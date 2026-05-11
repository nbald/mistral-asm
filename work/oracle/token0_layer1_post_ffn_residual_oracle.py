#!/usr/bin/env python3
"""External oracle for the token-0 layer-1 post-FFN residual smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-1 FFN RMSNorm oracle path, computes the full layer-1 FFN gate/up/SwiGLU
activation chain, dots that activation with blk.1.ffn_down.weight, then adds
the layer-1 post-attention residual with scalar f32 rounding.
"""

import argparse
import mmap
import os

import numpy as np

from token0_attn_output_oracle import OUTPUT_WIDTH
from token0_attn_q_oracle import (
    GGML_TYPE_Q8_0,
    f32,
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
from token0_ffn_swiglu_oracle import FFN_SWIGLU_WIDTH, swiglu_scalar
from token0_layer1_attn_norm_oracle import LAYER1_ATTN_NORM
from token0_layer1_attn_output_oracle import LAYER1_ATTN_OUTPUT
from token0_layer1_attn_v_oracle import LAYER1_ATTN_V
from token0_layer1_ffn_norm_oracle import (
    LAYER1_FFN_NORM,
    run_oracle as run_layer1_ffn_norm_oracle,
)


LAYER1_FFN_GATE = "blk.1.ffn_gate.weight"
LAYER1_FFN_UP = "blk.1.ffn_up.weight"
LAYER1_FFN_DOWN = "blk.1.ffn_down.weight"


def load_layer1_ffn_branch(path, expected_epsilon_bits, ffn_activation,
                           post_attn_residual, residual_words):
    require(len(ffn_activation) == OUTPUT_WIDTH,
            "layer-1 FFN RMSNorm activation width mismatch")
    require(len(post_attn_residual) == OUTPUT_WIDTH,
            "layer-1 post-attention residual width mismatch")
    require(0 <= residual_words <= OUTPUT_WIDTH,
            "requested layer-1 residual word count outside output width")

    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            require(epsilon_bits == expected_epsilon_bits,
                    "metadata epsilon changed between oracle passes")

            layer1_ffn_gate = require_tensor(
                tensors, LAYER1_FFN_GATE, GGML_TYPE_Q8_0, 2)
            layer1_ffn_up = require_tensor(
                tensors, LAYER1_FFN_UP, GGML_TYPE_Q8_0, 2)
            layer1_ffn_down = require_tensor(
                tensors, LAYER1_FFN_DOWN, GGML_TYPE_Q8_0, 2)
            require(layer1_ffn_gate["dims"][0] == OUTPUT_WIDTH,
                    "layer-1 FFN gate input width mismatch")
            require(layer1_ffn_gate["dims"][1] == FFN_SWIGLU_WIDTH,
                    "layer-1 FFN gate output width mismatch")
            require(layer1_ffn_up["dims"][0] == OUTPUT_WIDTH,
                    "layer-1 FFN up input width mismatch")
            require(layer1_ffn_up["dims"][1] == FFN_SWIGLU_WIDTH,
                    "layer-1 FFN up output width mismatch")
            require(layer1_ffn_down["dims"][0] == FFN_SWIGLU_WIDTH,
                    "layer-1 FFN down input width mismatch")
            require(layer1_ffn_down["dims"][1] == OUTPUT_WIDTH,
                    "layer-1 FFN down output width mismatch")

            gate_row_bytes = q8_0_row_bytes(layer1_ffn_gate["dims"][0])
            gate_start = tensor_pointer(
                buf, tensor_data_offset, layer1_ffn_gate,
                gate_row_bytes * layer1_ffn_gate["dims"][1])
            up_row_bytes = q8_0_row_bytes(layer1_ffn_up["dims"][0])
            up_start = tensor_pointer(
                buf, tensor_data_offset, layer1_ffn_up,
                up_row_bytes * layer1_ffn_up["dims"][1])
            down_row_bytes = q8_0_row_bytes(layer1_ffn_down["dims"][0])
            down_start = tensor_pointer(
                buf, tensor_data_offset, layer1_ffn_down,
                down_row_bytes * layer1_ffn_down["dims"][1])

            gate_outputs = np.empty(FFN_SWIGLU_WIDTH, dtype=np.float32)
            up_outputs = np.empty(FFN_SWIGLU_WIDTH, dtype=np.float32)
            swiglu_outputs = np.empty(FFN_SWIGLU_WIDTH, dtype=np.float32)
            for row in range(FFN_SWIGLU_WIDTH):
                gate_row = gate_start + row * gate_row_bytes
                up_row = up_start + row * up_row_bytes
                gate = q8_0_dot_row(buf, gate_row, ffn_activation)
                up = q8_0_dot_row(buf, up_row, ffn_activation)
                gate_outputs[row] = gate
                up_outputs[row] = up
                swiglu_outputs[row] = swiglu_scalar(gate, up)

            down_outputs = np.empty(residual_words, dtype=np.float32)
            post_ffn_residuals = np.empty(residual_words, dtype=np.float32)
            for row in range(residual_words):
                row_start = down_start + row * down_row_bytes
                down = q8_0_dot_row(buf, row_start, swiglu_outputs)
                down_outputs[row] = down
                post_ffn_residuals[row] = f32(post_attn_residual[row] + down)

            return {
                "tensor_data_offset": tensor_data_offset,
                LAYER1_FFN_GATE: layer1_ffn_gate,
                LAYER1_FFN_UP: layer1_ffn_up,
                LAYER1_FFN_DOWN: layer1_ffn_down,
                "layer1_ffn_gate_outputs": gate_outputs.copy(),
                "layer1_ffn_up_outputs": up_outputs.copy(),
                "layer1_ffn_swiglu_outputs": swiglu_outputs.copy(),
                "layer1_ffn_down_outputs": down_outputs.copy(),
                "layer1_post_ffn_residuals": post_ffn_residuals.copy(),
            }
    finally:
        os.close(fd)


def run_oracle(path, residual_words=4):
    result = run_layer1_ffn_norm_oracle(path)
    branch = load_layer1_ffn_branch(
        path,
        result["epsilon_bits"],
        result["layer1_ffn_norm_activation"],
        result["layer1_post_attn_residual"],
        residual_words,
    )

    result.update(branch)
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-1 post-FFN residual words.")
    parser.add_argument("model", help="path to the target Q8_0 GGUF model")
    parser.add_argument(
        "--residual-words", type=int, default=4,
        help="number of layer-1 down/residual words to print")
    args = parser.parse_args()

    result = run_oracle(args.model, args.residual_words)

    print(f"tensor_data_offset: {result['tensor_data_offset']}")
    print(f"attn_norm_rms_epsilon_f32_hex: "
          f"0x{result['epsilon_bits']:08x}")
    for label in (TOKEN_EMBD, ATTN_NORM, ATTN_V, ATTN_OUTPUT, FFN_NORM,
                  FFN_GATE, FFN_UP, FFN_DOWN, LAYER1_ATTN_NORM,
                  LAYER1_ATTN_V, LAYER1_ATTN_OUTPUT, LAYER1_FFN_NORM,
                  LAYER1_FFN_GATE, LAYER1_FFN_UP, LAYER1_FFN_DOWN):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["layer1_post_attn_residuals"][:4]):
        print(f"oracle_token0_layer1_post_attn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer1_ffn_norm_words"]):
        print(f"oracle_token0_layer1_ffn_norm{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer1_ffn_gate_outputs"][:4]):
        print(f"oracle_token0_layer1_ffn_gate_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer1_ffn_up_outputs"][:4]):
        print(f"oracle_token0_layer1_ffn_up_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer1_ffn_swiglu_outputs"][:4]):
        print(f"oracle_token0_layer1_ffn_swiglu_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer1_ffn_down_outputs"]):
        print(f"oracle_token0_layer1_ffn_down_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer1_post_ffn_residuals"]):
        print(f"oracle_token0_layer1_post_ffn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
