# Layer-2 Attention Branch Review 1 - 2026-05-11

Scope: first review-gate pass over the completed token-0 layer-2 attention
through post-attention residual path before allowing layer-2 FFN feature work.

## Findings

- No blocking findings in this pass.

## Notes

- The reviewed layer-2 branch still runs while `_start` owns the live GGUF mmap:
  layer-2 attention RMSNorm, query/key/value projection, context expansion,
  output projection, and post-attention residual all execute before
  `gguf_release_mapping`
  (`src/entry/start/main/smoke_orchestration.inc:403`,
  `src/entry/start/main/smoke_orchestration.inc:409`,
  `src/entry/start/main/smoke_orchestration.inc:413`).
- The tensor-payload readers require prerequisite statuses, exact tensor type and
  shape, non-negative tensor-data and tensor-relative offsets, overflow-free
  absolute offset arithmetic, and a complete payload span inside the mapping
  before passing mmap pointers to `rmsnorm_f32` or `q8_0_matvec_f32`
  (`src/infer/token0_layer2_attn.s:345`,
  `src/infer/token0_layer2_attn.s:428`,
  `src/infer/token0_layer2_attn.s:520`,
  `src/infer/token0_layer2_attn.s:612`,
  `src/infer/token0_layer2_attn_output.s:118`).
- The pure retained-buffer steps have the right dependency surface for the
  current one-token smoke: context expansion waits for a successful value
  projection and matching value/output descriptor shapes, and the post-attention
  residual waits for both the layer-1 post-FFN residual and layer-2 output
  projection statuses before reading either retained buffer
  (`src/infer/token0_layer2_attn_context.s:114`,
  `src/infer/token0_layer2_post_attn_residual.s:108`).
- Exact-hex public slices are status-gated at the print side as well as the
  compute side. The layer-2 norm, query, key, value, context, output projection,
  and post-attention residual labels only print after their matching status slot
  is 1
  (`src/infer/token0_layer2_attn.s:695`,
  `src/infer/token0_layer2_attn.s:774`,
  `src/infer/token0_layer2_attn.s:853`,
  `src/infer/token0_layer2_attn.s:932`,
  `src/infer/token0_layer2_attn_context.s:189`,
  `src/infer/token0_layer2_attn_output.s:202`,
  `src/infer/token0_layer2_post_attn_residual.s:158`).
- Oracle coverage matches the reviewed arithmetic boundary: the output oracle
  computes all 1024 layer-2 value rows, expands the single-token grouped-query
  context, then dots only the first four output-projection rows; the residual
  oracle adds those first four output words to the first four layer-1 post-FFN
  residual words with f32 rounding
  (`work/oracle/token0_layer2_attn_output_oracle.py:145`,
  `work/oracle/token0_layer2_attn_output_oracle.py:151`,
  `work/oracle/token0_layer2_attn_output_oracle.py:153`,
  `work/oracle/token0_layer2_post_attn_residual_oracle.py:43`).
- The newest layer-2 context, output, and residual modules stay well below the
  project split threshold. `src/infer/token0_layer2_attn.s` remains at 997 lines,
  so the next layer-2 FFN work should continue in focused modules instead of
  extending that near-limit file.

## Verification

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime smoke showed all reviewed layer-2 attention descriptors
  present with expected shapes/types, all reviewed layer-2 statuses at `1`, and
  the public layer-2 output/residual words
  `0x3eade180`, `0x3ee0fb2f`, `0xbff22222`, `0x3e24eb6b`,
  `0x3e9885c8`, `0xbd0e0bd8`, `0x3e299d00`, and `0x3d544d6e`.
- `python3 work/oracle/token0_layer2_post_attn_residual_oracle.py <local target>`
  reproduced the reviewed layer-2 attention output and post-attention residual
  words exactly; the normalized runtime/oracle diff was empty.
- A temporary 24-byte empty valid GGUF kept all reviewed layer-2 descriptor found
  flags and statuses at `0`, with no guarded layer-2 exact-hex labels.
- `git diff --check`
- runtime source extension scan allowing only tracked `.s` and `.inc` files under
  `src/`
- tracked include dependency scan
- static-link/no-dynamic-section and undefined-symbol checks
- exported-symbol inspection for the layer-2 attention/context/output/residual
  runners, statuses, and buffers
- tracked-artifact and tracked large-file scans
