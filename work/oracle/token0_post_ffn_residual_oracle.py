#!/usr/bin/env python3
"""External oracle for the token-0 first post-FFN residual smoke.

This file is verification tooling, not runtime source. It reuses the external
FFN down oracle to recompute the full scalar path through blk.0.ffn_down.weight,
then applies the same f32-rounded residual add that the assembly smoke path
performs for the first four output words.
"""

import argparse

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
    run_oracle as run_ffn_down_oracle,
)


def run_oracle(path):
    result = run_ffn_down_oracle(path)
    post_attn = result["post_attn_residual_words"]
    down = result["down_outputs"]
    result["post_ffn_residuals"] = [
        f32(post_attn[index] + down[index])
        for index in range(4)
    ]
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 post-FFN residual oracle words.")
    parser.add_argument("model", help="path to the target Q8_0 GGUF model")
    args = parser.parse_args()

    result = run_oracle(args.model)

    print(f"tensor_data_offset: {result['tensor_data_offset']}")
    print(f"attn_norm_rms_epsilon_f32_hex: "
          f"0x{result['epsilon_bits']:08x}")
    for label in (TOKEN_EMBD, ATTN_NORM, ATTN_V, ATTN_OUTPUT, FFN_NORM,
                  FFN_GATE, FFN_UP, FFN_DOWN):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["post_attn_residual_words"]):
        print(f"oracle_token0_post_attn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["down_outputs"]):
        print(f"oracle_token0_ffn_down_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["post_ffn_residuals"]):
        print(f"oracle_token0_post_ffn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
