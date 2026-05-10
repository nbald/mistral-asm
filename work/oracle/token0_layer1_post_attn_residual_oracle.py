#!/usr/bin/env python3
"""External oracle for the token-0 layer-1 post-attention residual smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-1 attention output oracle path, then applies the same f32-rounded
residual add that the assembly smoke path performs for the first four output
words.
"""

import argparse

import numpy as np

from token0_attn_q_oracle import f32, f32_bits
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
from token0_layer1_attn_output_oracle import (
    LAYER1_ATTN_OUTPUT,
    run_oracle as run_layer1_attn_output_oracle,
)
from token0_layer1_attn_v_oracle import LAYER1_ATTN_V


def run_oracle(path):
    result = run_layer1_attn_output_oracle(path)
    post_ffn = result["post_ffn_residuals"]
    attn_output = result["layer1_attn_output_outputs"]

    result["layer1_post_attn_residuals"] = np.empty(4, dtype=np.float32)
    for index in range(4):
        result["layer1_post_attn_residuals"][index] = f32(
            post_ffn[index] + attn_output[index])
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-1 post-attention residual "
                    "oracle words.")
    parser.add_argument("model", help="path to the target Q8_0 GGUF model")
    args = parser.parse_args()

    result = run_oracle(args.model)

    print(f"tensor_data_offset: {result['tensor_data_offset']}")
    print(f"attn_norm_rms_epsilon_f32_hex: "
          f"0x{result['epsilon_bits']:08x}")
    for label in (TOKEN_EMBD, ATTN_NORM, ATTN_V, ATTN_OUTPUT, FFN_NORM,
                  FFN_GATE, FFN_UP, FFN_DOWN, LAYER1_ATTN_NORM,
                  LAYER1_ATTN_V, LAYER1_ATTN_OUTPUT):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["post_ffn_residuals"][:4]):
        print(f"oracle_token0_post_ffn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer1_attn_output_outputs"]):
        print(f"oracle_token0_layer1_attn_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer1_post_attn_residuals"]):
        print(f"oracle_token0_layer1_post_attn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
