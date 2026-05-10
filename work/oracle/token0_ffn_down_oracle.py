#!/usr/bin/env python3
"""External oracle for the token-0 first FFN down projection smoke.

This file is verification tooling, not runtime source. It parses the target
GGUF directly, reproduces the scalar f32 arithmetic order used by the assembly
path through the full first-layer FFN SwiGLU activation, then dots that
activation with the first four rows of blk.0.ffn_down.weight.
"""

import argparse
import mmap
import os

import numpy as np

from token0_attn_output_oracle import (
    ATTN_OUTPUT,
    ATTN_V,
    CONTEXT_WIDTH,
    OUTPUT_WIDTH,
    VALUE_OUTPUT_WIDTH,
    expand_single_token_context,
)
from token0_attn_q_oracle import (
    ATTN_NORM,
    GGML_TYPE_F32,
    GGML_TYPE_Q8_0,
    TOKEN_EMBD,
    dequant_q8_0_row,
    f32,
    f32_bits,
    f32_from_bits,
    parse_gguf,
    q8_0_dot_row,
    q8_0_row_bytes,
    require,
    require_tensor,
    rmsnorm,
    tensor_pointer,
)
from token0_ffn_gate_oracle import FFN_GATE, FFN_GATE_OUTPUT_WIDTH
from token0_ffn_norm_oracle import FFN_NORM
from token0_ffn_swiglu_oracle import (
    FFN_DOWN,
    FFN_SWIGLU_WIDTH,
    swiglu_scalar,
)
from token0_ffn_up_oracle import FFN_UP, FFN_UP_OUTPUT_WIDTH


def run_oracle(path, down_rows=4):
    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            token_embd = require_tensor(tensors, TOKEN_EMBD, GGML_TYPE_Q8_0, 2)
            attn_norm = require_tensor(tensors, ATTN_NORM, GGML_TYPE_F32, 1)
            attn_v = require_tensor(tensors, ATTN_V, GGML_TYPE_Q8_0, 2)
            attn_output = require_tensor(
                tensors, ATTN_OUTPUT, GGML_TYPE_Q8_0, 2)
            ffn_norm = require_tensor(tensors, FFN_NORM, GGML_TYPE_F32, 1)
            ffn_gate = require_tensor(tensors, FFN_GATE, GGML_TYPE_Q8_0, 2)
            ffn_up = require_tensor(tensors, FFN_UP, GGML_TYPE_Q8_0, 2)
            ffn_down = require_tensor(tensors, FFN_DOWN, GGML_TYPE_Q8_0, 2)

            width = token_embd["dims"][0]
            token_rows = token_embd["dims"][1]
            require(token_rows > 0, "token embedding tensor has no rows")
            require(width == OUTPUT_WIDTH, "token embedding width mismatch")
            require(attn_norm["dims"][0] == width,
                    "attention RMSNorm width mismatch")
            require(attn_v["dims"][0] == width,
                    "attention value input width mismatch")
            require(attn_v["dims"][1] == VALUE_OUTPUT_WIDTH,
                    "attention value output width mismatch")
            require(attn_output["dims"][0] == CONTEXT_WIDTH,
                    "attention output input width mismatch")
            require(attn_output["dims"][1] == OUTPUT_WIDTH,
                    "attention output row count mismatch")
            require(ffn_norm["dims"][0] == OUTPUT_WIDTH,
                    "FFN RMSNorm width mismatch")
            require(ffn_gate["dims"][0] == OUTPUT_WIDTH,
                    "FFN gate input width mismatch")
            require(ffn_gate["dims"][1] == FFN_GATE_OUTPUT_WIDTH,
                    "FFN gate output width mismatch")
            require(ffn_up["dims"][0] == OUTPUT_WIDTH,
                    "FFN up input width mismatch")
            require(ffn_up["dims"][1] == FFN_UP_OUTPUT_WIDTH,
                    "FFN up output width mismatch")
            require(ffn_gate["dims"][1] == FFN_SWIGLU_WIDTH,
                    "FFN gate SwiGLU width mismatch")
            require(ffn_up["dims"][1] == FFN_SWIGLU_WIDTH,
                    "FFN up SwiGLU width mismatch")
            require(ffn_down["dims"][0] == FFN_SWIGLU_WIDTH,
                    "FFN down input width mismatch")
            require(ffn_down["dims"][1] == OUTPUT_WIDTH,
                    "FFN down output width mismatch")
            require(0 <= down_rows <= OUTPUT_WIDTH,
                    "requested FFN down row count outside output width")

            token_row_bytes = q8_0_row_bytes(width)
            token_start = tensor_pointer(buf, tensor_data_offset, token_embd,
                                         token_row_bytes * token_rows)
            norm_start = tensor_pointer(buf, tensor_data_offset, attn_norm,
                                        width * 4)
            attn_v_row_bytes = q8_0_row_bytes(attn_v["dims"][0])
            attn_v_start = tensor_pointer(buf, tensor_data_offset, attn_v,
                                          attn_v_row_bytes * attn_v["dims"][1])
            attn_output_row_bytes = q8_0_row_bytes(attn_output["dims"][0])
            attn_output_start = tensor_pointer(
                buf, tensor_data_offset, attn_output,
                attn_output_row_bytes * attn_output["dims"][1])
            ffn_norm_start = tensor_pointer(buf, tensor_data_offset, ffn_norm,
                                            OUTPUT_WIDTH * 4)
            ffn_gate_row_bytes = q8_0_row_bytes(ffn_gate["dims"][0])
            ffn_gate_start = tensor_pointer(
                buf, tensor_data_offset, ffn_gate,
                ffn_gate_row_bytes * ffn_gate["dims"][1])
            ffn_up_row_bytes = q8_0_row_bytes(ffn_up["dims"][0])
            ffn_up_start = tensor_pointer(
                buf, tensor_data_offset, ffn_up,
                ffn_up_row_bytes * ffn_up["dims"][1])
            ffn_down_row_bytes = q8_0_row_bytes(ffn_down["dims"][0])
            ffn_down_start = tensor_pointer(
                buf, tensor_data_offset, ffn_down,
                ffn_down_row_bytes * ffn_down["dims"][1])

            token0 = dequant_q8_0_row(buf, token_start, width)
            attn_norm_weight = np.frombuffer(
                buf, dtype="<f4", count=width, offset=norm_start).copy()
            normalized = rmsnorm(token0, attn_norm_weight,
                                 f32_from_bits(epsilon_bits))

            value_output = np.empty(VALUE_OUTPUT_WIDTH, dtype=np.float32)
            for row in range(VALUE_OUTPUT_WIDTH):
                row_start = attn_v_start + row * attn_v_row_bytes
                value_output[row] = q8_0_dot_row(buf, row_start, normalized)

            context = expand_single_token_context(value_output)

            post_attn_residual = np.empty(OUTPUT_WIDTH, dtype=np.float32)
            for row in range(OUTPUT_WIDTH):
                row_start = attn_output_start + row * attn_output_row_bytes
                attention_output = q8_0_dot_row(buf, row_start, context)
                post_attn_residual[row] = f32(token0[row] + attention_output)

            ffn_norm_weight = np.frombuffer(
                buf, dtype="<f4", count=OUTPUT_WIDTH,
                offset=ffn_norm_start).copy()
            ffn_norm_output = rmsnorm(post_attn_residual, ffn_norm_weight,
                                      f32_from_bits(epsilon_bits))

            gate_outputs = np.empty(FFN_SWIGLU_WIDTH, dtype=np.float32)
            up_outputs = np.empty(FFN_SWIGLU_WIDTH, dtype=np.float32)
            swiglu_outputs = np.empty(FFN_SWIGLU_WIDTH, dtype=np.float32)
            for row in range(FFN_SWIGLU_WIDTH):
                gate_row = ffn_gate_start + row * ffn_gate_row_bytes
                up_row = ffn_up_start + row * ffn_up_row_bytes
                gate = q8_0_dot_row(buf, gate_row, ffn_norm_output)
                up = q8_0_dot_row(buf, up_row, ffn_norm_output)
                gate_outputs[row] = gate
                up_outputs[row] = up
                swiglu_outputs[row] = swiglu_scalar(gate, up)

            down_outputs = []
            for row in range(down_rows):
                row_start = ffn_down_start + row * ffn_down_row_bytes
                down_outputs.append(q8_0_dot_row(buf, row_start,
                                                 swiglu_outputs))

            return {
                "tensor_data_offset": tensor_data_offset,
                "epsilon_bits": epsilon_bits,
                TOKEN_EMBD: token_embd,
                ATTN_NORM: attn_norm,
                ATTN_V: attn_v,
                ATTN_OUTPUT: attn_output,
                FFN_NORM: ffn_norm,
                FFN_GATE: ffn_gate,
                FFN_UP: ffn_up,
                FFN_DOWN: ffn_down,
                "post_attn_residual": post_attn_residual.copy(),
                "post_attn_residual_words": post_attn_residual[:4].copy(),
                "ffn_norm_words": ffn_norm_output[:4].copy(),
                "gate_outputs": gate_outputs[:4].copy(),
                "up_outputs": up_outputs[:4].copy(),
                "swiglu_outputs": swiglu_outputs[:4].copy(),
                "down_outputs": down_outputs,
            }
    finally:
        os.close(fd)


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 FFN down oracle words.")
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
    for index, value in enumerate(result["ffn_norm_words"]):
        print(f"oracle_token0_ffn_norm{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["gate_outputs"]):
        print(f"oracle_token0_ffn_gate_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["up_outputs"]):
        print(f"oracle_token0_ffn_up_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["swiglu_outputs"]):
        print(f"oracle_token0_ffn_swiglu_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["down_outputs"]):
        print(f"oracle_token0_ffn_down_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
