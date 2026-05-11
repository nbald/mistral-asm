# Token 0 Layer-1 Post-FFN Residual Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_layer1_ffn_gate_output*_f32_hex`,
`token0_layer1_ffn_up_output*_f32_hex`,
`token0_layer1_ffn_swiglu_output*_f32_hex`,
`token0_layer1_ffn_down_output*_f32_hex`, and
`token0_layer1_post_ffn_residual*_f32_hex` smoke paths for the local target
GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script reuses the full layer-1 FFN RMSNorm oracle path,
then dots the 3072-word activation with all 9216 rows of
`blk.1.ffn_gate.weight` and `blk.1.ffn_up.weight`, computes the full
9216-word SwiGLU activation as `silu(gate[i]) * up[i]`, dots that activation
with the first four rows of `blk.1.ffn_down.weight`, and adds those four down
words to the layer-1 post-attention residual with f32 rounding.

The arithmetic chain checked here extends
`work/oracle/token0-layer1-ffn-norm.md`:

1. Compute the complete token-0 layer-1 FFN RMSNorm activation.
2. Dot that activation with every row of `blk.1.ffn_gate.weight`.
3. Dot that activation with every row of `blk.1.ffn_up.weight`.
4. Compute the complete layer-1 FFN SwiGLU activation with the same scalar
   helper used by the earlier layer-0 oracle.
5. Dot the SwiGLU activation with the first four rows of
   `blk.1.ffn_down.weight`.
6. Add the first four layer-1 post-attention residual and FFN down words with
   f32 rounding.

Command:

```sh
python3 work/oracle/token0_layer1_post_ffn_residual_oracle.py \
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
oracle_token0_layer1_post_attn_residual0_f32_hex: 0xbd4055c4
oracle_token0_layer1_post_attn_residual1_f32_hex: 0xbf0fbbb6
oracle_token0_layer1_post_attn_residual2_f32_hex: 0x401af18e
oracle_token0_layer1_post_attn_residual3_f32_hex: 0xbe6a002c
oracle_token0_layer1_ffn_norm0_f32_hex: 0xbec8ddb4
oracle_token0_layer1_ffn_norm1_f32_hex: 0xc11f7d85
oracle_token0_layer1_ffn_norm2_f32_hex: 0x40d46234
oracle_token0_layer1_ffn_norm3_f32_hex: 0xbfe2ec8e
oracle_token0_layer1_ffn_gate_output0_f32_hex: 0xbe34ea97
oracle_token0_layer1_ffn_gate_output1_f32_hex: 0xbfcc8119
oracle_token0_layer1_ffn_gate_output2_f32_hex: 0xbf150238
oracle_token0_layer1_ffn_gate_output3_f32_hex: 0xbf882cef
oracle_token0_layer1_ffn_up_output0_f32_hex: 0x3f1797a4
oracle_token0_layer1_ffn_up_output1_f32_hex: 0x3f80ec8f
oracle_token0_layer1_ffn_up_output2_f32_hex: 0xbe651441
oracle_token0_layer1_ffn_up_output3_f32_hex: 0x3f2943b9
oracle_token0_layer1_ffn_swiglu_output0_f32_hex: 0xbd436233
oracle_token0_layer1_ffn_swiglu_output1_f32_hex: 0xbe8aab8b
oracle_token0_layer1_ffn_swiglu_output2_f32_hex: 0x3d3f2f78
oracle_token0_layer1_ffn_swiglu_output3_f32_hex: 0xbe38ceee
oracle_token0_layer1_ffn_down_output0_f32_hex: 0x3babc025
oracle_token0_layer1_ffn_down_output1_f32_hex: 0x3db2eb07
oracle_token0_layer1_ffn_down_output2_f32_hex: 0xbeba3568
oracle_token0_layer1_ffn_down_output3_f32_hex: 0x3df45039
oracle_token0_layer1_post_ffn_residual0_f32_hex: 0xbd2addbf
oracle_token0_layer1_post_ffn_residual1_f32_hex: 0xbef2bcaa
oracle_token0_layer1_post_ffn_residual2_f32_hex: 0x4003aae1
oracle_token0_layer1_post_ffn_residual3_f32_hex: 0xbddfb01f
```

Comparison result: the layer-1 gate, up, SwiGLU, down, and post-FFN residual
oracle words above match the current assembly runtime output for the
corresponding `token0_layer1_*_f32_hex` labels exactly. The input layer-1
post-attention residual and FFN RMSNorm public slices also still match exactly.
