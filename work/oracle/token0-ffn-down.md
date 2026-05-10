# Token 0 FFN Down Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_ffn_down_output*_f32_hex` smoke path for the local target GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script parses GGUF metadata and tensor descriptors directly,
then reproduces the current scalar arithmetic order:

1. Dequantize token ID 0 from `token_embd.weight` Q8_0 blocks.
2. Apply `blk.0.attn_norm.weight` with
   `mistral3.attention.layer_norm_rms_epsilon`.
3. Dot the normalized activation with every row of `blk.0.attn_v.weight`.
4. Expand the 1024-value V output into the 4096-value single-token attention
   context by repeating each 128-value KV-head block four times.
5. Dot the context with all 3072 rows of `blk.0.attn_output.weight`.
6. Add each token embedding activation word to its attention-output word with
   f32 rounding, matching the runtime `vaddss` residual smoke.
7. Apply `blk.0.ffn_norm.weight` to the full 3072-word residual with the same
   RMSNorm epsilon and scalar f32 accumulation order as `rmsnorm_f32`.
8. Dot the resulting FFN-normalized activation with all 9216 rows of both
   `blk.0.ffn_gate.weight` and `blk.0.ffn_up.weight`.
9. Compute the full 9216-word SwiGLU activation as `silu(gate[i]) * up[i]`.
10. Dot that full activation with the first four rows of
    `blk.0.ffn_down.weight`.

Command:

```sh
python3 work/oracle/token0_ffn_down_oracle.py \
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
oracle_token0_ffn_norm0_f32_hex: 0xc01a392c
oracle_token0_ffn_norm1_f32_hex: 0xc116e478
oracle_token0_ffn_norm2_f32_hex: 0x416e11b8
oracle_token0_ffn_norm3_f32_hex: 0x3fe0d866
oracle_token0_ffn_gate_output0_f32_hex: 0xbf5c7417
oracle_token0_ffn_gate_output1_f32_hex: 0xbfa9b30c
oracle_token0_ffn_gate_output2_f32_hex: 0xbfecdf2f
oracle_token0_ffn_gate_output3_f32_hex: 0xbfa6fe18
oracle_token0_ffn_up_output0_f32_hex: 0x3f641d75
oracle_token0_ffn_up_output1_f32_hex: 0x3f60c9d6
oracle_token0_ffn_up_output2_f32_hex: 0x3f65a149
oracle_token0_ffn_up_output3_f32_hex: 0x3f1ee2f1
oracle_token0_ffn_swiglu_output0_f32_hex: 0xbe697324
oracle_token0_ffn_swiglu_output1_f32_hex: 0xbe7a2af9
oracle_token0_ffn_swiglu_output2_f32_hex: 0xbe66d77d
oracle_token0_ffn_swiglu_output3_f32_hex: 0xbe30ee21
oracle_token0_ffn_down_output0_f32_hex: 0xbde9febc
oracle_token0_ffn_down_output1_f32_hex: 0xbec5ccf0
oracle_token0_ffn_down_output2_f32_hex: 0x3ffe1c83
oracle_token0_ffn_down_output3_f32_hex: 0xbe862464
```

Comparison result: these four FFN down projection words match the current
assembly runtime output for `token0_ffn_down_output0_f32_hex` through
`token0_ffn_down_output3_f32_hex` exactly. The intermediate FFN RMSNorm, gate
projection, up projection, and SwiGLU activation words also match the runtime's
guarded public slices exactly.
