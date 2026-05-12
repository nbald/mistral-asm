# Layer-5 Attention Output Chain Review 2 - 2026-05-12

Scope: second review-gate pass over the completed token-0 layer-5 attention
Q/K/V handoff, single-token context, and output-projection matvec/slice chain
before adding layer-5 post-attention residual work.

## Findings

- No blocking runtime findings in this pass.
- No runtime source changes were required. The reviewed path keeps tensor
  descriptor lookup, borrowed buffer ownership, mapped payload reads, and public
  oracle output behind separate status gates.

## Notes

- Runtime orchestration still runs layer-5 norm, Q/K/V projections, the explicit
  Q/K/V handoff, context, and output-projection matvec before releasing the GGUF
  mmap (`src/entry/start/main/smoke_orchestration.inc:442`,
  `src/entry/start/main/smoke_orchestration.inc:446`,
  `src/entry/start/main/smoke_orchestration.inc:447`,
  `src/entry/start/main/smoke_orchestration.inc:448`,
  `src/entry/start/main/smoke_orchestration.inc:452`).
- The Q/K/V handoff validates the three projection statuses and the retained
  Q/K/V descriptor shapes without reading projection buffers or
  `blk.5.attn_output.weight` payload bytes
  (`src/infer/token0_layer5_attn_qkv_handoff.s:40`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:89`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:91`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:120`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:131`).
- The context smoke requires `token0_layer5_attn_qkv_handoff_status`, rechecks
  Q/K/V and output-projection descriptor shapes, then copies each 128-f32 value
  head into its four query-head slots for single-token attention
  (`src/infer/token0_layer5_attn_context.s:102`,
  `src/infer/token0_layer5_attn_context.s:138`,
  `src/infer/token0_layer5_attn_context.s:152`,
  `src/infer/token0_layer5_attn_context.s:158`,
  `src/infer/token0_layer5_attn_context.s:174`).
- The output-projection smoke requires `token0_layer5_attn_context_status`,
  checks `blk.5.attn_output.weight` as Q8_0 `[4096 x 3072]`, proves the mapped
  payload span, and prints exact-hex words only when the matvec status is 1
  (`src/infer/token0_layer5_attn_output.s:119`,
  `src/infer/token0_layer5_attn_output.s:121`,
  `src/infer/token0_layer5_attn_output.s:127`,
  `src/infer/token0_layer5_attn_output.s:136`,
  `src/infer/token0_layer5_attn_output.s:160`,
  `src/infer/token0_layer5_attn_output.s:202`).
- Symbol visibility matches the intended handoff boundary: the Q/K/V buffers,
  Q/K/V handoff status, context status, context buffer, and output-matvec
  status are global; `token0_layer5_attn_output` remains local private storage.
  The next residual step should keep the add in
  `src/infer/token0_layer5_attn_output.s` and publish a new post-attention
  residual status/buffer from there, instead of exporting the private
  output-projection buffer as a general dependency.
- Oracle coverage matches the reviewed public boundary. The focused oracle
  extends the layer-5 value oracle by recomputing the value projection,
  expanding the single-token grouped-query context, and dotting that context
  against the first four rows of `blk.5.attn_output.weight`
  (`work/oracle/token0_layer5_attn_output_oracle.py:97`,
  `work/oracle/token0_layer5_attn_output_oracle.py:108`,
  `work/oracle/token0_layer5_attn_output_oracle.py:123`,
  `work/oracle/token0_layer5_attn_output_oracle.py:129`,
  `work/oracle/token0_layer5_attn_output_oracle.py:131`,
  `work/oracle/token0_layer5_attn_output_oracle.py:236`).

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- `python3 -m py_compile work/oracle/*.py`
- `./mistral-asm --help` mentions Q/K/V projection handoff status, context
  status smoke, output projection descriptor lookup, and output-projection
  matvec slice.
- Real-target runtime/oracle comparison matched 57 oracle-covered labels
  including epsilon plus the 56 exact-hex labels covered by
  `work/oracle/token0_layer5_attn_output_oracle.py`.
- Real-target status output reported `token0_layer5_attn_qkv_handoff: 1`,
  `token0_layer5_attn_context: 1`, and
  `token0_layer5_attn_output_matvec: 1`. The retained layer-5 output-projection
  descriptor remained Q8_0 `[4096 x 3072]` at relative offset `1049640960`.
- The published layer-5 output-projection words were `0x3d443070`,
  `0x3e31a0d5`, `0xbddb87ff`, and `0xbdc80eb7`.
- An explicitly packed 24-byte v3 zero-count GGUF kept
  `layer5_attn_output_tensor_found`, `token0_layer5_attn_qkv_handoff`,
  `token0_layer5_attn_context`, and `token0_layer5_attn_output_matvec` at `0`,
  and emitted no `token0_layer5_attn_output*_f32_hex` labels.
- `git diff --check`
- `file ./mistral-asm`, `readelf -d ./mistral-asm`,
  `readelf -l ./mistral-asm`, and `nm -u ./mistral-asm` confirmed a static
  executable with no dynamic section, no interpreter, and no undefined symbols.
- Runtime source extension scan allowed only `.s` and `.inc` files under
  `src/`.
- Tracked include dependency scan found every `.include` fragment listed in
  `Makefile` dependencies.
- Symbol inspection confirmed the reviewed handoff/context/output status
  symbols are global, the Q/K/V and context buffers are global, and
  `token0_layer5_attn_output` remains local private storage.
- Tracked artifact and tracked large-file scans found no model files, build
  outputs, binaries, long logs, traces, perf outputs, or tracked files over
  1 MiB.
- Source line-count check preserved the known pressure points:
  `src/infer/token0_layer5_attn.s` at 996 lines,
  `src/infer/token0_layer5_attn_qkv_handoff.s` at 138 lines,
  `src/infer/token0_layer5_attn_context.s` at 185 lines,
  `src/infer/token0_layer5_attn_output.s` at 266 lines,
  `src/infer/token0_layer4_ffn.s` at 945 lines,
  `src/infer/token0_layer4_attn.s` at 945 lines,
  `src/infer/token0_layer3_ffn.s` at 942 lines,
  `src/infer/token0_layer2_ffn.s` at 943 lines,
  `src/infer/token0_layer2_attn.s` at 997 lines, and
  `src/gguf/load_header/tensor_infos.inc` at 1172 lines.

## Residual Risk

- This pass reviews the token-0 layer-5 attention handoff/context/output
  projection chain only. It does not prove layer-5 post-attention residual,
  FFN work, full generation, or multi-token attention.
- The second review-gate pass is now complete. Feature work can resume with the
  layer-5 post-attention residual step.
