# Token 0 Post-FFN Residual Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_post_ffn_residual*_f32_hex` smoke path for the local target GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script reuses the full scalar FFN down oracle path, then
adds the first four post-attention residual words to the first four FFN down
output words with f32 rounding. That matches the runtime's scalar `vaddss`
residual smoke.

The arithmetic chain checked here is:

1. Dequantize token ID 0 from `token_embd.weight` Q8_0 blocks.
2. Apply `blk.0.attn_norm.weight` with
   `mistral3.attention.layer_norm_rms_epsilon`.
3. Dot the normalized activation with every row of `blk.0.attn_v.weight`.
4. Expand the 1024-value V output into the 4096-value single-token attention
   context by repeating each 128-value KV-head block four times.
5. Dot the context with all 3072 rows of `blk.0.attn_output.weight`.
6. Add each token embedding activation word to its attention-output word with
   f32 rounding, matching the runtime post-attention residual smoke.
7. Apply `blk.0.ffn_norm.weight` to the full 3072-word residual.
8. Dot the FFN-normalized activation with all 9216 rows of both
   `blk.0.ffn_gate.weight` and `blk.0.ffn_up.weight`.
9. Compute the full 9216-word SwiGLU activation as `silu(gate[i]) * up[i]`.
10. Dot that activation with the first four rows of `blk.0.ffn_down.weight`.
11. Add the first four post-attention residual and FFN down words with f32
    rounding.

Command:

```sh
python3 work/oracle/token0_post_ffn_residual_oracle.py \
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
blk.0.ffn_norm.weight: type 0 dims 3072 offset 521428992
blk.0.ffn_gate.weight: type 8 dims 3072x9216 offset 491347968
blk.0.ffn_up.weight: type 8 dims 3072x9216 offset 521441280
blk.0.ffn_down.weight: type 8 dims 9216x3072 offset 461266944
oracle_token0_post_attn_residual0_f32_hex: 0xbd41a6d5
oracle_token0_post_attn_residual1_f32_hex: 0xbe4a334d
oracle_token0_post_attn_residual2_f32_hex: 0x3f822e41
oracle_token0_post_attn_residual3_f32_hex: 0x3d7fcd1a
oracle_token0_ffn_down_output0_f32_hex: 0xbde9febc
oracle_token0_ffn_down_output1_f32_hex: 0xbec5ccf0
oracle_token0_ffn_down_output2_f32_hex: 0x3ffe1c83
oracle_token0_ffn_down_output3_f32_hex: 0xbe862464
oracle_token0_post_ffn_residual0_f32_hex: 0xbe256913
oracle_token0_post_ffn_residual1_f32_hex: 0xbf15734b
oracle_token0_post_ffn_residual2_f32_hex: 0x40402562
oracle_token0_post_ffn_residual3_f32_hex: 0xbe4c5582
```

Comparison result: these four post-FFN residual words match the current
assembly runtime output for `token0_post_ffn_residual0_f32_hex` through
`token0_post_ffn_residual3_f32_hex` exactly. The input post-attention residual
and FFN down words also match the runtime's guarded public slices exactly.
