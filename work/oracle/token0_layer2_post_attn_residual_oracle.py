#!/usr/bin/env python3
"""External oracle for the token-0 layer-2 post-attention residual smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-2 attention output oracle path, then applies the same f32-rounded
residual add that the assembly smoke path performs for the first four output
words.
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
    run_oracle as run_layer2_attn_output_oracle,
)
from token0_layer2_attn_v_oracle import LAYER2_ATTN_V


PUBLIC_OUTPUT_WORDS = 4


def run_oracle(path):
    result = run_layer2_attn_output_oracle(path)
    post_ffn = result["layer1_post_ffn_residuals"]
    attn_output = result["layer2_attn_output_outputs"]

    result["layer2_post_attn_residuals"] = []
    for index in range(PUBLIC_OUTPUT_WORDS):
        result["layer2_post_attn_residuals"].append(
            f32(post_ffn[index] + attn_output[index]))
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-2 post-attention residual "
                    "oracle words.")
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
    for index, value in enumerate(result["layer2_attn_output_outputs"]):
        print(f"oracle_token0_layer2_attn_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer2_post_attn_residuals"]):
        print(f"oracle_token0_layer2_post_attn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
