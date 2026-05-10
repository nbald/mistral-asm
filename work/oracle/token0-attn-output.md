# Token 0 Attention Output Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_attn_output*_f32_hex` smoke path for the local target GGUF.

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

Command:

```sh
python3 work/oracle/token0_attn_output_oracle.py \
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
oracle_token0_attn_context0_f32_hex: 0x3ca3b3bc
oracle_token0_attn_context1_f32_hex: 0x3c9bf3e4
oracle_token0_attn_context2_f32_hex: 0x3c29a3e4
oracle_token0_attn_context3_f32_hex: 0xbb17585e
oracle_token0_attn_output0_f32_hex: 0xbd553ed5
oracle_token0_attn_output1_f32_hex: 0xbe2c4b4d
oracle_token0_attn_output2_f32_hex: 0x3f7c2d02
oracle_token0_attn_output3_f32_hex: 0x3d799d1a
```

Comparison result: these four output words match the current assembly runtime
output for `token0_attn_output0_f32_hex` through
`token0_attn_output3_f32_hex` exactly. The context words also match the
runtime's guarded single-token context slice exactly.
