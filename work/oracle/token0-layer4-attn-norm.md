# Token 0 Layer-4 Attention RMSNorm Oracle

Purpose: independently check the first four f32 words printed by the assembly
`token0_layer4_attn_norm*_f32_hex` smoke path for the local target GGUF.

This oracle is external verification tooling only. It is not linked by the
runtime build. The script reuses the full layer-3 post-FFN residual oracle
path, then applies `blk.4.attn_norm.weight` with the same RMSNorm helper
semantics used by the assembly smoke.

The arithmetic chain checked here extends
`work/oracle/token0-layer3-post-ffn-residual.md`:

1. Compute the complete token-0 layer-3 post-FFN residual.
2. Load the full f32 `blk.4.attn_norm.weight` tensor.
3. Compute RMSNorm over all 3072 residual words using the captured
   `mistral3.attention.layer_norm_rms_epsilon` metadata value.
4. Compare the first four normalized words with the runtime exact-hex slice.

Command:

```sh
python3 work/oracle/token0_layer4_attn_norm_oracle.py \
  models/unsloth-Ministral-3-3B-Instruct-2512-GGUF/Ministral-3-3B-Instruct-2512-Q8_0.gguf
```

External tool versions used:

```text
Python 3.12.3
numpy 1.26.4
```

Relevant oracle output:

```text
tensor_data_offset: 7882016
attn_norm_rms_epsilon_f32_hex: 0x3727c5ac
blk.3.ffn_down.weight: type 8 dims 9216x3072 offset 832339968
blk.4.attn_norm.weight: type 0 dims 3072 offset 925937664
oracle_token0_layer3_post_ffn_residual0_f32_hex: 0x440c2692
oracle_token0_layer3_post_ffn_residual1_f32_hex: 0xc1ff9359
oracle_token0_layer3_post_ffn_residual2_f32_hex: 0xc2a96a19
oracle_token0_layer3_post_ffn_residual3_f32_hex: 0xc15e5fea
oracle_token0_layer4_attn_norm0_f32_hex: 0x420c4b32
oracle_token0_layer4_attn_norm1_f32_hex: 0xc0768887
oracle_token0_layer4_attn_norm2_f32_hex: 0xc14b813f
oracle_token0_layer4_attn_norm3_f32_hex: 0xbffefae6
```

Comparison result: these four layer-4 attention RMSNorm words match the
current assembly runtime output for `token0_layer4_attn_norm0_f32_hex` through
`token0_layer4_attn_norm3_f32_hex` exactly. The prerequisite layer-3 post-FFN
residual public slice also still matches exactly.
