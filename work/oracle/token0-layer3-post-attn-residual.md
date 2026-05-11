# Token 0 Layer-3 Post-Attention Residual Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_layer3_post_attn_residual*_f32_hex` smoke path for the local target
GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script recomputes the layer-3 attention output projection
and then adds the first four layer-2 post-FFN residual words to the first four
layer-3 attention output words with the same scalar f32 rounding used by the
assembly smoke path.

The arithmetic chain checked here extends
`work/oracle/token0-layer3-attn-output.md`:

1. Compute the complete token-0 layer-2 post-FFN residual.
2. Apply `blk.3.attn_norm.weight` to compute the full token-0 layer-3
   attention RMSNorm activation.
3. Dot the layer-3 normalized activation with every row of
   `blk.3.attn_v.weight`.
4. Expand the single-token grouped-query context from the full value output.
5. Dot that 4096-word context with the first four rows of
   `blk.3.attn_output.weight`.
6. Add the first four layer-2 post-FFN residual and layer-3 attention output
   words with f32 rounding.

Command:

```sh
python3 work/oracle/token0_layer3_post_attn_residual_oracle.py \
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
blk.3.attn_v.weight: type 8 dims 3072x1024 offset 828997632
blk.3.attn_output.weight: type 8 dims 4096x3072 offset 802258944
oracle_token0_layer2_post_ffn_residual0_f32_hex: 0x440c1d48
oracle_token0_layer2_post_ffn_residual1_f32_hex: 0xc200a8d7
oracle_token0_layer2_post_ffn_residual2_f32_hex: 0xc2a8120a
oracle_token0_layer2_post_ffn_residual3_f32_hex: 0xc15da38d
oracle_token0_layer3_attn_output0_f32_hex: 0x3ce80ee7
oracle_token0_layer3_attn_output1_f32_hex: 0x3da84154
oracle_token0_layer3_attn_output2_f32_hex: 0xbd1e4c02
oracle_token0_layer3_attn_output3_f32_hex: 0xbd11752d
oracle_token0_layer3_post_attn_residual0_f32_hex: 0x440c1f18
oracle_token0_layer3_post_attn_residual1_f32_hex: 0xc20054b6
oracle_token0_layer3_post_attn_residual2_f32_hex: 0xc2a825d4
oracle_token0_layer3_post_attn_residual3_f32_hex: 0xc15e3502
```

Comparison result: these four layer-3 post-attention residual words match the
current assembly runtime output for
`token0_layer3_post_attn_residual0_f32_hex` through
`token0_layer3_post_attn_residual3_f32_hex` exactly. The prerequisite layer-2
post-FFN residual and layer-3 attention output public slices also still match
exactly.
