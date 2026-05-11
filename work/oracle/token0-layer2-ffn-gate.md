# Token 0 Layer-2 FFN Gate Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_layer2_ffn_gate_output*_f32_hex` smoke path for the local target GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script reuses the full layer-2 FFN RMSNorm oracle path, then
dots the resulting 3072-word activation with the first four rows of
`blk.2.ffn_gate.weight` using the same scalar f32 Q8_0 accumulation order as
the runtime `q8_0_matvec_f32` helper.

The arithmetic chain checked here extends
`work/oracle/token0-layer2-ffn-norm.md`:

1. Compute the full upstream layer-1 post-FFN residual.
2. Apply `blk.2.attn_norm.weight` to that residual.
3. Compute all 1024 rows of `blk.2.attn_v.weight`.
4. Expand the one-token grouped-query context to 4096 f32 values.
5. Dot the context with all 3072 rows of `blk.2.attn_output.weight`.
6. Add all layer-1 post-FFN residual and layer-2 attention output words with
   f32 rounding.
7. Apply `blk.2.ffn_norm.weight` to the full layer-2 post-attention residual.
8. Dot the FFN-normalized activation with the first four rows of
   `blk.2.ffn_gate.weight`.

Command:

```sh
python3 work/oracle/token0_layer2_ffn_gate_oracle.py \
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
blk.1.attn_norm.weight: type 0 dims 3072 offset 554864640
blk.1.attn_v.weight: type 8 dims 3072x1024 offset 581615616
blk.1.attn_output.weight: type 8 dims 4096x3072 offset 554876928
blk.1.ffn_norm.weight: type 0 dims 3072 offset 645120000
blk.1.ffn_gate.weight: type 8 dims 3072x9216 offset 615038976
blk.1.ffn_up.weight: type 8 dims 3072x9216 offset 645132288
blk.1.ffn_down.weight: type 8 dims 9216x3072 offset 584957952
blk.2.attn_norm.weight: type 0 dims 3072 offset 678555648
blk.2.attn_v.weight: type 8 dims 3072x1024 offset 705306624
blk.2.attn_output.weight: type 8 dims 4096x3072 offset 678567936
blk.2.ffn_norm.weight: type 0 dims 3072 offset 768811008
blk.2.ffn_gate.weight: type 8 dims 3072x9216 offset 738729984
oracle_token0_layer2_ffn_norm0_f32_hex: 0x40522d9d
oracle_token0_layer2_ffn_norm1_f32_hex: 0xbf5d5852
oracle_token0_layer2_ffn_norm2_f32_hex: 0x3fc92f4e
oracle_token0_layer2_ffn_norm3_f32_hex: 0x3f3f5579
oracle_token0_layer2_ffn_gate_output0_f32_hex: 0x4204511d
oracle_token0_layer2_ffn_gate_output1_f32_hex: 0xbfebf5bb
oracle_token0_layer2_ffn_gate_output2_f32_hex: 0x414216d1
oracle_token0_layer2_ffn_gate_output3_f32_hex: 0x3f72ec48
```

Comparison result: these four layer-2 FFN gate words match the current assembly
runtime output for `token0_layer2_ffn_gate_output0_f32_hex` through
`token0_layer2_ffn_gate_output3_f32_hex` exactly. The prerequisite layer-2 FFN
RMSNorm public slice also still matches exactly.
