#!/usr/bin/env python3
"""External oracle for the token-0 layer-1 attention value projection smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-1 attention RMSNorm oracle path to compute the full 3072-word activation,
then dots that activation with the first four rows of blk.1.attn_v.weight using
the same scalar f32 Q8_0 arithmetic order as the assembly smoke path.
"""

import argparse
import mmap
import os

from token0_attn_output_oracle import OUTPUT_WIDTH
from token0_attn_q_oracle import (
    GGML_TYPE_Q8_0,
    f32_bits,
    parse_gguf,
    q8_0_dot_row,
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
from token0_layer1_attn_norm_oracle import (
    LAYER1_ATTN_NORM,
    run_oracle as run_layer1_attn_norm_oracle,
)


LAYER1_ATTN_V = "blk.1.attn_v.weight"
LAYER1_ATTN_V_OUTPUT_WIDTH = 1024
PUBLIC_OUTPUT_WORDS = 4


def load_layer1_attn_v_outputs(path, expected_epsilon_bits, activation):
    require(len(activation) == OUTPUT_WIDTH,
            "layer-1 attention RMSNorm activation width mismatch")

    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            require(epsilon_bits == expected_epsilon_bits,
                    "metadata epsilon changed between oracle passes")

            layer1_attn_v = require_tensor(
                tensors, LAYER1_ATTN_V, GGML_TYPE_Q8_0, 2)
            require(layer1_attn_v["dims"][0] == OUTPUT_WIDTH,
                    "layer-1 attention value input width mismatch")
            require(layer1_attn_v["dims"][1] == LAYER1_ATTN_V_OUTPUT_WIDTH,
                    "layer-1 attention value output width mismatch")

            row_bytes = q8_0_row_bytes(layer1_attn_v["dims"][0])
            matrix_start = tensor_pointer(
                buf, tensor_data_offset, layer1_attn_v,
                row_bytes * layer1_attn_v["dims"][1])

            outputs = []
            for row in range(PUBLIC_OUTPUT_WORDS):
                row_start = matrix_start + row * row_bytes
                outputs.append(q8_0_dot_row(buf, row_start, activation))

            return tensor_data_offset, layer1_attn_v, outputs
    finally:
        os.close(fd)


def run_oracle(path):
    result = run_layer1_attn_norm_oracle(path)
    tensor_data_offset, layer1_attn_v, outputs = load_layer1_attn_v_outputs(
        path, result["epsilon_bits"], result["layer1_attn_norm_activation"])

    result["tensor_data_offset"] = tensor_data_offset
    result[LAYER1_ATTN_V] = layer1_attn_v
    result["layer1_attn_v_outputs"] = outputs
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-1 attention value words.")
    parser.add_argument("model", help="path to the target Q8_0 GGUF model")
    args = parser.parse_args()

    result = run_oracle(args.model)

    print(f"tensor_data_offset: {result['tensor_data_offset']}")
    print(f"attn_norm_rms_epsilon_f32_hex: "
          f"0x{result['epsilon_bits']:08x}")
    for label in (TOKEN_EMBD, ATTN_NORM, ATTN_V, ATTN_OUTPUT, FFN_NORM,
                  FFN_GATE, FFN_UP, FFN_DOWN, LAYER1_ATTN_NORM,
                  LAYER1_ATTN_V):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["post_ffn_residuals"][:4]):
        print(f"oracle_token0_post_ffn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer1_attn_norm_words"]):
        print(f"oracle_token0_layer1_attn_norm{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer1_attn_v_outputs"]):
        print(f"oracle_token0_layer1_attn_v_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
