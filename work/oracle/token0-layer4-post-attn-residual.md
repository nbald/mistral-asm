# Token 0 Layer-4 Post-Attention Residual Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_layer4_post_attn_residual*_f32_hex` smoke path for the local target
GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script reuses the layer-4 attention output oracle path and
then adds the first four layer-3 post-FFN residual words to the first four
layer-4 attention output words with the same scalar f32 rounding used by the
assembly smoke path.

The arithmetic chain checked here extends
`work/oracle/token0-layer4-attn-output.md`:

1. Compute the complete token-0 layer-3 post-FFN residual.
2. Apply `blk.4.attn_norm.weight` to compute the full token-0 layer-4
   attention RMSNorm activation.
3. Dot the layer-4 normalized activation with every row of
   `blk.4.attn_v.weight`.
4. Expand the single-token grouped-query context from the full value output.
5. Dot that 4096-word context with the first four rows of
   `blk.4.attn_output.weight`.
6. Add the first four layer-3 post-FFN residual and layer-4 attention output
   words with f32 rounding.

Command:

```sh
python3 work/oracle/token0_layer4_post_attn_residual_oracle.py \
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
blk.4.attn_k.weight: type 8 dims 3072x1024 offset 922595328
blk.4.attn_v.weight: type 8 dims 3072x1024 offset 952688640
blk.4.attn_output.weight: type 8 dims 4096x3072 offset 925949952
oracle_token0_layer3_post_ffn_residual0_f32_hex: 0x440c2692
oracle_token0_layer3_post_ffn_residual1_f32_hex: 0xc1ff9359
oracle_token0_layer3_post_ffn_residual2_f32_hex: 0xc2a96a19
oracle_token0_layer3_post_ffn_residual3_f32_hex: 0xc15e5fea
oracle_token0_layer4_attn_output0_f32_hex: 0x3cfe6cdc
oracle_token0_layer4_attn_output1_f32_hex: 0x3e2382d0
oracle_token0_layer4_attn_output2_f32_hex: 0xbd9ca89f
oracle_token0_layer4_attn_output3_f32_hex: 0xbd9a5c81
oracle_token0_layer4_post_attn_residual0_f32_hex: 0x440c288f
oracle_token0_layer4_post_attn_residual1_f32_hex: 0xc1fe4c53
oracle_token0_layer4_post_attn_residual2_f32_hex: 0xc2a99143
oracle_token0_layer4_post_attn_residual3_f32_hex: 0xc15f94a3
```

Comparison result: these four layer-4 post-attention residual words match the
current assembly runtime output for
`token0_layer4_post_attn_residual0_f32_hex` through
`token0_layer4_post_attn_residual3_f32_hex` exactly. The prerequisite layer-3
post-FFN residual and layer-4 attention output public slices also still match
exactly.
