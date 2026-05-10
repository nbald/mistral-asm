#!/usr/bin/env python3
"""External oracle for the token-0 layer-1 attention RMSNorm smoke.

This file is verification tooling, not runtime source. It reuses the external
post-FFN residual oracle path to compute the full 3072-word residual after
layer 0, then applies blk.1.attn_norm.weight with the same RMSNorm helper
semantics used by the assembly smoke.
"""

import argparse
import mmap
import os

import numpy as np

from token0_attn_output_oracle import OUTPUT_WIDTH
from token0_attn_q_oracle import (
    GGML_TYPE_F32,
    f32_bits,
    f32_from_bits,
    parse_gguf,
    require,
    require_tensor,
    rmsnorm,
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
from token0_post_ffn_residual_oracle import run_oracle as run_post_ffn_oracle


LAYER1_ATTN_NORM = "blk.1.attn_norm.weight"


def load_layer1_attn_norm(path, expected_epsilon_bits):
    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            require(epsilon_bits == expected_epsilon_bits,
                    "metadata epsilon changed between oracle passes")

            layer1_attn_norm = require_tensor(
                tensors, LAYER1_ATTN_NORM, GGML_TYPE_F32, 1)
            require(layer1_attn_norm["dims"][0] == OUTPUT_WIDTH,
                    "layer-1 attention RMSNorm width mismatch")

            norm_start = tensor_pointer(
                buf, tensor_data_offset, layer1_attn_norm, OUTPUT_WIDTH * 4)
            weights = np.frombuffer(
                buf, dtype="<f4", count=OUTPUT_WIDTH,
                offset=norm_start).copy()

            return tensor_data_offset, layer1_attn_norm, weights
    finally:
        os.close(fd)


def run_oracle(path):
    result = run_post_ffn_oracle(path, residual_words=OUTPUT_WIDTH)
    tensor_data_offset, layer1_attn_norm, weights = load_layer1_attn_norm(
        path, result["epsilon_bits"])

    result["tensor_data_offset"] = tensor_data_offset
    result[LAYER1_ATTN_NORM] = layer1_attn_norm
    result["layer1_attn_norm_words"] = rmsnorm(
        result["post_ffn_residuals"], weights,
        f32_from_bits(result["epsilon_bits"]))[:4].copy()
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-1 attention RMSNorm words.")
    parser.add_argument("model", help="path to the target Q8_0 GGUF model")
    args = parser.parse_args()

    result = run_oracle(args.model)

    print(f"tensor_data_offset: {result['tensor_data_offset']}")
    print(f"attn_norm_rms_epsilon_f32_hex: "
          f"0x{result['epsilon_bits']:08x}")
    for label in (TOKEN_EMBD, ATTN_NORM, ATTN_V, ATTN_OUTPUT, FFN_NORM,
                  FFN_GATE, FFN_UP, FFN_DOWN, LAYER1_ATTN_NORM):
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


if __name__ == "__main__":
    main()
