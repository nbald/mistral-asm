# Layer-5 FFN Chain Review 2 - 2026-05-12

Scope: second review-gate pass over the completed token-0 layer-5
FFN/down/post-FFN residual chain before feature work resumes.

## Findings

- No blocking findings in this pass.
- No runtime source changes were required. The reviewed boundary remains
  status-gated, descriptor-shape-checked, mmap-bounds-checked before mapped
  payload reads, and split across focused modules.

## Notes

- Runtime orchestration preserves the dependency order while the model mapping
  is live: layer-5 post-attention residual, FFN norm, gate, up, SwiGLU, down,
  and post-FFN residual (`src/entry/start/main/smoke_orchestration.inc:449`,
  `src/entry/start/main/smoke_orchestration.inc:450`,
  `src/entry/start/main/smoke_orchestration.inc:451`,
  `src/entry/start/main/smoke_orchestration.inc:452`,
  `src/entry/start/main/smoke_orchestration.inc:453`,
  `src/entry/start/main/smoke_orchestration.inc:454`,
  `src/entry/start/main/smoke_orchestration.inc:455`).
- Layer-5 FFN descriptor bootstrap remains descriptor-only. Norm, gate, up, and
  down lookups retain found/shape/type/offset fields and leave payload reads to
  the later guarded smoke paths (`src/entry/start/main/bootstrap/layer5.inc:110`,
  `src/entry/start/main/bootstrap/layer5.inc:133`,
  `src/entry/start/main/bootstrap/layer5.inc:155`,
  `src/entry/start/main/bootstrap/layer5.inc:176`).
- The FFN norm smoke requires the layer-5 post-attention residual status,
  captured epsilon, f32 `[3072]` weights, non-negative offsets, an
  overflow-checked absolute payload offset, a complete mapped span, and a
  non-null mapping before calling `rmsnorm_f32`
  (`src/infer/token0_layer5_ffn.s:212`,
  `src/infer/token0_layer5_ffn.s:214`,
  `src/infer/token0_layer5_ffn.s:216`,
  `src/infer/token0_layer5_ffn.s:224`,
  `src/infer/token0_layer5_ffn.s:230`,
  `src/infer/token0_layer5_ffn.s:246`,
  `src/infer/token0_layer5_ffn.s:249`,
  `src/infer/token0_layer5_ffn.s:259`).
- Gate and up matvecs require the FFN norm status, Q8_0 `[3072 x 9216]`
  descriptors, and complete row-major payload-span proofs before writing private
  9216-f32 buffers (`src/infer/token0_layer5_ffn.s:499`,
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
- The SwiGLU stage reads no mapped tensor payload bytes. It consumes only the
  private gate/up buffers after both statuses are 1, then exports the 9216-f32
  activation handoff for the down module (`src/infer/token0_layer5_ffn.s:930`,
  `src/infer/token0_layer5_ffn.s:932`,
  `src/infer/token0_layer5_ffn.s:934`,
  `src/infer/token0_layer5_ffn.s:939`,
  `src/infer/token0_layer5_ffn.s:943`).
- The focused down module owns the Q8_0 `[9216 x 3072]` down matvec and private
  3072-f32 output. The post-FFN residual step separately requires both
  prerequisite statuses and rechecks the 3072 output width before exporting the
  next-layer handoff (`src/infer/token0_layer5_ffn_down.s:405`,
  `src/infer/token0_layer5_ffn_down.s:407`,
  `src/infer/token0_layer5_ffn_down.s:413`,
  `src/infer/token0_layer5_ffn_down.s:415`,
  `src/infer/token0_layer5_ffn_down.s:417`,
  `src/infer/token0_layer5_ffn_down.s:450`,
  `src/infer/token0_layer5_ffn_down.s:459`,
  `src/infer/token0_layer5_ffn_down.s:462`,
  `src/infer/token0_layer5_ffn_down.s:190`,
  `src/infer/token0_layer5_ffn_down.s:192`,
  `src/infer/token0_layer5_ffn_down.s:194`,
  `src/infer/token0_layer5_ffn_down.s:200`,
  `src/infer/token0_layer5_ffn_down.s:203`,
  `src/infer/token0_layer5_ffn_down.s:205`).
- Public exact-hex printers for norm, gate, up, SwiGLU, down, and post-FFN
  residual all have independent print-side status gates
  (`src/infer/token0_layer5_ffn.s:287`,
  `src/infer/token0_layer5_ffn.s:413`,
  `src/infer/token0_layer5_ffn.s:631`,
  `src/infer/token0_layer5_ffn.s:847`,
  `src/infer/token0_layer5_ffn_down.s:320`,
  `src/infer/token0_layer5_ffn_down.s:241`).
- Exported symbol inspection matched the ownership contract: norm activation,
  SwiGLU output, and post-FFN residual are public handoffs; gate/up/down
  projection buffers remain local private storage.
- Source size remains tight but acceptable for this pass:
  `src/infer/token0_layer5_ffn.s` is 952 lines,
  `src/infer/token0_layer5_ffn_down.s` is 475 lines,
  `src/infer/token0_layer5_attn.s` is 996 lines, and
  `src/infer/token0_layer2_attn.s` is 997 lines. Layer-6 work should start in
  focused files or Makefile-tracked fragments rather than expanding pressured
  modules.

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- `python3 -m py_compile work/oracle/*.py` passed.
- Real-target runtime/oracle comparison against
  `work/oracle/token0_layer5_post_ffn_residual_oracle.py` matched 85 labels:
  all 84 oracle-prefixed exact-hex labels plus the shared
  `attn_norm_rms_epsilon_f32_hex` value.
- Real-target output reported the reviewed descriptors as f32 `[3072]`, Q8_0
  `[3072 x 9216]`, Q8_0 `[3072 x 9216]`, and Q8_0 `[9216 x 3072]`; all reviewed
  layer-5 post-attention, FFN norm/gate/up/SwiGLU/down, and post-FFN statuses
  were `1`.
- An explicitly packed 24-byte GGUF v3 zero-count fixture kept the reviewed
  layer-5 FFN descriptor found flags and dependent statuses at `0`, and emitted
  no guarded layer-5 FFN or post-FFN residual exact-hex labels.
- `git diff --check`, static-link/no-dynamic-section/no-interpreter,
  undefined-symbol, runtime source extension, include dependency, tracked
  artifact, tracked large-file, exported/local symbol, and line-count scans
  passed.

## Residual Risk

- This completes the required two-pass review gate for the layer-5 FFN chain.
- The reviewed code still proves a token-0 smoke boundary, not reusable whole
  graph execution or text generation.
- The scalar path remains correctness-first and expensive. Optimization remains
  deferred until a useful inference path exists.
