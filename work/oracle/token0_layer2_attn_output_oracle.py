#!/usr/bin/env python3
"""External oracle for the token-0 layer-2 attention output projection smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-2 attention RMSNorm oracle path, computes the full layer-2 value
projection, expands the one-token grouped-query context, and dots that context
with the first four rows of blk.2.attn_output.weight using the same scalar f32
Q8_0 arithmetic order as the assembly smoke path.
"""

import argparse
import mmap
import os

import numpy as np

import token0_attn_output_oracle
import token0_ffn_down_oracle
import token0_layer1_attn_output_oracle
import token0_layer1_ffn_norm_oracle
import token0_layer1_post_ffn_residual_oracle as layer1_post_ffn_module

from token0_attn_output_oracle import (
    CONTEXT_WIDTH,
    OUTPUT_WIDTH,
    VALUE_OUTPUT_WIDTH,
    expand_single_token_context,
)
from token0_attn_q_oracle import (
    GGML_TYPE_Q8_0,
    Q8_0_BLOCK_BYTES,
    Q8_0_BLOCK_VALUES,
    f32,
    f32_bits,
    parse_gguf,
    q8_0_row_bytes,
    require,
    require_span,
    require_tensor,
    tensor_pointer,
)
from token0_ffn_down_oracle import (
    ATTN_NORM,
    ATTN_OUTPUT,
    ATTN_V,
    FFN_DOWN,
    FFN_GATE,
    FFN_NORM,
    FFN_UP,
    TOKEN_EMBD,
)
from token0_layer1_attn_norm_oracle import LAYER1_ATTN_NORM
from token0_layer1_attn_output_oracle import LAYER1_ATTN_OUTPUT
from token0_layer1_attn_v_oracle import LAYER1_ATTN_V
from token0_layer1_ffn_norm_oracle import LAYER1_FFN_NORM
from token0_layer1_post_ffn_residual_oracle import (
    LAYER1_FFN_DOWN,
    LAYER1_FFN_GATE,
    LAYER1_FFN_UP,
)
from token0_layer2_attn_norm_oracle import (
    LAYER2_ATTN_NORM,
    run_oracle as run_layer2_attn_norm_oracle,
)
from token0_layer2_attn_v_oracle import LAYER2_ATTN_V


LAYER2_ATTN_OUTPUT = "blk.2.attn_output.weight"
PUBLIC_OUTPUT_WORDS = 4


def q8_0_dot_row_ordered_numpy(buf, row_start, activation):
    """Compute one Q8_0 row dot with f32 products and ordered f32 summation."""
    require(len(activation) % Q8_0_BLOCK_VALUES == 0,
            "Q8_0 activation width is not a multiple of 32")
    block_count = len(activation) // Q8_0_BLOCK_VALUES
    if block_count == 0:
        return f32(0.0)

    require_span(buf, row_start, block_count * Q8_0_BLOCK_BYTES)
    activation_blocks = np.asarray(
        activation, dtype=np.float32).reshape(block_count, Q8_0_BLOCK_VALUES)
    scales = np.ndarray(
        (block_count,), dtype="<f2", buffer=buf, offset=row_start,
        strides=(Q8_0_BLOCK_BYTES,)).astype(np.float32)
    quants = np.ndarray(
        (block_count, Q8_0_BLOCK_VALUES), dtype=np.int8, buffer=buf,
        offset=row_start + 2,
        strides=(Q8_0_BLOCK_BYTES, 1)).astype(np.float32)

    # Keep the assembly's dequantize, multiply, then row-order accumulate
    # contract. np.cumsum with dtype float32 preserves the public row order
    # while avoiding Python-level unpacking for every scalar.
    dequant = quants * scales[:, None]
    products = dequant * activation_blocks
    return np.cumsum(products.ravel(), dtype=np.float32)[-1]


def install_ordered_numpy_dot():
    modules = (
        token0_attn_output_oracle,
        token0_ffn_down_oracle,
        token0_layer1_attn_output_oracle,
        token0_layer1_ffn_norm_oracle,
        layer1_post_ffn_module,
    )
    for module in modules:
        module.q8_0_dot_row = q8_0_dot_row_ordered_numpy


def load_layer2_attn_output_outputs(path, expected_epsilon_bits, activation):
    require(len(activation) == OUTPUT_WIDTH,
            "layer-2 attention RMSNorm activation width mismatch")

    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            require(epsilon_bits == expected_epsilon_bits,
                    "metadata epsilon changed between oracle passes")

            layer2_attn_v = require_tensor(
                tensors, LAYER2_ATTN_V, GGML_TYPE_Q8_0, 2)
            layer2_attn_output = require_tensor(
                tensors, LAYER2_ATTN_OUTPUT, GGML_TYPE_Q8_0, 2)
            require(layer2_attn_v["dims"][0] == OUTPUT_WIDTH,
                    "layer-2 attention value input width mismatch")
            require(layer2_attn_v["dims"][1] == VALUE_OUTPUT_WIDTH,
                    "layer-2 attention value output width mismatch")
            require(layer2_attn_output["dims"][0] == CONTEXT_WIDTH,
                    "layer-2 attention output input width mismatch")
            require(layer2_attn_output["dims"][1] == OUTPUT_WIDTH,
                    "layer-2 attention output row count mismatch")

            value_row_bytes = q8_0_row_bytes(layer2_attn_v["dims"][0])
            value_start = tensor_pointer(
                buf, tensor_data_offset, layer2_attn_v,
                value_row_bytes * layer2_attn_v["dims"][1])
            output_row_bytes = q8_0_row_bytes(
                layer2_attn_output["dims"][0])
            output_start = tensor_pointer(
                buf, tensor_data_offset, layer2_attn_output,
                output_row_bytes * layer2_attn_output["dims"][1])

            value_output = np.empty(VALUE_OUTPUT_WIDTH, dtype=np.float32)
            for row in range(VALUE_OUTPUT_WIDTH):
                row_start = value_start + row * value_row_bytes
                value_output[row] = q8_0_dot_row_ordered_numpy(
                    buf, row_start, activation)

            context = expand_single_token_context(value_output)

            outputs = []
            for row in range(PUBLIC_OUTPUT_WORDS):
                row_start = output_start + row * output_row_bytes
                outputs.append(q8_0_dot_row_ordered_numpy(
                    buf, row_start, context))

            return (
                tensor_data_offset,
                layer2_attn_v,
                layer2_attn_output,
                context[:PUBLIC_OUTPUT_WORDS].copy(),
                outputs,
            )
    finally:
        os.close(fd)


def run_oracle(path):
    install_ordered_numpy_dot()
    result = run_layer2_attn_norm_oracle(path)
    (
        tensor_data_offset,
        layer2_attn_v,
        layer2_attn_output,
        context_words,
        outputs,
    ) = load_layer2_attn_output_outputs(
        path, result["epsilon_bits"], result["layer2_attn_norm_activation"])

    result["tensor_data_offset"] = tensor_data_offset
    result[LAYER2_ATTN_V] = layer2_attn_v
    result[LAYER2_ATTN_OUTPUT] = layer2_attn_output
    result["layer2_attn_context_words"] = context_words
    result["layer2_attn_output_outputs"] = outputs
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-2 attention output words.")
    parser.add_argument("model", help="path to the target Q8_0 GGUF model")
    args = parser.parse_args()

    result = run_oracle(args.model)

    print(f"tensor_data_offset: {result['tensor_data_offset']}")
    print(f"attn_norm_rms_epsilon_f32_hex: "
          f"0x{result['epsilon_bits']:08x}")
    for label in (TOKEN_EMBD, ATTN_NORM, ATTN_V, ATTN_OUTPUT, FFN_NORM,
                  FFN_GATE, FFN_UP, FFN_DOWN, LAYER1_ATTN_NORM,
                  LAYER1_ATTN_V, LAYER1_ATTN_OUTPUT, LAYER1_FFN_NORM,
                  LAYER1_FFN_GATE, LAYER1_FFN_UP, LAYER1_FFN_DOWN,
                  LAYER2_ATTN_NORM, LAYER2_ATTN_V, LAYER2_ATTN_OUTPUT):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["layer1_post_ffn_residuals"][:4]):
        print(f"oracle_token0_layer1_post_ffn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer2_attn_norm_words"]):
        print(f"oracle_token0_layer2_attn_norm{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer2_attn_context_words"]):
        print(f"oracle_token0_layer2_attn_context{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer2_attn_output_outputs"]):
        print(f"oracle_token0_layer2_attn_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
