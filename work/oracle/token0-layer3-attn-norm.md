# Token 0 Layer-3 Attention RMSNorm Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_layer3_attn_norm*_f32_hex` smoke path for the local target GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script reuses the full layer-2 post-FFN residual oracle path,
then applies `blk.3.attn_norm.weight` with the same RMSNorm helper semantics
used by the assembly smoke.

The arithmetic chain checked here extends
`work/oracle/token0-layer2-post-ffn-residual.md`:

1. Compute the complete token-0 layer-2 post-FFN residual.
2. Load the full f32 `blk.3.attn_norm.weight` tensor.
3. Compute RMSNorm over all 3072 residual words using the captured
   `mistral3.attention.layer_norm_rms_epsilon` metadata value.
4. Compare the first four normalized words with the runtime exact-hex slice.

Command:

```sh
python3 work/oracle/token0_layer3_attn_norm_oracle.py \
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
blk.2.ffn_up.weight: type 8 dims 3072x9216 offset 768823296
blk.2.ffn_down.weight: type 8 dims 9216x3072 offset 708648960
blk.3.attn_norm.weight: type 0 dims 3072 offset 802246656
oracle_token0_layer2_post_ffn_residual0_f32_hex: 0x440c1d48
oracle_token0_layer2_post_ffn_residual1_f32_hex: 0xc200a8d7
oracle_token0_layer2_post_ffn_residual2_f32_hex: 0xc2a8120a
oracle_token0_layer2_post_ffn_residual3_f32_hex: 0xc15da38d
oracle_token0_layer3_attn_norm0_f32_hex: 0x41be7bcf
oracle_token0_layer3_attn_norm1_f32_hex: 0xc06721de
oracle_token0_layer3_attn_norm2_f32_hex: 0xc13cb538
oracle_token0_layer3_attn_norm3_f32_hex: 0xbfe354dc
```

Comparison result: these four layer-3 attention RMSNorm words match the
current assembly runtime output for `token0_layer3_attn_norm0_f32_hex` through
`token0_layer3_attn_norm3_f32_hex` exactly. The prerequisite layer-2 post-FFN
residual public slice also still matches exactly.
