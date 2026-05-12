# Layer-5 Attention Output Chain Review 1 - 2026-05-12

Scope: first review-gate pass over the completed token-0 layer-5 attention
Q/K/V handoff, single-token context, and output-projection matvec/slice chain
before adding layer-5 post-attention residual work.

## Findings

- No blocking runtime findings in this pass.
- No runtime source changes were required. The reviewed chain remains
  status-gated, keeps descriptor lookup separate from payload consumption, and
  fails closed on synthetic or malformed inputs.

## Notes

- Runtime orchestration preserves the ownership and mmap lifetime chain:
  layer-5 norm/Q/K/V run after the layer-4 post-FFN residual, then the explicit
  Q/K/V handoff, context, and output-projection matvec run before
  `gguf_release_mapping` (`src/entry/start/main/smoke_orchestration.inc:442`,
  `src/entry/start/main/smoke_orchestration.inc:446`,
  `src/entry/start/main/smoke_orchestration.inc:447`,
  `src/entry/start/main/smoke_orchestration.inc:448`,
  `src/entry/start/main/smoke_orchestration.inc:452`).
- The Q/K/V handoff owns only its status word, validates the three projection
  statuses plus exact Q/K/V descriptor shapes, and intentionally reads no
  projection buffer bytes or output-projection payload bytes
  (`src/infer/token0_layer5_attn_qkv_handoff.s:40`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:46`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:91`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:98`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:120`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:131`).
- The context module consumes `token0_layer5_attn_qkv_handoff_status`, borrows
  the exported value projection buffer, rechecks query/key/value/output
  descriptor shapes, and expands each 128-f32 KV head into four query-head
  blocks without reading model payload bytes
  (`src/infer/token0_layer5_attn_context.s:51`,
  `src/infer/token0_layer5_attn_context.s:102`,
  `src/infer/token0_layer5_attn_context.s:127`,
  `src/infer/token0_layer5_attn_context.s:138`,
  `src/infer/token0_layer5_attn_context.s:149`,
  `src/infer/token0_layer5_attn_context.s:174`).
- The output-projection matvec smoke depends on the context status, requires
  `blk.5.attn_output.weight` to be Q8_0 `[4096 x 3072]`, proves the full mapped
  payload span before calling `q8_0_matvec_f32`, and prints exact-hex words
  only after `token0_layer5_attn_output_matvec_status` is 1
  (`src/infer/token0_layer5_attn_output.s:119`,
  `src/infer/token0_layer5_attn_output.s:121`,
  `src/infer/token0_layer5_attn_output.s:127`,
  `src/infer/token0_layer5_attn_output.s:136`,
  `src/infer/token0_layer5_attn_output.s:160`,
  `src/infer/token0_layer5_attn_output.s:174`,
  `src/infer/token0_layer5_attn_output.s:202`).
- Oracle coverage matches the public boundary. The focused oracle reuses the
  layer-5 value oracle, recomputes the full value projection, expands the
  single-token grouped-query context, and dots that context against the first
  four rows of `blk.5.attn_output.weight`
  (`work/oracle/token0_layer5_attn_output_oracle.py:97`,
  `work/oracle/token0_layer5_attn_output_oracle.py:108`,
  `work/oracle/token0_layer5_attn_output_oracle.py:123`,
  `work/oracle/token0_layer5_attn_output_oracle.py:129`,
  `work/oracle/token0_layer5_attn_output_oracle.py:131`,
  `work/oracle/token0_layer5_attn_output_oracle.py:149`,
  `work/oracle/token0_layer5_attn_output_oracle.py:236`).
- The focused layer-5 modules are build-tracked as separate assembly sources
  (`Makefile:30`, `Makefile:31`, `Makefile:32`). `token0_layer5_attn_output`
  is currently a local symbol, while the context buffer and status handoffs are
  exported. The next residual implementation must either keep the residual add
  in this module or deliberately export/handoff the private output buffer
  before another object consumes it.

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
  `token0_layer5_attn_output_matvec: 1`. The published layer-5 output words
  were `0x3d443070`, `0x3e31a0d5`, `0xbddb87ff`, and `0xbdc80eb7`.
- A temporary 24-byte zero-count GGUF kept `layer5_attn_output_tensor_found`,
  `token0_layer5_attn_qkv_handoff`, `token0_layer5_attn_context`, and
  `token0_layer5_attn_output_matvec` at `0`, and emitted no
  `token0_layer5_attn_output*_f32_hex` labels.
- `git diff --check`
- `file ./mistral-asm`, `readelf -d ./mistral-asm`,
  `readelf -l ./mistral-asm`, and `nm -u ./mistral-asm` confirmed a static
  executable with no dynamic section, no interpreter, and no undefined
  symbols.
- Runtime source extension scan allowed only `.s` and `.inc` files under
  `src/`.
- Tracked include dependency scan found every `.include` fragment listed in
  `Makefile` dependencies.
- Symbol inspection confirmed the reviewed handoff/context/output status
  symbols are global, the context buffer is global, and
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
- A second review-gate pass is still required before feature work resumes.
- The output-projection buffer handoff remains an intentional next-step design
  choice because the buffer is private today.
