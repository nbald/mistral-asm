# Token 0 Attention Query Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_attn_q_output*_f32_hex` smoke path for the local target GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script parses GGUF metadata and tensor descriptors directly,
then reproduces the current scalar arithmetic order:

1. Dequantize token ID 0 from `token_embd.weight` Q8_0 blocks.
2. Apply `blk.0.attn_norm.weight` with
   `mistral3.attention.layer_norm_rms_epsilon`.
3. Dot the normalized activation with the first four rows of
   `blk.0.attn_q.weight`.

Command:

```sh
python3 work/oracle/token0_attn_q_oracle.py \
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
blk.0.attn_q.weight: type 8 dims 3072x4096 offset 444555264
oracle_token0_attn_q_output0_f32_hex: 0xbf9945a5
oracle_token0_attn_q_output1_f32_hex: 0xbf0612bc
oracle_token0_attn_q_output2_f32_hex: 0xbe09ed5f
oracle_token0_attn_q_output3_f32_hex: 0xbf155e8e
```

Comparison result: these four words match the current assembly runtime output
for `token0_attn_q_output0_f32_hex` through
`token0_attn_q_output3_f32_hex` exactly.
