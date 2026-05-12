# Layer-5 Attention Residual Chain Review 1 - 2026-05-12

Scope: first review-gate pass over the completed token-0 layer-5 attention
Q/K/V handoff, single-token context, output-projection matvec/slice, and
post-attention residual handoff chain before adding layer-5 FFN work.

## Findings

- No blocking runtime findings in this pass.
- No runtime source changes were required. The reviewed chain keeps the raw
  layer-5 output-projection buffer private, publishes only the residual handoff
  needed by future FFN work, and keeps all payload reads behind status and shape
  gates.

## Notes

- Runtime orchestration preserves the chain order before releasing the GGUF
  mapping: layer-5 attention norm/Q/K/V, explicit Q/K/V handoff, context,
  output-projection matvec, then post-attention residual
  (`src/entry/start/main/smoke_orchestration.inc:442`,
  `src/entry/start/main/smoke_orchestration.inc:446`,
  `src/entry/start/main/smoke_orchestration.inc:447`,
  `src/entry/start/main/smoke_orchestration.inc:448`,
  `src/entry/start/main/smoke_orchestration.inc:449`,
  `src/entry/start/main/smoke_orchestration.inc:451`).
- The Q/K/V handoff owns only its status, requires the three projection statuses,
  rechecks exact Q/K/V descriptor shapes, and intentionally reads no projection
  buffer bytes or output-projection payload bytes
  (`src/infer/token0_layer5_attn_qkv_handoff.s:40`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:46`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:91`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:98`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:120`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:131`).
- The context smoke consumes the explicit handoff, borrows only the exported
  value projection buffer, rechecks Q/K/V and output-projection descriptor
  shapes, and expands each 128-f32 value head into four query-head blocks for the
  single-token case without reading mapped payload bytes
  (`src/infer/token0_layer5_attn_context.s:51`,
  `src/infer/token0_layer5_attn_context.s:102`,
  `src/infer/token0_layer5_attn_context.s:127`,
  `src/infer/token0_layer5_attn_context.s:138`,
  `src/infer/token0_layer5_attn_context.s:149`,
  `src/infer/token0_layer5_attn_context.s:174`).
- The output-projection module keeps `token0_layer5_attn_output` as local
  private storage, while `token0_layer5_post_attn_residual_status` and
  `token0_layer5_post_attn_residual` are explicit global handoff symbols for
  later FFN work (`src/infer/token0_layer5_attn_output.s:64`,
  `src/infer/token0_layer5_attn_output.s:68`,
  `src/infer/token0_layer5_attn_output.s:73`).
- The output-projection smoke requires `token0_layer5_attn_context_status`,
  validates `blk.5.attn_output.weight` as Q8_0 `[4096 x 3072]`, proves the full
  mapped payload span before calling `q8_0_matvec_f32`, and prints exact-hex
  output words only after the matvec status is 1
  (`src/infer/token0_layer5_attn_output.s:198`,
  `src/infer/token0_layer5_attn_output.s:200`,
  `src/infer/token0_layer5_attn_output.s:206`,
  `src/infer/token0_layer5_attn_output.s:215`,
  `src/infer/token0_layer5_attn_output.s:239`,
  `src/infer/token0_layer5_attn_output.s:250`,
  `src/infer/token0_layer5_attn_output.s:333`).
- The post-attention residual smoke requires both the layer-4 post-FFN residual
  and layer-5 output-matvec statuses, repeats the 3072-wide output descriptor
  guard, writes only the exported residual buffer, and prints exact-hex residual
  words only after `token0_layer5_post_attn_residual_status` is 1
  (`src/infer/token0_layer5_attn_output.s:284`,
  `src/infer/token0_layer5_attn_output.s:286`,
  `src/infer/token0_layer5_attn_output.s:292`,
  `src/infer/token0_layer5_attn_output.s:295`,
  `src/infer/token0_layer5_attn_output.s:300`,
  `src/infer/token0_layer5_attn_output.s:311`,
  `src/infer/token0_layer5_attn_output.s:412`).
- Oracle coverage matches the reviewed public boundary. The focused oracle
  reuses the layer-5 value oracle, recomputes the full value projection, expands
  the single-token grouped-query context, dots against the first four rows of
  `blk.5.attn_output.weight`, and adds the layer-4 post-FFN residual with scalar
  f32 rounding for the public layer-5 residual words
  (`work/oracle/token0_layer5_attn_output_oracle.py:88`,
  `work/oracle/token0_layer5_attn_output_oracle.py:99`,
  `work/oracle/token0_layer5_attn_output_oracle.py:121`,
  `work/oracle/token0_layer5_attn_output_oracle.py:131`,
  `work/oracle/token0_layer5_attn_output_oracle.py:133`,
  `work/oracle/token0_layer5_attn_output_oracle.py:161`,
  `work/oracle/token0_layer5_attn_output_oracle.py:246`,
  `work/oracle/token0_layer5_attn_output_oracle.py:249`).
- The focused layer-5 modules are separate Makefile-tracked assembly sources
  (`Makefile:29`, `Makefile:30`, `Makefile:31`, `Makefile:32`). This keeps
  future layer-5 FFN work out of `src/infer/token0_layer5_attn.s`, which remains
  at the documented line-count pressure point.

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- `python3 -m py_compile work/oracle/*.py`
- `./mistral-asm --help` mentions Q/K/V projection handoff status, context
  status smoke, output projection descriptor lookup, output-projection matvec
  slice, and post-attention residual slice.
- Real-target runtime/oracle comparison matched 61 oracle-covered labels:
  epsilon plus the 60 exact-hex labels covered by
  `work/oracle/token0_layer5_attn_output_oracle.py`.
- Real-target status output reported `token0_layer5_attn_qkv_handoff: 1`,
  `token0_layer5_attn_context: 1`,
  `token0_layer5_attn_output_matvec: 1`, and
  `token0_layer5_post_attn_residual: 1`.
- The published layer-5 post-attention residual words were `0x440c34df`,
  `0xc1fcec34`, `0xc2a9b98b`, and `0xc1618569`.
- An explicitly packed 24-byte v3 zero-count GGUF kept
  `layer5_attn_output_tensor_found`, `token0_layer5_attn_qkv_handoff`,
  `token0_layer5_attn_context`, `token0_layer5_attn_output_matvec`, and
  `token0_layer5_post_attn_residual` at `0`, and emitted no guarded layer-5
  output/residual exact-hex labels.
- `git diff --check`
- `file ./mistral-asm`, `readelf -d ./mistral-asm`,
  `readelf -l ./mistral-asm`, and `nm -u ./mistral-asm` confirmed a static
  executable with no dynamic section, no interpreter, and no undefined symbols.
- Runtime source extension scan allowed only `.s` and `.inc` files under `src/`.
- Tracked include dependency scan found every `.include` fragment listed in
  `Makefile` dependencies.
- Symbol inspection confirmed the layer-5 Q/K/V buffers, Q/K/V handoff status,
  context status/buffer, output-matvec status, and post-attention residual
  status/buffer are global, while `token0_layer5_attn_output` remains local
  private storage.
- Tracked artifact and tracked large-file scans found no model files, build
  outputs, binaries, long logs, traces, perf outputs, or tracked files over
  1 MiB.
- Source line-count check preserved the known pressure points:
  `src/infer/token0_layer5_attn.s` at 996 lines,
  `src/infer/token0_layer5_attn_qkv_handoff.s` at 138 lines,
  `src/infer/token0_layer5_attn_context.s` at 185 lines,
  `src/infer/token0_layer5_attn_output.s` at 476 lines,
  `src/infer/token0_layer4_ffn.s` at 945 lines,
  `src/infer/token0_layer4_attn.s` at 945 lines,
  `src/infer/token0_layer3_ffn.s` at 942 lines,
  `src/infer/token0_layer2_ffn.s` at 943 lines,
  `src/infer/token0_layer2_attn.s` at 997 lines, and
  `src/gguf/load_header/tensor_infos.inc` at 1172 lines.

## Residual Risk

- This pass reviews the token-0 layer-5 attention handoff/context/output
  projection/post-attention residual chain only. It does not prove layer-5 FFN
  work, full generation, or multi-token attention.
- A second review-gate pass is still required before feature work resumes.
