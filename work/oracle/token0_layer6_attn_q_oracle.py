#!/usr/bin/env python3
"""External oracle for the token-0 layer-6 attention query projection smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-6 attention RMSNorm oracle path, then dots that full 3072-word activation
with the first four rows of blk.6.attn_q.weight using the same scalar f32 Q8_0
accumulation order as the assembly smoke path.
"""

import argparse
import mmap
import os

import token0_layer6_attn_norm_oracle as norm_oracle

from token0_attn_output_oracle import OUTPUT_WIDTH
from token0_attn_q_oracle import (
    GGML_TYPE_Q8_0,
    parse_gguf,
    q8_0_row_bytes,
    require,
    require_tensor,
    tensor_pointer,
)
from token0_layer2_attn_output_oracle import q8_0_dot_row_ordered_numpy
from token0_layer6_attn_norm_oracle import (
    LAYER6_ATTN_NORM,
    run_oracle as run_layer6_attn_norm_oracle,
)


LAYER6_ATTN_Q = "blk.6.attn_q.weight"
LAYER6_ATTN_Q_OUTPUT_WIDTH = 4096
PUBLIC_OUTPUT_WORDS = 4


def load_layer6_attn_q_outputs(path, expected_epsilon_bits, activation):
    require(len(activation) == OUTPUT_WIDTH,
            "layer-6 attention RMSNorm activation width mismatch")

    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            require(epsilon_bits == expected_epsilon_bits,
                    "metadata epsilon changed between oracle passes")

            layer6_attn_q = require_tensor(
                tensors, LAYER6_ATTN_Q, GGML_TYPE_Q8_0, 2)
            require(layer6_attn_q["dims"][0] == OUTPUT_WIDTH,
                    "layer-6 attention query input width mismatch")
            require(layer6_attn_q["dims"][1] == LAYER6_ATTN_Q_OUTPUT_WIDTH,
                    "layer-6 attention query output width mismatch")

            row_bytes = q8_0_row_bytes(layer6_attn_q["dims"][0])
            matrix_start = tensor_pointer(
                buf, tensor_data_offset, layer6_attn_q,
                row_bytes * layer6_attn_q["dims"][1])

            outputs = []
            for row in range(PUBLIC_OUTPUT_WORDS):
                row_start = matrix_start + row * row_bytes
                outputs.append(q8_0_dot_row_ordered_numpy(
                    buf, row_start, activation))

            return {
                "tensor_data_offset": tensor_data_offset,
                LAYER6_ATTN_Q: layer6_attn_q,
                "layer6_attn_q_outputs": outputs,
            }
    finally:
        os.close(fd)


def run_oracle(path):
    result = run_layer6_attn_norm_oracle(path)
    query = load_layer6_attn_q_outputs(
        path,
        result["epsilon_bits"],
        result["layer6_attn_norm_activation"],
    )

    result.update(query)
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-6 attention query words.")
    parser.add_argument("model", help="path to the target Q8_0 GGUF model")
    args = parser.parse_args()

    result = run_oracle(args.model)

    print(f"tensor_data_offset: {result['tensor_data_offset']}")
    print(f"attn_norm_rms_epsilon_f32_hex: "
          f"0x{result['epsilon_bits']:08x}")
    for label in (norm_oracle.TOKEN_EMBD, norm_oracle.ATTN_NORM,
                  norm_oracle.ATTN_V, norm_oracle.ATTN_OUTPUT,
                  norm_oracle.FFN_NORM, norm_oracle.FFN_GATE,
                  norm_oracle.FFN_UP, norm_oracle.FFN_DOWN,
                  norm_oracle.LAYER1_ATTN_NORM, norm_oracle.LAYER1_ATTN_V,
                  norm_oracle.LAYER1_ATTN_OUTPUT,
                  norm_oracle.LAYER1_FFN_NORM, norm_oracle.LAYER1_FFN_GATE,
                  norm_oracle.LAYER1_FFN_UP, norm_oracle.LAYER1_FFN_DOWN,
                  norm_oracle.LAYER2_ATTN_NORM, norm_oracle.LAYER2_ATTN_V,
                  norm_oracle.LAYER2_ATTN_OUTPUT,
                  norm_oracle.LAYER2_FFN_NORM, norm_oracle.LAYER2_FFN_GATE,
                  norm_oracle.LAYER2_FFN_UP, norm_oracle.LAYER2_FFN_DOWN,
                  norm_oracle.LAYER3_ATTN_NORM, norm_oracle.LAYER3_ATTN_V,
                  norm_oracle.LAYER3_ATTN_OUTPUT,
                  norm_oracle.LAYER3_FFN_NORM, norm_oracle.LAYER3_FFN_GATE,
                  norm_oracle.LAYER3_FFN_UP, norm_oracle.LAYER3_FFN_DOWN,
                  norm_oracle.LAYER4_ATTN_NORM, norm_oracle.LAYER4_ATTN_Q,
                  norm_oracle.LAYER4_ATTN_K, norm_oracle.LAYER4_ATTN_V,
                  norm_oracle.LAYER4_ATTN_OUTPUT,
                  norm_oracle.LAYER4_FFN_NORM, norm_oracle.LAYER4_FFN_GATE,
                  norm_oracle.LAYER4_FFN_UP, norm_oracle.LAYER4_FFN_DOWN,
                  norm_oracle.LAYER5_ATTN_NORM, norm_oracle.LAYER5_ATTN_Q,
                  norm_oracle.LAYER5_ATTN_K, norm_oracle.LAYER5_ATTN_V,
                  norm_oracle.LAYER5_ATTN_OUTPUT,
                  norm_oracle.LAYER5_FFN_NORM, norm_oracle.LAYER5_FFN_GATE,
                  norm_oracle.LAYER5_FFN_UP, norm_oracle.LAYER5_FFN_DOWN,
                  LAYER6_ATTN_NORM, LAYER6_ATTN_Q):
        norm_oracle.print_tensor(result, label)

    word_groups = (
        ("token0_layer3_post_ffn_residual",
         result["layer3_post_ffn_residuals"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer4_attn_output",
         result["layer4_attn_output_outputs"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer4_post_attn_residual",
         result["layer4_post_attn_residuals"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer4_ffn_norm", result["layer4_ffn_norm_words"]),
        ("token0_layer4_ffn_gate_output",
         result["layer4_ffn_gate_outputs"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer4_ffn_up_output",
         result["layer4_ffn_up_outputs"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer4_ffn_swiglu_output",
         result["layer4_ffn_swiglu_outputs"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer4_ffn_down_output",
         result["layer4_ffn_down_outputs"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer4_post_ffn_residual",
         result["layer4_post_ffn_residuals"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer5_attn_norm", result["layer5_attn_norm_words"]),
        ("token0_layer5_attn_q_output", result["layer5_attn_q_outputs"]),
        ("token0_layer5_attn_k_output", result["layer5_attn_k_outputs"]),
        ("token0_layer5_attn_v_output", result["layer5_attn_v_outputs"]),
        ("token0_layer5_attn_output",
         result["layer5_attn_output_outputs"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer5_post_attn_residual",
         result["layer5_post_attn_residuals"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer5_ffn_norm", result["layer5_ffn_norm_words"]),
        ("token0_layer5_ffn_gate_output",
         result["layer5_ffn_gate_outputs"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer5_ffn_up_output",
         result["layer5_ffn_up_outputs"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer5_ffn_swiglu_output",
         result["layer5_ffn_swiglu_outputs"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer5_ffn_down_output",
         result["layer5_ffn_down_outputs"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer5_post_ffn_residual",
         result["layer5_post_ffn_residuals"][:PUBLIC_OUTPUT_WORDS]),
        ("token0_layer6_attn_norm", result["layer6_attn_norm_words"]),
        ("token0_layer6_attn_q_output", result["layer6_attn_q_outputs"]),
    )
    for label, values in word_groups:
        norm_oracle.print_words(label, values)


if __name__ == "__main__":
    main()
