#!/usr/bin/env python3
"""External oracle for the token-0 layer-3 FFN SwiGLU activation smoke.

This file is verification tooling, not runtime source. It reuses the external
layer-3 FFN RMSNorm oracle path plus the focused layer-3 FFN gate/up projection
loaders, then applies silu(gate[i]) * up[i] for the first four activation
words.
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
from token0_layer2_ffn_down_oracle import LAYER2_FFN_DOWN
from token0_layer2_ffn_gate_oracle import LAYER2_FFN_GATE
from token0_layer2_ffn_norm_oracle import LAYER2_FFN_NORM
from token0_layer2_ffn_up_oracle import LAYER2_FFN_UP
from token0_layer3_attn_norm_oracle import LAYER3_ATTN_NORM
from token0_layer3_attn_output_oracle import LAYER3_ATTN_OUTPUT
from token0_layer3_attn_v_oracle import LAYER3_ATTN_V
from token0_layer3_ffn_gate_oracle import (
    LAYER3_FFN_GATE,
    load_layer3_ffn_gate_outputs,
)
from token0_layer3_ffn_norm_oracle import (
    LAYER3_FFN_NORM,
    run_oracle as run_layer3_ffn_norm_oracle,
)
from token0_layer3_ffn_up_oracle import (
    LAYER3_FFN_UP,
    load_layer3_ffn_up_outputs,
)


def run_oracle(path):
    result = run_layer3_ffn_norm_oracle(path)
    gate = load_layer3_ffn_gate_outputs(
        path,
        result["epsilon_bits"],
        result["layer3_ffn_norm_activation"],
    )
    up = load_layer3_ffn_up_outputs(
        path,
        result["epsilon_bits"],
        result["layer3_ffn_norm_activation"],
    )
    require(gate["tensor_data_offset"] == up["tensor_data_offset"],
            "layer-3 FFN gate/up oracle tensor-data offsets disagree")
    require(len(gate["layer3_ffn_gate_outputs"]) ==
            len(up["layer3_ffn_up_outputs"]),
            "layer-3 FFN gate/up public output counts disagree")

    swiglu_outputs = [
        swiglu_scalar(gate_value, up_value)
        for gate_value, up_value in zip(
            gate["layer3_ffn_gate_outputs"],
            up["layer3_ffn_up_outputs"],
        )
    ]

    result["tensor_data_offset"] = gate["tensor_data_offset"]
    result[LAYER3_FFN_GATE] = gate[LAYER3_FFN_GATE]
    result[LAYER3_FFN_UP] = up[LAYER3_FFN_UP]
    result["layer3_ffn_gate_outputs"] = gate["layer3_ffn_gate_outputs"]
    result["layer3_ffn_up_outputs"] = up["layer3_ffn_up_outputs"]
    result["layer3_ffn_swiglu_outputs"] = swiglu_outputs
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 layer-3 FFN SwiGLU words.")
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
                  LAYER3_FFN_UP):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["layer3_attn_output_outputs"][:4]):
        print(f"oracle_token0_layer3_attn_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_post_attn_residuals"][:4]):
        print(f"oracle_token0_layer3_post_attn_residual{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_ffn_norm_words"]):
        print(f"oracle_token0_layer3_ffn_norm{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_ffn_gate_outputs"]):
        print(f"oracle_token0_layer3_ffn_gate_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_ffn_up_outputs"]):
        print(f"oracle_token0_layer3_ffn_up_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")
    for index, value in enumerate(result["layer3_ffn_swiglu_outputs"]):
        print(f"oracle_token0_layer3_ffn_swiglu_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
