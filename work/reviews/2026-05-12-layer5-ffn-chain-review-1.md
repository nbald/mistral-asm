# Layer-5 FFN Chain Review 1 - 2026-05-12

Scope: first review-gate pass over the completed token-0 layer-5
FFN/down/post-FFN residual chain before expanding feature scope.

## Findings

- No blocking findings in this pass.
- No runtime source changes were required. The reviewed chain remains
  status-gated, shape-checked, mmap-bounds-checked before mapped payload reads,
  and split so the down projection plus post-FFN residual stay in the focused
  down module.

## Notes

- Runtime orchestration preserves the reviewed dependency order while the GGUF
  mapping is still live: layer-5 post-attention residual, FFN RMSNorm, gate/up
  matvecs, SwiGLU, down matvec, then post-FFN residual
  (`src/entry/start/main/smoke_orchestration.inc:449`,
  `src/entry/start/main/smoke_orchestration.inc:450`,
  `src/entry/start/main/smoke_orchestration.inc:451`,
  `src/entry/start/main/smoke_orchestration.inc:452`,
  `src/entry/start/main/smoke_orchestration.inc:453`,
  `src/entry/start/main/smoke_orchestration.inc:454`,
  `src/entry/start/main/smoke_orchestration.inc:455`).
- Descriptor bootstrap remains descriptor-only for the layer-5 FFN norm, gate,
  up, and down tensors. The lookup path retains shape, type, and relative
  offset metadata through `gguf_lookup_tensor_info`, while payload bytes are read
  only by later smoke paths that recheck type, shape, and bounds
  (`src/entry/start/main/bootstrap/layer5.inc:110`,
  `src/entry/start/main/bootstrap/layer5.inc:133`,
  `src/entry/start/main/bootstrap/layer5.inc:155`,
  `src/entry/start/main/bootstrap/layer5.inc:176`).
- The FFN RMSNorm smoke fails closed: it starts with `rax = 0`, requires the
  post-attention residual, captured epsilon metadata, f32 `[3072]` weights,
  non-negative offsets, an overflow-safe absolute offset, a complete mapped
  payload span, and a non-null mapping before calling `rmsnorm_f32`
  (`src/infer/token0_layer5_ffn.s:212`,
  `src/infer/token0_layer5_ffn.s:214`,
  `src/infer/token0_layer5_ffn.s:216`,
  `src/infer/token0_layer5_ffn.s:218`,
  `src/infer/token0_layer5_ffn.s:224`,
  `src/infer/token0_layer5_ffn.s:230`,
  `src/infer/token0_layer5_ffn.s:246`,
  `src/infer/token0_layer5_ffn.s:249`,
  `src/infer/token0_layer5_ffn.s:259`).
- Gate and up matvec smokes match the shared `q8_0_matvec_f32` ABI. They require
  the FFN norm status, Q8_0 `[3072 x 9216]` descriptors, complete payload-span
  proofs, and then write private 9216-f32 projection buffers
  (`src/infer/token0_layer5_ffn.s:499`,
  `src/infer/token0_layer5_ffn.s:501`,
  `src/infer/token0_layer5_ffn.s:507`,
  `src/infer/token0_layer5_ffn.s:509`,
  `src/infer/token0_layer5_ffn.s:511`,
  `src/infer/token0_layer5_ffn.s:544`,
  `src/infer/token0_layer5_ffn.s:553`,
  `src/infer/token0_layer5_ffn.s:556`,
  `src/infer/token0_layer5_ffn.s:717`,
  `src/infer/token0_layer5_ffn.s:719`,
  `src/infer/token0_layer5_ffn.s:725`,
  `src/infer/token0_layer5_ffn.s:727`,
  `src/infer/token0_layer5_ffn.s:729`,
  `src/infer/token0_layer5_ffn.s:761`,
  `src/infer/token0_layer5_ffn.s:770`,
  `src/infer/token0_layer5_ffn.s:773`).
- The SwiGLU stage reads no mapped payload bytes. It waits for both private
  projection statuses, combines private gate/up buffers, and publishes only the
  9216-f32 SwiGLU handoff needed by the focused down-projection module
  (`src/infer/token0_layer5_ffn.s:930`,
  `src/infer/token0_layer5_ffn.s:932`,
  `src/infer/token0_layer5_ffn.s:934`,
  `src/infer/token0_layer5_ffn.s:939`,
  `src/infer/token0_layer5_ffn.s:943`).
- The down module owns the large down-matvec and residual add instead of growing
  the 952-line layer-5 FFN module. The down smoke requires the exported SwiGLU
  status and handoff, verifies Q8_0 `[9216 x 3072]`, proves the complete mapped
  span, and writes private 3072-f32 down output before publishing status and the
  guarded exact-hex slice (`src/infer/token0_layer5_ffn_down.s:405`,
  `src/infer/token0_layer5_ffn_down.s:407`,
  `src/infer/token0_layer5_ffn_down.s:413`,
  `src/infer/token0_layer5_ffn_down.s:415`,
  `src/infer/token0_layer5_ffn_down.s:417`,
  `src/infer/token0_layer5_ffn_down.s:450`,
  `src/infer/token0_layer5_ffn_down.s:459`,
  `src/infer/token0_layer5_ffn_down.s:462`).
- The post-FFN residual smoke requires both prerequisite statuses, repeats the
  3072-wide down descriptor guard, writes only the exported next-layer handoff
  buffer, and does not read mapped tensor payload bytes
  (`src/infer/token0_layer5_ffn_down.s:190`,
  `src/infer/token0_layer5_ffn_down.s:192`,
  `src/infer/token0_layer5_ffn_down.s:194`,
  `src/infer/token0_layer5_ffn_down.s:200`,
  `src/infer/token0_layer5_ffn_down.s:203`,
  `src/infer/token0_layer5_ffn_down.s:205`,
  `src/infer/token0_layer5_ffn_down.s:217`).
- Public exact-hex slices are independently print-side status-gated for FFN
  norm, gate, up, SwiGLU, down, and post-FFN residual outputs
  (`src/infer/token0_layer5_ffn.s:287`,
  `src/infer/token0_layer5_ffn.s:413`,
  `src/infer/token0_layer5_ffn.s:631`,
  `src/infer/token0_layer5_ffn.s:847`,
  `src/infer/token0_layer5_ffn_down.s:320`,
  `src/infer/token0_layer5_ffn_down.s:241`).
- Oracle coverage is acceptable for the reviewed boundary. The layer-5 FFN down
  oracle recomputes full 9216-word gate/up/SwiGLU activations before dotting the
  public down rows, and the post-FFN residual oracle adds the matching
  post-attention residual words with scalar f32 rounding
  (`work/oracle/token0_layer5_ffn_down_oracle.py:129`,
  `work/oracle/token0_layer5_ffn_down_oracle.py:132`,
  `work/oracle/token0_layer5_ffn_down_oracle.py:139`,
  `work/oracle/token0_layer5_ffn_down_oracle.py:141`,
  `work/oracle/token0_layer5_ffn_down_oracle.py:144`,
  `work/oracle/token0_layer5_post_ffn_residual_oracle.py:72`,
  `work/oracle/token0_layer5_post_ffn_residual_oracle.py:74`).
- Split discipline is acceptable for this pass but tight. `token0_layer5_ffn.s`
  is 952 lines and should not receive substantial new feature code; continuing
  layer-6 work should start in focused modules or Makefile-tracked fragments.

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- `python3 -m py_compile work/oracle/*.py`
- Real target smoke reported `token0_layer5_post_attn_residual: 1`,
  `token0_layer5_ffn_norm: 1`, `token0_layer5_ffn_gate_matvec: 1`,
  `token0_layer5_ffn_up_matvec: 1`, `token0_layer5_ffn_swiglu: 1`,
  `token0_layer5_ffn_down_matvec: 1`, and
  `token0_layer5_post_ffn_residual: 1`.
- Real target descriptor output reported layer-5 FFN norm as f32 `[3072]`,
  gate/up as Q8_0 `[3072 x 9216]`, and down as Q8_0 `[9216 x 3072]`.
- Real-target runtime/oracle comparison matched all 84 oracle-prefixed
  exact-hex labels from `work/oracle/token0_layer5_post_ffn_residual_oracle.py`;
  the shared epsilon exact-hex line also matched, for 85 covered exact values.
- A 24-byte v3 zero-count GGUF kept the reviewed layer-5 FFN descriptor found
  flags and dependent statuses at `0`, and emitted no guarded layer-5 FFN or
  post-FFN residual exact-hex labels.
- `git diff --check`
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, `readelf -l ./mistral-asm`,
  and `nm -u ./mistral-asm` confirmed a static executable with no dynamic
  section, no interpreter, and no undefined symbols.
- Runtime source extension scan allowed only `.s` and `.inc` files under
  `src/`.
- Include dependency scan found every `.include` fragment listed in `Makefile`
  dependencies.
- Exported-symbol inspection covered the reviewed layer-5 FFN runner entry
  points, descriptor slots, statuses, and retained activation handoff buffers.
  Gate/up/down projection outputs remain local private storage; FFN norm,
  SwiGLU, and post-FFN residual buffers are exported only where they are
  handoff surfaces.
- Tracked artifact and tracked large-file scans found no model files, build
  outputs, binaries, long logs, traces, perf outputs, or tracked files over
  1 MiB.
- Source line-count check preserved the known pressure points:
  `src/infer/token0_layer5_ffn.s` at 952 lines,
  `src/infer/token0_layer5_ffn_down.s` at 475 lines,
  `src/infer/token0_layer5_attn.s` at 996 lines,
  `src/infer/token0_layer4_ffn.s` at 945 lines,
  `src/infer/token0_layer4_attn.s` at 945 lines,
  `src/infer/token0_layer3_ffn.s` at 942 lines,
  `src/infer/token0_layer2_ffn.s` at 943 lines,
  `src/infer/token0_layer2_attn.s` at 997 lines,
  `src/entry/start/lookup_summary/layer5.inc` at 898 lines, and
  `src/gguf/load_header/tensor_infos.inc` at 1172 lines.

## Residual Risk

- This is only the first of two required review passes before feature work
  resumes.
- This pass proves the public token-0 layer-5 FFN/down/post-FFN residual smoke
  boundary, not token generation or a reusable whole-layer execution
  abstraction.
- The scalar smoke path remains correctness-first and expensive. Optimization
  remains deferred until a useful inference path exists.
