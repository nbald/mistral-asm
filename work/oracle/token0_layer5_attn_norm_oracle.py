#!/usr/bin/env python3
"""External oracle for the token-0 layer-5 attention RMSNorm smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-4 post-FFN residual oracle in full-width mode, then applies
blk.5.attn_norm.weight with the same RMSNorm helper semantics used by the
assembly smoke.
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
)
from token0_layer4_ffn_gate_oracle import LAYER4_FFN_GATE
from token0_layer4_ffn_norm_oracle import LAYER4_FFN_NORM
from token0_layer4_ffn_up_oracle import LAYER4_FFN_UP
from token0_layer4_post_ffn_residual_oracle import (
    run_oracle as run_layer4_post_ffn_residual_oracle,
)


LAYER5_ATTN_NORM = "blk.5.attn_norm.weight"


def load_layer5_attn_norm(path, expected_epsilon_bits,
                          layer4_post_ffn_residuals):
    require(len(layer4_post_ffn_residuals) == OUTPUT_WIDTH,
            "layer-4 post-FFN residual width mismatch")

    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            require(epsilon_bits == expected_epsilon_bits,
                    "metadata epsilon changed between oracle passes")

            layer5_attn_norm = require_tensor(
                tensors, LAYER5_ATTN_NORM, GGML_TYPE_F32, 1)
            require(layer5_attn_norm["dims"][0] == OUTPUT_WIDTH,
                    "layer-5 attention RMSNorm width mismatch")

            norm_start = tensor_pointer(
                buf, tensor_data_offset, layer5_attn_norm, OUTPUT_WIDTH * 4)
            norm_weight = np.frombuffer(
                buf, dtype="<f4", count=OUTPUT_WIDTH,
                offset=norm_start).copy()
            norm_output = rmsnorm(
                layer4_post_ffn_residuals, norm_weight,
                f32_from_bits(epsilon_bits))

            return {
                "tensor_data_offset": tensor_data_offset,
                LAYER5_ATTN_NORM: layer5_attn_norm,
                "layer5_attn_norm_activation": norm_output.copy(),
                "layer5_attn_norm_words": norm_output[
                    :PUBLIC_OUTPUT_WORDS].copy(),
            }
    finally:
        os.close(fd)


def run_oracle(path):
    result = run_layer4_post_ffn_residual_oracle(path, OUTPUT_WIDTH)
    norm = load_layer5_attn_norm(
        path,
        result["epsilon_bits"],
        result["layer4_post_ffn_residuals"],
    )

    result.update(norm)
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-5 attention RMSNorm words.")
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
                  LAYER3_ATTN_OUTPUT, LAYER3_FFN_NORM, LAYER3_FFN_GATE,
                  LAYER3_FFN_UP, LAYER3_FFN_DOWN, LAYER4_ATTN_NORM,
                  LAYER4_ATTN_Q, LAYER4_ATTN_K, LAYER4_ATTN_V,
                  LAYER4_ATTN_OUTPUT, LAYER4_FFN_NORM, LAYER4_FFN_GATE,
                  LAYER4_FFN_UP, LAYER4_FFN_DOWN, LAYER5_ATTN_NORM):
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


if __name__ == "__main__":
    main()
