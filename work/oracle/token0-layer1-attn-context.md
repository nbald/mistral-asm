# Token 0 Layer-1 Attention Context Oracle

Purpose: independently justify the first four f32 words printed by the assembly
`token0_layer1_attn_context*_f32_hex` smoke path for the local target GGUF.

This oracle note is external verification evidence only. It is not linked by
the runtime build. The arithmetic input is the independently checked layer-1
attention value projection from `token0_layer1_attn_v_oracle.py`; the context
step itself is a shape-guarded grouped-query copy.

The context rule checked here is:

1. The layer-1 value projection produces 1024 f32 words:
   8 KV heads * 128 words per head.
2. The layer-1 attention context has 4096 f32 words:
   32 query heads * 128 words per head.
3. In this one-token smoke path, every query head attends to exactly one
   key/value entry, so softmax over the single attention score is exactly 1.
4. Ministral grouped-query attention maps each KV head to four query heads, so
   each 128-word KV-head value block is copied four times into context.
5. Therefore context words 0 through 3 are exactly value-projection words 0
   through 3. No output-projection payload bytes participate in this equality.

Command for the independent value projection input:

```sh
python3 work/oracle/token0_layer1_attn_v_oracle.py \
  models/unsloth-Ministral-3-3B-Instruct-2512-GGUF/Ministral-3-3B-Instruct-2512-Q8_0.gguf
```

External tool versions used:

```text
Python 3.12.3
numpy 1.26.4
```

Relevant oracle output:

```text
blk.1.attn_v.weight: type 8 dims 3072x1024 offset 581615616
oracle_token0_layer1_attn_v_output0_f32_hex: 0x3d6bd91b
oracle_token0_layer1_attn_v_output1_f32_hex: 0x3d763224
oracle_token0_layer1_attn_v_output2_f32_hex: 0x3d709b92
oracle_token0_layer1_attn_v_output3_f32_hex: 0xbcca1ab6
```

Runtime context output:

```text
token0_layer1_attn_context: 1
token0_layer1_attn_context0_f32_hex: 0x3d6bd91b
token0_layer1_attn_context1_f32_hex: 0x3d763224
token0_layer1_attn_context2_f32_hex: 0x3d709b92
token0_layer1_attn_context3_f32_hex: 0xbcca1ab6
```

Comparison result: these four context words match the independently recomputed
layer-1 value projection words exactly. The equality follows from the
single-token grouped-query context rule, so this note verifies the current
context smoke without adding a second implementation of the same copy loop.
