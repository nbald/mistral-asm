#!/usr/bin/env python3
"""External oracle for the token-0 layer-3 FFN gate projection smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-3 FFN RMSNorm oracle path, then dots that full 3072-word activation with
the first four rows of blk.3.ffn_gate.weight using the same scalar f32 Q8_0
arithmetic order as the assembly smoke path.
"""

import argparse
import mmap
import os

from token0_attn_output_oracle import OUTPUT_WIDTH
from token0_attn_q_oracle import (
    GGML_TYPE_Q8_0,
    f32_bits,
    parse_gguf,
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
from token0_ffn_gate_oracle import FFN_GATE_OUTPUT_WIDTH
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
    q8_0_dot_row_ordered_numpy,
)
from token0_layer2_attn_v_oracle import LAYER2_ATTN_V
from token0_layer2_ffn_down_oracle import LAYER2_FFN_DOWN
from token0_layer2_ffn_gate_oracle import LAYER2_FFN_GATE
from token0_layer2_ffn_norm_oracle import LAYER2_FFN_NORM
from token0_layer2_ffn_up_oracle import LAYER2_FFN_UP
from token0_layer3_attn_norm_oracle import LAYER3_ATTN_NORM
from token0_layer3_attn_output_oracle import LAYER3_ATTN_OUTPUT
from token0_layer3_attn_v_oracle import LAYER3_ATTN_V
from token0_layer3_ffn_norm_oracle import (
    LAYER3_FFN_NORM,
    run_oracle as run_layer3_ffn_norm_oracle,
)


LAYER3_FFN_GATE = "blk.3.ffn_gate.weight"
PUBLIC_OUTPUT_WORDS = 4


def load_layer3_ffn_gate_outputs(path, expected_epsilon_bits, activation):
    require(len(activation) == OUTPUT_WIDTH,
            "layer-3 FFN RMSNorm activation width mismatch")

    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            require(epsilon_bits == expected_epsilon_bits,
                    "metadata epsilon changed between oracle passes")

            layer3_ffn_gate = require_tensor(
                tensors, LAYER3_FFN_GATE, GGML_TYPE_Q8_0, 2)
            require(layer3_ffn_gate["dims"][0] == OUTPUT_WIDTH,
                    "layer-3 FFN gate input width mismatch")
            require(layer3_ffn_gate["dims"][1] == FFN_GATE_OUTPUT_WIDTH,
                    "layer-3 FFN gate output width mismatch")

            gate_row_bytes = q8_0_row_bytes(layer3_ffn_gate["dims"][0])
            gate_start = tensor_pointer(
                buf, tensor_data_offset, layer3_ffn_gate,
                gate_row_bytes * layer3_ffn_gate["dims"][1])

            outputs = []
            for row in range(PUBLIC_OUTPUT_WORDS):
                row_start = gate_start + row * gate_row_bytes
                outputs.append(q8_0_dot_row_ordered_numpy(
                    buf, row_start, activation))

            return {
                "tensor_data_offset": tensor_data_offset,
                LAYER3_FFN_GATE: layer3_ffn_gate,
                "layer3_ffn_gate_outputs": outputs,
            }
    finally:
        os.close(fd)


def run_oracle(path):
    result = run_layer3_ffn_norm_oracle(path)
    gate = load_layer3_ffn_gate_outputs(
        path,
        result["epsilon_bits"],
        result["layer3_ffn_norm_activation"],
    )

    result.update(gate)
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-3 FFN gate words.")
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
                  LAYER3_ATTN_OUTPUT, LAYER3_FFN_NORM, LAYER3_FFN_GATE):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["layer3_attn_output_outputs"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer3_attn_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_post_attn_residuals"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer3_post_attn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_ffn_norm_words"]):
        print(f"oracle_token0_layer3_ffn_norm{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_ffn_gate_outputs"]):
        print(f"oracle_token0_layer3_ffn_gate_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
