#!/usr/bin/env python3
"""External oracle for the token-0 first attention key projection smoke.

This file is verification tooling, not runtime source. It reuses the GGUF
parser and scalar f32 arithmetic helpers from the query oracle, then prints the
first four key-projection output words as raw bits.
"""

import argparse
import mmap
import os

import numpy as np

from token0_attn_q_oracle import (
    ATTN_NORM,
    GGML_TYPE_F32,
    GGML_TYPE_Q8_0,
    TOKEN_EMBD,
    dequant_q8_0_row,
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


ATTN_K = "blk.0.attn_k.weight"


def run_oracle(path):
    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            token_embd = require_tensor(tensors, TOKEN_EMBD, GGML_TYPE_Q8_0, 2)
            attn_norm = require_tensor(tensors, ATTN_NORM, GGML_TYPE_F32, 1)
            attn_k = require_tensor(tensors, ATTN_K, GGML_TYPE_Q8_0, 2)

            width = token_embd["dims"][0]
            token_rows = token_embd["dims"][1]
            require(token_rows > 0, "token embedding tensor has no rows")
            require(attn_norm["dims"][0] == width,
                    "attention RMSNorm width mismatch")
            require(attn_k["dims"][0] == width,
                    "attention key input width mismatch")
            require(attn_k["dims"][1] >= 4,
                    "attention key tensor has fewer than four rows")

            token_row_bytes = q8_0_row_bytes(width)
            token_start = tensor_pointer(buf, tensor_data_offset, token_embd,
                                         token_row_bytes * token_rows)
            norm_start = tensor_pointer(buf, tensor_data_offset, attn_norm,
                                        width * 4)
            attn_k_row_bytes = q8_0_row_bytes(attn_k["dims"][0])
            attn_k_start = tensor_pointer(buf, tensor_data_offset, attn_k,
                                          attn_k_row_bytes * attn_k["dims"][1])

            token0 = dequant_q8_0_row(buf, token_start, width)
            norm_weight = np.frombuffer(buf, dtype="<f4", count=width,
                                        offset=norm_start).copy()
            normalized = rmsnorm(token0, norm_weight, f32_from_bits(epsilon_bits))

            outputs = []
            for row in range(4):
                row_start = attn_k_start + row * attn_k_row_bytes
                outputs.append(q8_0_dot_row(buf, row_start, normalized))

            return {
                "tensor_data_offset": tensor_data_offset,
                "epsilon_bits": epsilon_bits,
                TOKEN_EMBD: token_embd,
                ATTN_NORM: attn_norm,
                ATTN_K: attn_k,
                "outputs": outputs,
            }
    finally:
        os.close(fd)


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 attention key oracle words.")
    parser.add_argument("model", help="path to the target Q8_0 GGUF model")
    args = parser.parse_args()

    result = run_oracle(args.model)

    print(f"tensor_data_offset: {result['tensor_data_offset']}")
    print(f"attn_norm_rms_epsilon_f32_hex: "
          f"0x{result['epsilon_bits']:08x}")
    for label in (TOKEN_EMBD, ATTN_NORM, ATTN_K):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["outputs"]):
        print(f"oracle_token0_attn_k_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
