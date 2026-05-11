#!/usr/bin/env python3
"""External oracle for the token-0 layer-2 FFN SwiGLU activation smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-2 FFN RMSNorm, gate projection, and up projection oracle paths, then
applies silu(gate[i]) * up[i] for the first four activation words.
"""

import argparse

from token0_attn_q_oracle import f32_bits, require
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
from token0_ffn_swiglu_oracle import swiglu_scalar
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
from token0_layer2_ffn_gate_oracle import (
    LAYER2_FFN_GATE,
    load_layer2_ffn_gate_outputs,
)
from token0_layer2_ffn_norm_oracle import (
    LAYER2_FFN_NORM,
    run_oracle as run_layer2_ffn_norm_oracle,
)
from token0_layer2_ffn_up_oracle import (
    LAYER2_FFN_UP,
    load_layer2_ffn_up_outputs,
)


def run_oracle(path):
    result = run_layer2_ffn_norm_oracle(path)
    gate_data_offset, layer2_ffn_gate, gate_outputs = (
        load_layer2_ffn_gate_outputs(
            path,
            result["epsilon_bits"],
            result["layer2_ffn_norm_activation"],
        )
    )
    up_data_offset, layer2_ffn_up, up_outputs = (
        load_layer2_ffn_up_outputs(
            path,
            result["epsilon_bits"],
            result["layer2_ffn_norm_activation"],
        )
    )
    require(gate_data_offset == up_data_offset,
            "layer-2 FFN gate/up oracle tensor-data offsets disagree")
    require(len(gate_outputs) == len(up_outputs),
            "layer-2 FFN gate/up public output counts disagree")

    swiglu_outputs = [
        swiglu_scalar(gate, up)
        for gate, up in zip(gate_outputs, up_outputs)
    ]

    result["tensor_data_offset"] = gate_data_offset
    result[LAYER2_FFN_GATE] = layer2_ffn_gate
    result[LAYER2_FFN_UP] = layer2_ffn_up
    result["layer2_ffn_gate_outputs"] = gate_outputs
    result["layer2_ffn_up_outputs"] = up_outputs
    result["layer2_ffn_swiglu_outputs"] = swiglu_outputs
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-2 FFN SwiGLU words.")
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
                  LAYER2_FFN_NORM, LAYER2_FFN_GATE, LAYER2_FFN_UP):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["layer2_ffn_norm_words"]):
        print(f"oracle_token0_layer2_ffn_norm{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer2_ffn_gate_outputs"]):
        print(f"oracle_token0_layer2_ffn_gate_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer2_ffn_up_outputs"]):
        print(f"oracle_token0_layer2_ffn_up_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer2_ffn_swiglu_outputs"]):
        print(f"oracle_token0_layer2_ffn_swiglu_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
