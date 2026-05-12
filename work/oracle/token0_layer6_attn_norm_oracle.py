#!/usr/bin/env python3
"""External oracle for the token-0 layer-6 attention RMSNorm smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-5 post-FFN residual oracle in full-width mode, then applies
blk.6.attn_norm.weight with the same RMSNorm helper semantics used by the
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
from token0_layer5_post_ffn_residual_oracle import (
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
    run_oracle as run_layer5_post_ffn_residual_oracle,
)


LAYER6_ATTN_NORM = "blk.6.attn_norm.weight"


def load_layer6_attn_norm(path, expected_epsilon_bits,
                          layer5_post_ffn_residuals):
    require(len(layer5_post_ffn_residuals) == OUTPUT_WIDTH,
            "layer-5 post-FFN residual width mismatch")

    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            require(epsilon_bits == expected_epsilon_bits,
                    "metadata epsilon changed between oracle passes")

            layer6_attn_norm = require_tensor(
                tensors, LAYER6_ATTN_NORM, GGML_TYPE_F32, 1)
            require(layer6_attn_norm["dims"][0] == OUTPUT_WIDTH,
                    "layer-6 attention RMSNorm width mismatch")

            norm_start = tensor_pointer(
                buf, tensor_data_offset, layer6_attn_norm, OUTPUT_WIDTH * 4)
            norm_weight = np.frombuffer(
                buf, dtype="<f4", count=OUTPUT_WIDTH,
                offset=norm_start).copy()
            norm_output = rmsnorm(
                layer5_post_ffn_residuals, norm_weight,
                f32_from_bits(epsilon_bits))

            return {
                "tensor_data_offset": tensor_data_offset,
                LAYER6_ATTN_NORM: layer6_attn_norm,
                "layer6_attn_norm_activation": norm_output.copy(),
                "layer6_attn_norm_words": norm_output[
                    :PUBLIC_OUTPUT_WORDS].copy(),
            }
    finally:
        os.close(fd)


def run_oracle(path):
    result = run_layer5_post_ffn_residual_oracle(path, OUTPUT_WIDTH)
    norm = load_layer6_attn_norm(
        path,
        result["epsilon_bits"],
        result["layer5_post_ffn_residuals"],
    )

    result.update(norm)
    return result


def print_tensor(result, label):
    tensor = result[label]
    dims = "x".join(str(dim) for dim in tensor["dims"])
    print(f"{label}: type {tensor['type']} dims {dims} "
          f"offset {tensor['offset']}")


def print_words(label, values):
    for index, value in enumerate(values):
        print(f"oracle_{label}{index}_f32_hex: 0x{f32_bits(value):08x}")


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-6 attention RMSNorm words.")
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
                  LAYER4_FFN_UP, LAYER4_FFN_DOWN, LAYER5_ATTN_NORM,
                  LAYER5_ATTN_Q, LAYER5_ATTN_K, LAYER5_ATTN_V,
                  LAYER5_ATTN_OUTPUT, LAYER5_FFN_NORM, LAYER5_FFN_GATE,
                  LAYER5_FFN_UP, LAYER5_FFN_DOWN, LAYER6_ATTN_NORM):
        print_tensor(result, label)

    print_words(
        "token0_layer3_post_ffn_residual",
        result["layer3_post_ffn_residuals"][:PUBLIC_OUTPUT_WORDS])
    print_words(
        "token0_layer4_attn_output",
        result["layer4_attn_output_outputs"][:PUBLIC_OUTPUT_WORDS])
    print_words(
        "token0_layer4_post_attn_residual",
        result["layer4_post_attn_residuals"][:PUBLIC_OUTPUT_WORDS])
    print_words("token0_layer4_ffn_norm", result["layer4_ffn_norm_words"])
    print_words(
        "token0_layer4_ffn_gate_output",
        result["layer4_ffn_gate_outputs"][:PUBLIC_OUTPUT_WORDS])
    print_words(
        "token0_layer4_ffn_up_output",
        result["layer4_ffn_up_outputs"][:PUBLIC_OUTPUT_WORDS])
    print_words(
        "token0_layer4_ffn_swiglu_output",
        result["layer4_ffn_swiglu_outputs"][:PUBLIC_OUTPUT_WORDS])
    print_words(
        "token0_layer4_ffn_down_output",
        result["layer4_ffn_down_outputs"][:PUBLIC_OUTPUT_WORDS])
    print_words(
        "token0_layer4_post_ffn_residual",
        result["layer4_post_ffn_residuals"][:PUBLIC_OUTPUT_WORDS])
    print_words("token0_layer5_attn_norm", result["layer5_attn_norm_words"])
    print_words("token0_layer5_attn_q_output", result["layer5_attn_q_outputs"])
    print_words("token0_layer5_attn_k_output", result["layer5_attn_k_outputs"])
    print_words("token0_layer5_attn_v_output", result["layer5_attn_v_outputs"])
    print_words(
        "token0_layer5_attn_output",
        result["layer5_attn_output_outputs"][:PUBLIC_OUTPUT_WORDS])
    print_words(
        "token0_layer5_post_attn_residual",
        result["layer5_post_attn_residuals"][:PUBLIC_OUTPUT_WORDS])
    print_words("token0_layer5_ffn_norm", result["layer5_ffn_norm_words"])
    print_words(
        "token0_layer5_ffn_gate_output",
        result["layer5_ffn_gate_outputs"][:PUBLIC_OUTPUT_WORDS])
    print_words(
        "token0_layer5_ffn_up_output",
        result["layer5_ffn_up_outputs"][:PUBLIC_OUTPUT_WORDS])
    print_words(
        "token0_layer5_ffn_swiglu_output",
        result["layer5_ffn_swiglu_outputs"][:PUBLIC_OUTPUT_WORDS])
    print_words(
        "token0_layer5_ffn_down_output",
        result["layer5_ffn_down_outputs"][:PUBLIC_OUTPUT_WORDS])
    print_words(
        "token0_layer5_post_ffn_residual",
        result["layer5_post_ffn_residuals"][:PUBLIC_OUTPUT_WORDS])
    print_words("token0_layer6_attn_norm", result["layer6_attn_norm_words"])


if __name__ == "__main__":
    main()
