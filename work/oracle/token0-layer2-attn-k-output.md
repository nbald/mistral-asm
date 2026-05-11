# Token 0 Layer-2 Attention Key Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_layer2_attn_k_output*_f32_hex` smoke path for the local target GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script reuses the full layer-2 attention RMSNorm oracle path,
then dots the resulting 3072-word activation with the first four rows of
`blk.2.attn_k.weight` using the same scalar Q8_0 f32 accumulation order as
`q8_0_matvec_f32`.

The arithmetic chain checked here is:

1. Compute the full token-0 layer-0 attention, FFN branch, and post-FFN residual.
2. Apply `blk.1.attn_norm.weight` and compute the full token-0 layer-1
   attention value, output projection, and post-attention residual.
3. Apply `blk.1.ffn_norm.weight`, compute the full gate/up/SwiGLU branch, dot it
   through `blk.1.ffn_down.weight`, and add the full layer-1 post-FFN residual.
4. Apply `blk.2.attn_norm.weight` to the full layer-1 post-FFN residual.
5. Dot the layer-2 normalized activation with the first four rows of
   `blk.2.attn_k.weight`.

Command:

```sh
python3 work/oracle/token0_layer2_attn_k_oracle.py \
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
blk.2.attn_k.weight: type 8 dims 3072x1024 offset 675213312
oracle_token0_layer1_post_ffn_residual0_f32_hex: 0xbd2addbf
oracle_token0_layer1_post_ffn_residual1_f32_hex: 0xbef2bcaa
oracle_token0_layer1_post_ffn_residual2_f32_hex: 0x4003aae1
oracle_token0_layer1_post_ffn_residual3_f32_hex: 0xbddfb01f
oracle_token0_layer2_attn_norm0_f32_hex: 0xbf898056
oracle_token0_layer2_attn_norm1_f32_hex: 0xc152dc8b
oracle_token0_layer2_attn_norm2_f32_hex: 0x4248afc4
oracle_token0_layer2_attn_norm3_f32_hex: 0xc0556342
oracle_token0_layer2_attn_k_output0_f32_hex: 0xc0775316
oracle_token0_layer2_attn_k_output1_f32_hex: 0xbecc9c4c
oracle_token0_layer2_attn_k_output2_f32_hex: 0xbfd669ad
oracle_token0_layer2_attn_k_output3_f32_hex: 0x4005155d
```

Comparison result: these four layer-2 attention key words match the current
assembly runtime output for `token0_layer2_attn_k_output0_f32_hex` through
`token0_layer2_attn_k_output3_f32_hex` exactly. The prerequisite layer-1
post-FFN residual and layer-2 attention RMSNorm public slices also still match
exactly.
