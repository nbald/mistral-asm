# Token 0 Layer-4 Attention Query Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_layer4_attn_q_output*_f32_hex` smoke path for the local target GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script reuses the full layer-4 attention RMSNorm oracle path,
then dots the resulting 3072-word activation with the first four rows of
`blk.4.attn_q.weight` using the same scalar f32 Q8_0 accumulation order as
`q8_0_matvec_f32`.

The arithmetic chain checked here extends
`work/oracle/token0-layer4-attn-norm.md`:

1. Compute the complete token-0 layer-3 post-FFN residual.
2. Apply `blk.4.attn_norm.weight` to compute the full token-0 layer-4
   attention RMSNorm activation.
3. Dot the layer-4 normalized activation with the first four rows of
   `blk.4.attn_q.weight`.

Command:

```sh
python3 work/oracle/token0_layer4_attn_q_oracle.py \
  models/unsloth-Ministral-3-3B-Instruct-2512-GGUF/Ministral-3-3B-Instruct-2512-Q8_0.gguf
```

External tool versions used:

```text
Python 3.12.3
numpy 1.26.4
```

Relevant oracle output:

```text
tensor_data_offset: 7882016
attn_norm_rms_epsilon_f32_hex: 0x3727c5ac
blk.3.ffn_down.weight: type 8 dims 9216x3072 offset 832339968
blk.4.attn_norm.weight: type 0 dims 3072 offset 925937664
blk.4.attn_q.weight: type 8 dims 3072x4096 offset 939319296
oracle_token0_layer3_post_ffn_residual0_f32_hex: 0x440c2692
oracle_token0_layer3_post_ffn_residual1_f32_hex: 0xc1ff9359
oracle_token0_layer3_post_ffn_residual2_f32_hex: 0xc2a96a19
oracle_token0_layer3_post_ffn_residual3_f32_hex: 0xc15e5fea
oracle_token0_layer4_attn_norm0_f32_hex: 0x420c4b32
oracle_token0_layer4_attn_norm1_f32_hex: 0xc0768887
oracle_token0_layer4_attn_norm2_f32_hex: 0xc14b813f
oracle_token0_layer4_attn_norm3_f32_hex: 0xbffefae6
oracle_token0_layer4_attn_q_output0_f32_hex: 0xbe996fc1
oracle_token0_layer4_attn_q_output1_f32_hex: 0xbefb10d3
oracle_token0_layer4_attn_q_output2_f32_hex: 0x3f524ef6
oracle_token0_layer4_attn_q_output3_f32_hex: 0x3ea056cc
```

Comparison result: these four layer-4 attention query words match the current
assembly runtime output for `token0_layer4_attn_q_output0_f32_hex` through
`token0_layer4_attn_q_output3_f32_hex` exactly. The prerequisite layer-3
post-FFN residual and layer-4 attention RMSNorm public slices also still match
exactly.
