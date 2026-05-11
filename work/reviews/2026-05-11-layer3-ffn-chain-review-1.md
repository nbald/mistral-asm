# Layer-3 FFN Chain Review 1 - 2026-05-11

Scope: first review-gate pass over the completed token-0 layer-3 FFN branch
through the guarded FFN down projection and post-FFN residual slice before any
next-layer feature work resumes.

## Findings

- No blocking findings in this pass.
- No source changes were required. The reviewed chain remains status-gated,
  mapping-lifetime-bound, and split between the focused FFN and FFN-down
  modules.

## Notes

- Runtime orchestration preserves the dependency order for the reviewed chain:
  layer-3 post-attention residual, FFN RMSNorm, gate/up projections, SwiGLU,
  FFN down projection, and post-FFN residual all execute before the GGUF mapping
  is released (`src/entry/start/main/smoke_orchestration.inc:422`,
  `src/entry/start/main/smoke_orchestration.inc:423`,
  `src/entry/start/main/smoke_orchestration.inc:427`,
  `src/entry/start/main/smoke_orchestration.inc:428`,
  `src/entry/start/main/smoke_orchestration.inc:430`).
- Descriptor setup stays descriptor-only until guarded smoke functions consume
  payload bytes. The layer-3 bootstrap captures FFN norm, gate, up, and down
  tensor descriptors into retained static slots, and the focused runtime
  functions later recheck type and shape before use
  (`src/entry/start/main/bootstrap/layer3.inc:106`,
  `src/entry/start/main/bootstrap/layer3.inc:127`,
  `src/entry/start/main/bootstrap/layer3.inc:148`,
  `src/entry/start/main/bootstrap/layer3.inc:169`,
  `src/entry/start/state/layer3_bss.inc:107`,
  `src/entry/start/state/layer3_bss.inc:128`,
  `src/entry/start/state/layer3_bss.inc:149`,
  `src/entry/start/state/layer3_bss.inc:170`).
- Mapped payload readers fail closed before calling math helpers. The layer-3
  FFN RMSNorm, gate, up, and down smokes require prerequisite statuses, found
  flags, exact GGML type and shape, non-negative tensor-data and tensor-relative
  offsets, overflow-free absolute offset arithmetic, a complete payload span
  inside the mapping, and a non-null mmap base
  (`src/infer/token0_layer3_ffn.s:212`,
  `src/infer/token0_layer3_ffn.s:228`,
  `src/infer/token0_layer3_ffn.s:247`,
  `src/infer/token0_layer3_ffn.s:497`,
  `src/infer/token0_layer3_ffn.s:513`,
  `src/infer/token0_layer3_ffn.s:542`,
  `src/infer/token0_layer3_ffn.s:712`,
  `src/infer/token0_layer3_ffn.s:728`,
  `src/infer/token0_layer3_ffn.s:757`,
  `src/infer/token0_layer3_ffn_down.s:405`,
  `src/infer/token0_layer3_ffn_down.s:422`,
  `src/infer/token0_layer3_ffn_down.s:451`).
- Pure retained-buffer stages have the intended dependency surface. SwiGLU waits
  for both layer-3 gate and up projection statuses before combining private
  buffers, and the post-FFN residual waits for the layer-3 post-attention
  residual plus FFN-down status before scalar f32 addition into retained output
  storage (`src/infer/token0_layer3_ffn.s:922`,
  `src/infer/token0_layer3_ffn.s:929`,
  `src/infer/token0_layer3_ffn_down.s:348`,
  `src/infer/token0_layer3_ffn_down.s:356`,
  `src/infer/token0_layer3_ffn_down.s:359`).
- Public exact-hex slices are status-gated at the print side. The reviewed
  FFN RMSNorm, gate, up, SwiGLU, down, and post-FFN residual print helpers emit
  fixed four-word slices only after their owning status is 1
  (`src/infer/token0_layer3_ffn.s:285`,
  `src/infer/token0_layer3_ffn.s:410`,
  `src/infer/token0_layer3_ffn.s:625`,
  `src/infer/token0_layer3_ffn.s:838`,
  `src/infer/token0_layer3_ffn_down.s:266`,
  `src/infer/token0_layer3_ffn_down.s:187`).
- Oracle coverage matches the arithmetic boundary. The FFN-down oracle computes
  all 9216 layer-3 gate/up rows, the complete SwiGLU activation, and the first
  four down rows; the post-FFN residual oracle then adds the matching layer-3
  post-attention residual and down words with scalar f32 rounding
  (`work/oracle/token0_layer3_ffn_down_oracle.py:117`,
  `work/oracle/token0_layer3_ffn_down_oracle.py:120`,
  `work/oracle/token0_layer3_ffn_down_oracle.py:130`,
  `work/oracle/token0_layer3_post_ffn_residual_oracle.py:53`,
  `work/oracle/token0_layer3_post_ffn_residual_oracle.py:58`).
- Split discipline is acceptable for the second review pass. The near-threshold
  layer-3 FFN module remains at 942 lines, while down/residual work lives in the
  focused 473-line module. Future substantial layer-3 work should continue in a
  focused module rather than extending near-threshold files.

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- Post-documentation `make all check` passed with the same harness results.
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime/oracle comparison for layer-3 post-attention residual,
  FFN RMSNorm, gate/up projections, SwiGLU, FFN down projection, and post-FFN
  residual exact-hex labels was empty. The real target reported all reviewed
  layer-3 FFN descriptors and statuses at `1`; `blk.3.ffn_down.weight` still
  reported output dimension `3072`.
- A temporary 24-byte empty valid GGUF kept the reviewed layer-3 FFN descriptor
  found flags and dependent statuses at `0`, and emitted no guarded layer-3
  FFN or post-FFN residual exact-hex labels.
- `git diff --check`
- Runtime source extension scan allowed only tracked `.s` and `.inc` files
  under `src/`.
- Tracked include dependency scan covered `.include` fragments in `Makefile`.
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, and
  `nm -u ./mistral-asm` confirmed a static executable with no dynamic section
  and no undefined symbols.
- Exported-symbol inspection covered the reviewed layer-3 FFN runner entry
  points, statuses, and retained handoff buffers.
- Source line-count check passed with the known near-threshold files and
  tensor-directory walker exception unchanged.
- Tracked artifact and tracked large-file scans passed.

## Residual Risk

- This pass does not prove a full layer-4 handoff or token generation; it covers
  the completed token-0 layer-3 FFN branch only.
- The scalar smoke path remains intentionally correctness-first and expensive.
  Optimization is deferred until after the first useful inference path exists.
- The second review-gate pass should independently recheck the same chain before
  feature work resumes.
