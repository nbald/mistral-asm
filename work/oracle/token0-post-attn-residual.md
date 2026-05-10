# Token 0 Post-Attention Residual Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_post_attn_residual*_f32_hex` smoke path for the local target GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script parses GGUF metadata and tensor descriptors directly,
then reproduces the current scalar arithmetic order:

1. Dequantize token ID 0 from `token_embd.weight` Q8_0 blocks.
2. Apply `blk.0.attn_norm.weight` with
   `mistral3.attention.layer_norm_rms_epsilon`.
3. Dot the normalized activation with every row of `blk.0.attn_v.weight`.
4. Expand the 1024-value V output into the 4096-value single-token attention
   context by repeating each 128-value KV-head block four times.
5. Dot the context with the first four rows of
   `blk.0.attn_output.weight`.
6. Add the matching token embedding activation word to each attention-output
   word with f32 rounding, matching the runtime `vaddss` residual smoke.

Command:

```sh
python3 work/oracle/token0_post_attn_residual_oracle.py \
  models/unsloth-Ministral-3-3B-Instruct-2512-GGUF/Ministral-3-3B-Instruct-2512-Q8_0.gguf
```

External tool versions used:

```text
Python 3.12.3
numpy 1.26.4
```

Oracle output:

```text
tensor_data_offset: 7882016
attn_norm_rms_epsilon_f32_hex: 0x3727c5ac
token_embd.weight: type 8 dims 3072x131072 offset 12288
blk.0.attn_norm.weight: type 0 dims 3072 offset 431173632
blk.0.attn_v.weight: type 8 dims 3072x1024 offset 457924608
blk.0.attn_output.weight: type 8 dims 4096x3072 offset 431185920
oracle_token0_embedding_activation0_f32_hex: 0x3b9cc000
oracle_token0_embedding_activation1_f32_hex: 0xbcef4000
oracle_token0_embedding_activation2_f32_hex: 0x3d02f800
oracle_token0_embedding_activation3_f32_hex: 0x3ac60000
oracle_token0_attn_output0_f32_hex: 0xbd553ed5
oracle_token0_attn_output1_f32_hex: 0xbe2c4b4d
oracle_token0_attn_output2_f32_hex: 0x3f7c2d02
oracle_token0_attn_output3_f32_hex: 0x3d799d1a
oracle_token0_post_attn_residual0_f32_hex: 0xbd41a6d5
oracle_token0_post_attn_residual1_f32_hex: 0xbe4a334d
oracle_token0_post_attn_residual2_f32_hex: 0x3f822e41
oracle_token0_post_attn_residual3_f32_hex: 0x3d7fcd1a
```

Comparison result: these four residual words match the current assembly
runtime output for `token0_post_attn_residual0_f32_hex` through
`token0_post_attn_residual3_f32_hex` exactly. The attention output words also
match the runtime's guarded attention-output projection slice exactly.
