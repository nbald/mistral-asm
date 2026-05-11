# Token 0 Layer-3 Post-FFN Residual Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_layer3_post_ffn_residual*_f32_hex` smoke path for the local target
GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script reuses the full layer-3 FFN down oracle path, then
adds the first four layer-3 post-attention residual words to the first four
layer-3 FFN down output words with f32 rounding.

The arithmetic chain checked here extends
`work/oracle/token0-layer3-ffn-down.md`:

1. Compute the complete token-0 layer-3 post-attention residual.
2. Compute the complete token-0 layer-3 FFN RMSNorm activation.
3. Dot that activation with every row of `blk.3.ffn_gate.weight`.
4. Dot that activation with every row of `blk.3.ffn_up.weight`.
5. Compute the complete layer-3 FFN SwiGLU activation.
6. Dot the SwiGLU activation with the first four rows of
   `blk.3.ffn_down.weight`.
7. Add the first four layer-3 post-attention residual and FFN down words with
   f32 rounding.

Command:

```sh
python3 work/oracle/token0_layer3_post_ffn_residual_oracle.py \
  models/unsloth-Ministral-3-3B-Instruct-2512-GGUF/Ministral-3-3B-Instruct-2512-Q8_0.gguf
```

External tool versions used:

```text
Python 3.12.3
numpy 1.26.4
```

Relevant oracle output:

```text
oracle_token0_layer3_post_attn_residual0_f32_hex: 0x440c1f18
oracle_token0_layer3_post_attn_residual1_f32_hex: 0xc20054b6
oracle_token0_layer3_post_attn_residual2_f32_hex: 0xc2a825d4
oracle_token0_layer3_post_attn_residual3_f32_hex: 0xc15e3502
oracle_token0_layer3_ffn_down_output0_f32_hex: 0x3def4ab2
oracle_token0_layer3_ffn_down_output1_f32_hex: 0x3e0b094a
oracle_token0_layer3_ffn_down_output2_f32_hex: 0xbf222273
oracle_token0_layer3_ffn_down_output3_f32_hex: 0xbc2b9ed5
oracle_token0_layer3_post_ffn_residual0_f32_hex: 0x440c2692
oracle_token0_layer3_post_ffn_residual1_f32_hex: 0xc1ff9359
oracle_token0_layer3_post_ffn_residual2_f32_hex: 0xc2a96a19
oracle_token0_layer3_post_ffn_residual3_f32_hex: 0xc15e5fea
```

Comparison result: these four layer-3 post-FFN residual words match the
current assembly runtime output for
`token0_layer3_post_ffn_residual0_f32_hex` through
`token0_layer3_post_ffn_residual3_f32_hex` exactly. The prerequisite
layer-3 post-attention residual and layer-3 FFN public slices also still match
exactly.
