# Token 0 Layer-2 Attention Output Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_layer2_attn_output*_f32_hex` smoke path for the local target GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script reuses the full layer-2 attention RMSNorm oracle path,
computes the full layer-2 value projection, expands the one-token grouped-query
context, then dots that context with the first four rows of
`blk.2.attn_output.weight`. Its local Q8_0 dot helper keeps f32 products and
ordered f32 summation while using NumPy to avoid Python-level scalar unpacking
for every element.

The arithmetic chain checked here is:

1. Compute the full token-0 layer-0 attention, FFN branch, and post-FFN residual.
2. Apply `blk.1.attn_norm.weight` and compute the full token-0 layer-1
   attention value, output projection, and post-attention residual.
3. Apply `blk.1.ffn_norm.weight`, compute the full gate/up/SwiGLU branch, dot it
   through `blk.1.ffn_down.weight`, and add the full layer-1 post-FFN residual.
4. Apply `blk.2.attn_norm.weight` to the full layer-1 post-FFN residual.
5. Compute all 1024 rows of `blk.2.attn_v.weight`.
6. Expand the one-token grouped-query context to 4096 f32 values.
7. Dot the context with the first four rows of `blk.2.attn_output.weight`.

Command:

```sh
python3 work/oracle/token0_layer2_attn_output_oracle.py \
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
oracle_token0_layer1_post_ffn_residual0_f32_hex: 0xbd2addbf
oracle_token0_layer1_post_ffn_residual1_f32_hex: 0xbef2bcaa
oracle_token0_layer1_post_ffn_residual2_f32_hex: 0x4003aae1
oracle_token0_layer1_post_ffn_residual3_f32_hex: 0xbddfb01f
oracle_token0_layer2_attn_norm0_f32_hex: 0xbf898056
oracle_token0_layer2_attn_norm1_f32_hex: 0xc152dc8b
oracle_token0_layer2_attn_norm2_f32_hex: 0x4248afc4
oracle_token0_layer2_attn_norm3_f32_hex: 0xc0556342
oracle_token0_layer2_attn_context0_f32_hex: 0x3d38e19b
oracle_token0_layer2_attn_context1_f32_hex: 0x3ae7765b
oracle_token0_layer2_attn_context2_f32_hex: 0xbd4bbba8
oracle_token0_layer2_attn_context3_f32_hex: 0xbf48b85f
oracle_token0_layer2_attn_output0_f32_hex: 0x3eade180
oracle_token0_layer2_attn_output1_f32_hex: 0x3ee0fb2f
oracle_token0_layer2_attn_output2_f32_hex: 0xbff22222
oracle_token0_layer2_attn_output3_f32_hex: 0x3e24eb6b
```

Comparison result: these four layer-2 attention output-projection words match
the current assembly runtime output for
`token0_layer2_attn_output0_f32_hex` through
`token0_layer2_attn_output3_f32_hex` exactly. The prerequisite layer-2
attention context public slice also still matches exactly.
