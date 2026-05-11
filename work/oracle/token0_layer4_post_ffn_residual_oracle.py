#!/usr/bin/env python3
"""External oracle for the token-0 layer-4 post-FFN residual smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-4 FFN down oracle path, then adds the layer-4 post-attention residual to
the layer-4 FFN down output with scalar f32 rounding.
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
from token0_layer1_attn_output_oracle import LAYER1_ATTN_OUTPUT
from token0_layer1_attn_v_oracle import LAYER1_ATTN_V
from token0_layer1_ffn_norm_oracle import LAYER1_FFN_NORM
from token0_layer1_post_ffn_residual_oracle import (
    LAYER1_FFN_DOWN,
    LAYER1_FFN_GATE,
    LAYER1_FFN_UP,
)
from token0_layer2_attn_norm_oracle import LAYER2_ATTN_NORM
from token0_layer2_attn_output_oracle import LAYER2_ATTN_OUTPUT
from token0_layer2_attn_v_oracle import LAYER2_ATTN_V
from token0_layer2_ffn_down_oracle import LAYER2_FFN_DOWN
from token0_layer2_ffn_gate_oracle import LAYER2_FFN_GATE
from token0_layer2_ffn_norm_oracle import LAYER2_FFN_NORM
from token0_layer2_ffn_up_oracle import LAYER2_FFN_UP
from token0_layer3_attn_norm_oracle import LAYER3_ATTN_NORM
from token0_layer3_attn_output_oracle import LAYER3_ATTN_OUTPUT
from token0_layer3_attn_v_oracle import LAYER3_ATTN_V
from token0_layer3_ffn_down_oracle import LAYER3_FFN_DOWN
from token0_layer3_ffn_gate_oracle import LAYER3_FFN_GATE
from token0_layer3_ffn_norm_oracle import LAYER3_FFN_NORM
from token0_layer3_ffn_up_oracle import LAYER3_FFN_UP
from token0_layer4_attn_k_oracle import LAYER4_ATTN_K
from token0_layer4_attn_norm_oracle import LAYER4_ATTN_NORM
from token0_layer4_attn_output_oracle import LAYER4_ATTN_OUTPUT
from token0_layer4_attn_q_oracle import LAYER4_ATTN_Q
from token0_layer4_attn_v_oracle import LAYER4_ATTN_V
from token0_layer4_ffn_down_oracle import (
    LAYER4_FFN_DOWN,
    PUBLIC_OUTPUT_WORDS,
    run_oracle as run_layer4_ffn_down_oracle,
)
from token0_layer4_ffn_gate_oracle import LAYER4_FFN_GATE
from token0_layer4_ffn_norm_oracle import LAYER4_FFN_NORM
from token0_layer4_ffn_up_oracle import LAYER4_FFN_UP


def run_oracle(path, residual_words=PUBLIC_OUTPUT_WORDS):
    result = run_layer4_ffn_down_oracle(path, residual_words)
    post_attn = result["layer4_post_attn_residuals"]
    down = result["layer4_ffn_down_outputs"]

    residuals = np.empty(residual_words, dtype=np.float32)
    for index in range(residual_words):
        residuals[index] = f32(post_attn[index] + down[index])

    result["layer4_post_ffn_residuals"] = residuals
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-4 post-FFN residual words.")
    parser.add_argument("model", help="path to the target Q8_0 GGUF model")
    parser.add_argument(
        "--residual-words", type=int, default=PUBLIC_OUTPUT_WORDS,
        help="number of layer-4 down/residual words to print")
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
                  LAYER4_FFN_UP, LAYER4_FFN_DOWN):
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
                                  [:args.residual_words]):
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
    for index, value in enumerate(result["layer4_ffn_down_outputs"]):
        print(f"oracle_token0_layer4_ffn_down_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer4_post_ffn_residuals"]):
        print(f"oracle_token0_layer4_post_ffn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
