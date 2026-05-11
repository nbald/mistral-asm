#!/usr/bin/env python3
"""External oracle for the token-0 layer-3 attention context smoke.

This file is verification tooling, not runtime source. It reuses the layer-3
attention value-projection oracle, validates the layer-3 output-projection
descriptor as a shape guard, and prints the first four context words. It does
not read blk.3.attn_output.weight payload bytes.
"""

import argparse
import mmap
import os

from token0_attn_output_oracle import CONTEXT_WIDTH, OUTPUT_WIDTH
from token0_attn_q_oracle import (
    GGML_TYPE_Q8_0,
    f32_bits,
    parse_gguf,
    require,
    require_tensor,
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
from token0_layer3_attn_v_oracle import (
    LAYER3_ATTN_V,
    run_oracle as run_layer3_attn_v_oracle,
)


LAYER3_ATTN_OUTPUT = "blk.3.attn_output.weight"
PUBLIC_OUTPUT_WORDS = 4


def load_layer3_attn_output_descriptor(path, expected_epsilon_bits):
    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            require(epsilon_bits == expected_epsilon_bits,
                    "metadata epsilon changed between oracle passes")

            layer3_attn_output = require_tensor(
                tensors, LAYER3_ATTN_OUTPUT, GGML_TYPE_Q8_0, 2)
            require(layer3_attn_output["dims"][0] == CONTEXT_WIDTH,
                    "layer-3 attention output input width mismatch")
            require(layer3_attn_output["dims"][1] == OUTPUT_WIDTH,
                    "layer-3 attention output row count mismatch")

            return tensor_data_offset, layer3_attn_output
    finally:
        os.close(fd)


def run_oracle(path):
    result = run_layer3_attn_v_oracle(path)
    tensor_data_offset, layer3_attn_output = (
        load_layer3_attn_output_descriptor(path, result["epsilon_bits"]))
    require(tensor_data_offset == result["tensor_data_offset"],
            "tensor data offset changed between oracle passes")

    # For a one-token sequence, the first query head reads the first KV head
    # directly; the first public context words are therefore the first value
    # projection words.
    context_words = result["layer3_attn_v_outputs"][:PUBLIC_OUTPUT_WORDS]

    result[LAYER3_ATTN_OUTPUT] = layer3_attn_output
    result["layer3_attn_context_words"] = context_words
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-3 attention context words.")
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
                  LAYER3_ATTN_OUTPUT):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["layer2_post_ffn_residuals"]
                                  [:PUBLIC_OUTPUT_WORDS]):
        print(f"oracle_token0_layer2_post_ffn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_attn_norm_words"]):
        print(f"oracle_token0_layer3_attn_norm{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_attn_v_outputs"]):
        print(f"oracle_token0_layer3_attn_v_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_attn_context_words"]):
        print(f"oracle_token0_layer3_attn_context{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
