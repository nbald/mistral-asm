# Layer-2 FFN Branch Review 2 - 2026-05-11

Scope: second review-gate pass over the completed token-0 layer-2 FFN branch
through the post-FFN residual before resuming feature work.

## Findings

- No blocking findings in this pass.

## Notes

- Exported runner contracts are present for every layer-2 FFN branch entry
  point. The contracts cover purpose, inputs, outputs, clobbers,
  ownership/lifetime, and error behavior for the RMSNorm, gate/up projections,
  SwiGLU activation, down projection, and post-FFN residual runners
  (`src/infer/token0_layer2_ffn.s:143`,
  `src/infer/token0_layer2_ffn.s:350`,
  `src/infer/token0_layer2_ffn.s:565`,
  `src/infer/token0_layer2_ffn.s:779`,
  `src/infer/token0_layer2_ffn_down.s:80`,
  `src/infer/token0_layer2_ffn_down.s:125`).
- Non-trivial internal helpers also have short contracts before the function
  body. This includes mapped payload readers, status-gated print helpers, and
  pure retained-buffer transforms, so the branch remains auditable without
  relying on commit history alone (`src/infer/token0_layer2_ffn.s:190`,
  `src/infer/token0_layer2_ffn.s:475`,
  `src/infer/token0_layer2_ffn.s:689`,
  `src/infer/token0_layer2_ffn.s:903`,
  `src/infer/token0_layer2_ffn_down.s:329`,
  `src/infer/token0_layer2_ffn_down.s:381`).
- Handoff storage is explicit enough for the next layer. The FFN module owns
  norm, gate, up, and SwiGLU buffers; the down module borrows only the exported
  SwiGLU buffer and then owns the private down output plus the exported
  post-FFN residual for later focused inference steps
  (`src/infer/token0_layer2_ffn.s:103`,
  `src/infer/token0_layer2_ffn.s:119`,
  `src/infer/token0_layer2_ffn.s:128`,
  `src/infer/token0_layer2_ffn.s:136`,
  `src/infer/token0_layer2_ffn_down.s:59`,
  `src/infer/token0_layer2_ffn_down.s:73`).
- CLI/help and smoke orchestration agree with the completed public surface:
  the layer-2 FFN branch runs after the layer-2 post-attention residual and
  before mapping release, and the help text describes published output slices
  through the post-FFN residual rather than status-only probes
  (`src/entry/start/main/smoke_orchestration.inc:409`,
  `src/entry/start/main/smoke_orchestration.inc:415`,
  `src/entry/start/rodata/cli_requests.inc:22`).
- Build inputs remain explicit. The two focused layer-2 FFN runtime modules
  are listed as standalone `.s` sources in the Makefile, and the tracked
  `.inc` fragments under `src/` are covered by Makefile dependencies
  (`Makefile:17`, `Makefile:18`, `Makefile:23`, `Makefile:67`).
- Feature work can resume after this second pass. The readiness condition is
  that new layer-3 work should start in focused layer-3 modules or
  Makefile-tracked include fragments, not by extending the near-threshold
  layer-2 attention or FFN files.

## Verification

- `make`
- `make check` passed with `q8_0_dot: ok`, `rmsnorm: ok`, `swiglu: ok`, and
  `gguf_lookup: ok`.
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime/oracle comparison for layer-2 post-attention residual,
  FFN norm, gate/up projections, SwiGLU, FFN-down projection, and post-FFN
  residual exact-hex labels was empty. The reviewed layer-2 statuses all
  printed `1`.
- A temporary 24-byte empty valid GGUF kept layer-2 FFN descriptor found flags
  and the reviewed layer-2 post-attention/FFN/post-residual statuses at `0`,
  with no guarded layer-2 exact-hex labels.
- `git diff --check`
- runtime source extension scan allowing only tracked `.s` and `.inc` files
  under `src/`
- tracked include dependency scan
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, and
  `nm -u ./mistral-asm` confirmed a static executable with no dynamic section
  and no undefined symbols.
- exported-symbol inspection for the reviewed layer-2 FFN runners, statuses,
  and retained handoff buffers
- tracked-artifact and tracked large-file scans
