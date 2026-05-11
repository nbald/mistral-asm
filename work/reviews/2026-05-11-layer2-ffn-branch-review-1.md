# Layer-2 FFN Branch Review 1 - 2026-05-11

Scope: first review-gate pass over the completed token-0 layer-2 FFN branch
through the post-FFN residual before allowing new feature scope.

## Findings

- No blocking findings in this pass.

## Notes

- Runtime ordering keeps all mapped tensor payload reads inside `_start`'s live
  GGUF mapping lifetime. The layer-2 FFN RMSNorm, gate/up projections, SwiGLU,
  down projection, and post-FFN residual all run before `gguf_release_mapping`
  (`src/entry/start/main/smoke_orchestration.inc:410`,
  `src/entry/start/main/smoke_orchestration.inc:415`,
  `src/entry/start/main/smoke_orchestration.inc:419`).
- The mapped payload readers fail closed before touching tensor bytes. The
  layer-2 FFN norm/gate/up/down smokes require prerequisite status, expected
  descriptor presence, exact type and shape, non-negative tensor-data and tensor
  offsets, overflow-free absolute offset arithmetic, a complete payload span
  inside the mapping, and a non-null mapping base before calling `rmsnorm_f32`
  or `q8_0_matvec_f32` (`src/infer/token0_layer2_ffn.s:213`,
  `src/infer/token0_layer2_ffn.s:229`,
  `src/infer/token0_layer2_ffn.s:498`,
  `src/infer/token0_layer2_ffn.s:514`,
  `src/infer/token0_layer2_ffn.s:712`,
  `src/infer/token0_layer2_ffn.s:728`,
  `src/infer/token0_layer2_ffn_down.s:404`,
  `src/infer/token0_layer2_ffn_down.s:420`).
- The pure retained-buffer steps have the expected dependency surface. SwiGLU
  waits for both gate and up projection statuses before reading module-owned
  buffers, and the post-FFN residual waits for the layer-2 post-attention
  residual plus FFN-down status before scalar f32 addition into the next
  retained residual (`src/infer/token0_layer2_ffn.s:923`,
  `src/infer/token0_layer2_ffn.s:930`,
  `src/infer/token0_layer2_ffn_down.s:347`,
  `src/infer/token0_layer2_ffn_down.s:358`).
- Public exact-hex slices are status-gated at the print side as well as the
  compute side. The layer-2 FFN norm, gate, up, SwiGLU, down, and post-FFN
  residual words print only after their matching status slot is 1
  (`src/infer/token0_layer2_ffn.s:286`,
  `src/infer/token0_layer2_ffn.s:411`,
  `src/infer/token0_layer2_ffn.s:625`,
  `src/infer/token0_layer2_ffn.s:839`,
  `src/infer/token0_layer2_ffn_down.s:265`,
  `src/infer/token0_layer2_ffn_down.s:186`).
- Oracle coverage matches the reviewed arithmetic boundary. The down oracle
  computes all layer-2 gate/up projection rows, the full 9216-word SwiGLU
  activation, then dots the first four rows of `blk.2.ffn_down.weight`; the
  post-FFN residual oracle adds those down words to the first four layer-2
  post-attention residual words with f32 rounding
  (`work/oracle/token0_layer2_ffn_down_oracle.py:113`,
  `work/oracle/token0_layer2_ffn_down_oracle.py:122`,
  `work/oracle/token0_layer2_post_ffn_residual_oracle.py:46`,
  `work/oracle/token0_layer2_post_ffn_residual_oracle.py:51`).
- Split discipline is adequate for this completed branch. The focused
  layer-2 FFN module is close to the project threshold at 943 lines, while the
  layer-2 FFN-down module is 471 lines. The second review pass should keep this
  as a readiness condition before any future feature work extends the branch.

## Verification

- `make`
- `make check` passed with `q8_0_dot: ok`, `rmsnorm: ok`, `swiglu: ok`, and
  `gguf_lookup: ok`.
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime/oracle comparison for layer-2 post-attention residual,
  FFN norm, gate/up projections, SwiGLU, FFN-down projection, and post-FFN
  residual exact-hex labels was empty. The reviewed layer-2 FFN statuses all
  printed `1`.
- A temporary 24-byte empty valid GGUF kept the layer-2 FFN descriptor found
  flags and all reviewed layer-2 FFN/post-residual statuses at `0`, with no
  guarded layer-2 exact-hex labels.
- `git diff --check`
- runtime source extension scan allowing only tracked `.s` and `.inc` files
  under `src/`
- tracked include dependency scan
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, and `nm -u ./mistral-asm`
  confirmed a static executable with no dynamic section and no undefined
  symbols.
- exported-symbol inspection for the reviewed layer-2 FFN runners, statuses,
  and retained buffers
- tracked-artifact and tracked large-file scans
