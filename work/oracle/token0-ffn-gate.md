# Token 0 FFN Gate Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_ffn_gate_output*_f32_hex` smoke path for the local target GGUF.

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
8. Dot the resulting FFN-normalized activation with the first four rows of
   `blk.0.ffn_gate.weight`.

Command:

```sh
python3 work/oracle/token0_ffn_gate_oracle.py \
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
oracle_token0_ffn_norm0_f32_hex: 0xc01a392c
oracle_token0_ffn_norm1_f32_hex: 0xc116e478
oracle_token0_ffn_norm2_f32_hex: 0x416e11b8
oracle_token0_ffn_norm3_f32_hex: 0x3fe0d866
oracle_token0_ffn_gate_output0_f32_hex: 0xbf5c7417
oracle_token0_ffn_gate_output1_f32_hex: 0xbfa9b30c
oracle_token0_ffn_gate_output2_f32_hex: 0xbfecdf2f
oracle_token0_ffn_gate_output3_f32_hex: 0xbfa6fe18
```

Comparison result: these four FFN gate projection words match the current
assembly runtime output for `token0_ffn_gate_output0_f32_hex` through
`token0_ffn_gate_output3_f32_hex` exactly. The intermediate FFN RMSNorm words
also match the runtime's guarded FFN norm slice exactly.
