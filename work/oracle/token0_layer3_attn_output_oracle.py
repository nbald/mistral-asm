#!/usr/bin/env python3
"""External oracle for the token-0 layer-3 attention output projection smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-3 attention RMSNorm oracle path, computes the complete layer-3 value
projection and single-token grouped-query context, then dots that context with
the first four rows of blk.3.attn_output.weight using the same scalar f32 Q8_0
arithmetic order as the assembly smoke path.
"""

import argparse
import mmap
import os

import numpy as np

from token0_attn_output_oracle import (
    CONTEXT_WIDTH,
    OUTPUT_WIDTH,
    VALUE_OUTPUT_WIDTH,
    expand_single_token_context,
)
from token0_attn_q_oracle import (
    GGML_TYPE_Q8_0,
    f32_bits,
    parse_gguf,
    q8_0_row_bytes,
    require,
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
from token0_layer2_attn_norm_oracle import LAYER2_ATTN_NORM
from token0_layer2_attn_output_oracle import (
    LAYER2_ATTN_OUTPUT,
    q8_0_dot_row_ordered_numpy,
)
from token0_layer2_attn_v_oracle import LAYER2_ATTN_V
from token0_layer2_ffn_down_oracle import LAYER2_FFN_DOWN
from token0_layer2_ffn_gate_oracle import LAYER2_FFN_GATE
from token0_layer2_ffn_norm_oracle import LAYER2_FFN_NORM
from token0_layer2_ffn_up_oracle import LAYER2_FFN_UP
from token0_layer3_attn_norm_oracle import (
    LAYER3_ATTN_NORM,
    run_oracle as run_layer3_attn_norm_oracle,
)
from token0_layer3_attn_v_oracle import LAYER3_ATTN_V


LAYER3_ATTN_OUTPUT = "blk.3.attn_output.weight"
PUBLIC_OUTPUT_WORDS = 4


def load_layer3_attn_output_outputs(path, expected_epsilon_bits, activation):
    require(len(activation) == OUTPUT_WIDTH,
            "layer-3 attention RMSNorm activation width mismatch")

    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            require(epsilon_bits == expected_epsilon_bits,
                    "metadata epsilon changed between oracle passes")

            layer3_attn_v = require_tensor(
                tensors, LAYER3_ATTN_V, GGML_TYPE_Q8_0, 2)
            layer3_attn_output = require_tensor(
                tensors, LAYER3_ATTN_OUTPUT, GGML_TYPE_Q8_0, 2)
            require(layer3_attn_v["dims"][0] == OUTPUT_WIDTH,
                    "layer-3 attention value input width mismatch")
            require(layer3_attn_v["dims"][1] == VALUE_OUTPUT_WIDTH,
                    "layer-3 attention value output width mismatch")
            require(layer3_attn_output["dims"][0] == CONTEXT_WIDTH,
                    "layer-3 attention output input width mismatch")
            require(layer3_attn_output["dims"][1] == OUTPUT_WIDTH,
                    "layer-3 attention output row count mismatch")

            value_row_bytes = q8_0_row_bytes(layer3_attn_v["dims"][0])
            value_start = tensor_pointer(
                buf, tensor_data_offset, layer3_attn_v,
                value_row_bytes * layer3_attn_v["dims"][1])
            output_row_bytes = q8_0_row_bytes(
                layer3_attn_output["dims"][0])
            output_start = tensor_pointer(
                buf, tensor_data_offset, layer3_attn_output,
                output_row_bytes * layer3_attn_output["dims"][1])

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

            return {
                "tensor_data_offset": tensor_data_offset,
                LAYER3_ATTN_V: layer3_attn_v,
                LAYER3_ATTN_OUTPUT: layer3_attn_output,
                "layer3_attn_v_outputs": value_output[
                    :PUBLIC_OUTPUT_WORDS].copy(),
                "layer3_attn_context_words": context[
                    :PUBLIC_OUTPUT_WORDS].copy(),
                "layer3_attn_output_outputs": outputs,
            }
    finally:
        os.close(fd)


def run_oracle(path):
    result = run_layer3_attn_norm_oracle(path)
    output = load_layer3_attn_output_outputs(
        path, result["epsilon_bits"], result["layer3_attn_norm_activation"])

    result.update(output)
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-3 attention output words.")
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
                  LAYER2_ATTN_NORM, LAYER2_ATTN_V, LAYER2_ATTN_OUTPUT,
                  LAYER2_FFN_NORM, LAYER2_FFN_GATE, LAYER2_FFN_UP,
                  LAYER2_FFN_DOWN, LAYER3_ATTN_NORM, LAYER3_ATTN_V,
                  LAYER3_ATTN_OUTPUT):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["layer2_post_ffn_residuals"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer2_post_ffn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_attn_norm_words"]):
        print(f"oracle_token0_layer3_attn_norm{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_attn_v_outputs"]):
        print(f"oracle_token0_layer3_attn_v_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_attn_context_words"]):
        print(f"oracle_token0_layer3_attn_context{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_attn_output_outputs"]):
        print(f"oracle_token0_layer3_attn_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
