# Token 0 Layer-2 FFN Down Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_layer2_ffn_down_output*_f32_hex` smoke path for the local target GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script reuses the full layer-2 FFN RMSNorm oracle path,
then dots the 3072-word activation with all 9216 rows of
`blk.2.ffn_gate.weight` and `blk.2.ffn_up.weight`, computes the full
9216-word SwiGLU activation as `silu(gate[i]) * up[i]`, and dots that
activation with the first four rows of `blk.2.ffn_down.weight`.

The arithmetic chain checked here extends
`work/oracle/token0-layer2-ffn-swiglu.md`:

1. Compute the complete token-0 layer-2 FFN RMSNorm activation.
2. Dot that activation with every row of `blk.2.ffn_gate.weight`.
3. Dot that activation with every row of `blk.2.ffn_up.weight`.
4. Compute the complete layer-2 FFN SwiGLU activation with the same scalar
   helper used by the earlier FFN oracles.
5. Dot the SwiGLU activation with the first four rows of
   `blk.2.ffn_down.weight`.

Command:

```sh
python3 work/oracle/token0_layer2_ffn_down_oracle.py \
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
oracle_token0_layer2_ffn_norm0_f32_hex: 0x40522d9d
oracle_token0_layer2_ffn_norm1_f32_hex: 0xbf5d5852
oracle_token0_layer2_ffn_norm2_f32_hex: 0x3fc92f4e
oracle_token0_layer2_ffn_norm3_f32_hex: 0x3f3f5579
oracle_token0_layer2_ffn_gate_output0_f32_hex: 0x4204511d
oracle_token0_layer2_ffn_gate_output1_f32_hex: 0xbfebf5bb
oracle_token0_layer2_ffn_gate_output2_f32_hex: 0x414216d1
oracle_token0_layer2_ffn_gate_output3_f32_hex: 0x3f72ec48
oracle_token0_layer2_ffn_up_output0_f32_hex: 0x4289660c
oracle_token0_layer2_ffn_up_output1_f32_hex: 0x3ef6cc7e
oracle_token0_layer2_ffn_up_output2_f32_hex: 0xc1421f69
oracle_token0_layer2_ffn_up_output3_f32_hex: 0x3e00b19d
oracle_token0_layer2_ffn_swiglu_output0_f32_hex: 0x450e084e
oracle_token0_layer2_ffn_swiglu_output1_f32_hex: 0xbdf8abeb
oracle_token0_layer2_ffn_swiglu_output2_f32_hex: 0xc3132ce7
oracle_token0_layer2_ffn_swiglu_output3_f32_hex: 0x3db01261
oracle_token0_layer2_ffn_down_output0_f32_hex: 0x440c0a37
oracle_token0_layer2_ffn_down_output1_f32_hex: 0xc2008554
oracle_token0_layer2_ffn_down_output2_f32_hex: 0xc2a866d8
oracle_token0_layer2_ffn_down_output3_f32_hex: 0xc15e77da
```

Comparison result: these four layer-2 FFN down output words match the current
assembly runtime output for `token0_layer2_ffn_down_output0_f32_hex` through
`token0_layer2_ffn_down_output3_f32_hex` exactly. The prerequisite layer-2 FFN
RMSNorm, gate, up, and SwiGLU public slices also still match exactly.
