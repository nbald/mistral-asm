#!/usr/bin/env python3
"""External oracle for the token-0 layer-5 post-FFN residual smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-5 FFN down oracle path, then adds the layer-5 post-attention residual to
the layer-5 FFN down output with scalar f32 rounding.
"""

import argparse

import numpy as np

from token0_attn_q_oracle import f32, f32_bits
from token0_layer5_ffn_down_oracle import (
    ATTN_NORM,
    ATTN_OUTPUT,
    ATTN_V,
    FFN_DOWN,
    FFN_GATE,
    FFN_NORM,
    FFN_UP,
    LAYER1_ATTN_NORM,
    LAYER1_ATTN_OUTPUT,
    LAYER1_ATTN_V,
    LAYER1_FFN_DOWN,
    LAYER1_FFN_GATE,
    LAYER1_FFN_NORM,
    LAYER1_FFN_UP,
    LAYER2_ATTN_NORM,
    LAYER2_ATTN_OUTPUT,
    LAYER2_ATTN_V,
    LAYER2_FFN_DOWN,
    LAYER2_FFN_GATE,
    LAYER2_FFN_NORM,
    LAYER2_FFN_UP,
    LAYER3_ATTN_NORM,
    LAYER3_ATTN_OUTPUT,
    LAYER3_ATTN_V,
    LAYER3_FFN_DOWN,
    LAYER3_FFN_GATE,
    LAYER3_FFN_NORM,
    LAYER3_FFN_UP,
    LAYER4_ATTN_K,
    LAYER4_ATTN_NORM,
    LAYER4_ATTN_OUTPUT,
    LAYER4_ATTN_Q,
    LAYER4_ATTN_V,
    LAYER4_FFN_DOWN,
    LAYER4_FFN_GATE,
    LAYER4_FFN_NORM,
    LAYER4_FFN_UP,
    LAYER5_ATTN_K,
    LAYER5_ATTN_NORM,
    LAYER5_ATTN_OUTPUT,
    LAYER5_ATTN_Q,
    LAYER5_ATTN_V,
    LAYER5_FFN_DOWN,
    LAYER5_FFN_GATE,
    LAYER5_FFN_NORM,
    LAYER5_FFN_UP,
    PUBLIC_OUTPUT_WORDS,
    TOKEN_EMBD,
    run_oracle as run_layer5_ffn_down_oracle,
)


def run_oracle(path, residual_words=PUBLIC_OUTPUT_WORDS):
    result = run_layer5_ffn_down_oracle(path, residual_words)
    post_attn = result["layer5_post_attn_residuals"]
    down = result["layer5_ffn_down_outputs"]

    residuals = np.empty(residual_words, dtype=np.float32)
    for index in range(residual_words):
        residuals[index] = f32(post_attn[index] + down[index])

    result["layer5_post_ffn_residuals"] = residuals
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-5 post-FFN residual words.")
    parser.add_argument("model", help="path to the target Q8_0 GGUF model")
    parser.add_argument(
        "--residual-words", type=int, default=PUBLIC_OUTPUT_WORDS,
        help="number of layer-5 down/residual words to print")
    args = parser.parse_args()

    result = run_oracle(args.model, args.residual_words)

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
                  LAYER3_ATTN_OUTPUT, LAYER3_FFN_NORM, LAYER3_FFN_GATE,
                  LAYER3_FFN_UP, LAYER3_FFN_DOWN, LAYER4_ATTN_NORM,
                  LAYER4_ATTN_Q, LAYER4_ATTN_K, LAYER4_ATTN_V,
                  LAYER4_ATTN_OUTPUT, LAYER4_FFN_NORM, LAYER4_FFN_GATE,
                  LAYER4_FFN_UP, LAYER4_FFN_DOWN, LAYER5_ATTN_NORM,
                  LAYER5_ATTN_Q, LAYER5_ATTN_K, LAYER5_ATTN_V,
                  LAYER5_ATTN_OUTPUT, LAYER5_FFN_NORM, LAYER5_FFN_GATE,
                  LAYER5_FFN_UP, LAYER5_FFN_DOWN):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["layer3_post_ffn_residuals"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer3_post_ffn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer4_attn_output_outputs"]):
        print(f"oracle_token0_layer4_attn_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer4_post_attn_residuals"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer4_post_attn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer4_ffn_norm_words"]):
        print(f"oracle_token0_layer4_ffn_norm{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer4_ffn_gate_outputs"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer4_ffn_gate_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer4_ffn_up_outputs"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer4_ffn_up_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer4_ffn_swiglu_outputs"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer4_ffn_swiglu_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer4_ffn_down_outputs"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer4_ffn_down_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer4_post_ffn_residuals"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer4_post_ffn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer5_attn_norm_words"]):
        print(f"oracle_token0_layer5_attn_norm{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer5_attn_q_outputs"]):
        print(f"oracle_token0_layer5_attn_q_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer5_attn_k_outputs"]):
        print(f"oracle_token0_layer5_attn_k_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer5_attn_v_outputs"]):
        print(f"oracle_token0_layer5_attn_v_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer5_attn_output_outputs"]):
        print(f"oracle_token0_layer5_attn_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer5_post_attn_residuals"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer5_post_attn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer5_ffn_norm_words"]):
        print(f"oracle_token0_layer5_ffn_norm{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer5_ffn_gate_outputs"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer5_ffn_gate_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer5_ffn_up_outputs"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer5_ffn_up_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer5_ffn_swiglu_outputs"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer5_ffn_swiglu_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer5_ffn_down_outputs"]):
        print(f"oracle_token0_layer5_ffn_down_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer5_post_ffn_residuals"]):
        print(f"oracle_token0_layer5_post_ffn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
