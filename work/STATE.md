# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add descriptor-only lookup coverage for `blk.2.attn_norm.weight` as the first
layer-2 setup step, without reading tensor payload bytes.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- The narrow GGUF v3 little-endian loader records metadata, tensor directory
  offsets, fixed layer-0 descriptors, and reusable named descriptor lookups.
- Token-0 layer-0 forward smoke coverage reaches post-FFN residual and is
  covered by external oracle notes/scripts.
- Token-0 layer-1 coverage reaches FFN RMSNorm slice publication. The external
  oracle recomputes the full layer-1 attention output and residual before
  checking the first four FFN norm words, and it matches the runtime.
- A newer operator inbox entry stopped feature work and requested two
  consecutive repository-wide review passes before any new feature work. Pass 1
  is recorded in `work/reviews/2026-05-11-repository-wide-review-1.md`.
- Repository-wide review pass 2 is recorded in
  `work/reviews/2026-05-11-repository-wide-review-2.md`. The required
  two-pass review gate is complete.
- The first behavior-preserving `_start.s` responsibility split is complete:
  generic text/output helpers now live in `src/runtime/text.s`, and the
  runtime link includes that module.
- Descriptor-only reusable lookup coverage now includes
  `blk.1.ffn_gate.weight` and `blk.1.ffn_up.weight`. Each descriptor is stored
  in a separate layer-1 scratch slot and printed as found/dimension/type/offset
  summary lines without reading payload bytes.
- A newer operator inbox instruction to stop adding subsystem-specific runtime
  logic, buffers, or printers to `_start.s` has been made durable. New feature
  work should prefer focused modules such as `src/infer/` when feasible.
- Status-only layer-1 FFN gate matvec coverage now lives in
  `src/infer/token0_layer1_ffn.s`. It consumes the existing private
  `token0_layer1_ffn_norm_activation`, reads `blk.1.ffn_gate.weight` only after
  descriptor/type/shape/bounds checks, writes a private layer-1 FFN gate output
  buffer, stores a private status word, and prints only
  `token0_layer1_ffn_gate_matvec`.
- The un-cleared transient operator instruction to split `_start.s` before new
  feature work was treated as active, encoded durably here, and handled for this
  iteration by moving the existing token-0 layer-1 FFN RMSNorm smoke routine
  into `src/infer/token0_layer1_ffn.s`. `_start.s` now exports the handoff slots
  that the focused inference code already consumed logically.
- The layer-1 FFN norm status printer and four-word exact-hex slice printer now
  live beside the FFN norm smoke in `src/infer/token0_layer1_ffn.s`. `_start.s`
  preserves the same output position through a single focused wrapper call, and
  all public diagnostic labels and values are unchanged.
- Status-only layer-1 FFN up matvec coverage now lives beside the gate path in
  `src/infer/token0_layer1_ffn.s`. `_start.s` exports only the needed
  `blk.1.ffn_up.weight` descriptor handoff fields and calls the focused up
  status wrapper immediately after the existing gate status line.
- The layer-1 FFN gate matvec wrapper now also prints a guarded first-four
  exact-hex slice from the private `token0_layer1_ffn_gate_output` buffer when
  its status is 1. The new gate output words appear after
  `token0_layer1_ffn_gate_matvec: 1` and before the existing up status line,
  matching the layer-0 FFN diagnostic order.
- The oversized entry source has been split without behavior changes:
  `src/entry/_start.s` is now an 8-line include driver, and the former contents
  live under `src/entry/start/` as responsibility-named fragments. The fragments
  are still assembled as one translation unit, so local labels and diagnostic
  ordering are preserved.
- The remaining large structural files have had a second behavior-preserving
  split pass: `src/gguf/load_header.s` is now an include driver, and the largest
  entry fragments (`main.inc`, `rodata.inc`, `output_slices.inc`, and
  `token0_smokes.inc`) now delegate to smaller responsibility-named fragments.
  `work/prompts/continue.md` now requires splitting or moving focused work
  before adding substantial code to files near or above 1000 lines, and requires
  Makefile dependencies for introduced include fragments.
- The layer-1 FFN up matvec wrapper now also prints a guarded first-four
  exact-hex slice from the private `token0_layer1_ffn_up_output` buffer when
  its status is 1. The new up output words appear after
  `token0_layer1_ffn_up_matvec: 1`, matching the layer-0 FFN diagnostic order.
- Status-only layer-1 FFN SwiGLU coverage now lives beside the layer-1 FFN
  gate/up paths in `src/infer/token0_layer1_ffn.s`. It consumes only the
  private layer-1 FFN gate/up output buffers, writes a private
  `token0_layer1_ffn_swiglu_output` buffer and status word, and prints only
  `token0_layer1_ffn_swiglu`.
- The layer-1 FFN SwiGLU wrapper now also prints a guarded first-four exact-hex
  slice from the private `token0_layer1_ffn_swiglu_output` buffer when its
  status is 1. The new words appear immediately after
  `token0_layer1_ffn_swiglu: 1`, and the help milestone line now describes the
  layer-1 FFN SwiGLU output slice.
- Descriptor-only reusable lookup coverage now includes
  `blk.1.ffn_down.weight`. The descriptor is stored in a separate layer-1
  scratch slot and printed as found/dimension/type/offset summary lines after
  the existing layer-1 FFN gate/up descriptor summaries without reading payload
  bytes.
- Status-only layer-1 FFN down matvec coverage now lives in a focused
  `src/infer/token0_layer1_ffn_down.s` module instead of growing the existing
  layer-1 FFN module past the 1000-line threshold. It consumes the private
  layer-1 SwiGLU activation and the focused `blk.1.ffn_down.weight` descriptor
  only after descriptor/type/shape/bounds checks, writes a private down output
  buffer and status word, and prints only `token0_layer1_ffn_down_matvec`.
- The layer-1 FFN down matvec wrapper now also prints a guarded first-four
  exact-hex slice from the private `token0_layer1_ffn_down_output` buffer when
  its status is 1. The new words appear immediately after
  `token0_layer1_ffn_down_matvec: 1`, and the help milestone line now
  describes layer-1 FFN SwiGLU/down output slices.
- Status-only layer-1 post-FFN residual coverage now lives beside the focused
  layer-1 FFN down path in `src/infer/token0_layer1_ffn_down.s`. It consumes
  `token0_layer1_post_attn_residual_status`,
  `token0_layer1_ffn_down_matvec_status`,
  `token0_layer1_post_attn_residual`, and
  `token0_layer1_ffn_down_output`, writes a reusable
  `token0_layer1_post_ffn_residual` buffer plus status word, and prints exactly
  one `token0_layer1_post_ffn_residual` status line after the down output slice.
- The layer-1 post-FFN residual wrapper now also prints a guarded first-four
  exact-hex slice from the private `token0_layer1_post_ffn_residual` buffer when
  its status is 1. The new words appear immediately after
  `token0_layer1_post_ffn_residual: 1`, and the help milestone line now
  describes the layer-1 post-FFN residual output slice.
- Review gate pass 1 over the completed layer-1 FFN down and post-FFN residual
  slice path is recorded in
  `work/reviews/2026-05-11-layer1-ffn-down-review-1.md`. It found no runtime
  bounds or status-gating blocker, but it found a durable oracle coverage gap
  for the committed layer-1 FFN gate/up/SwiGLU/down and post-FFN residual
  public diagnostics.
- Durable external oracle coverage for the completed token-0 layer-1 FFN branch
  now lives in `work/oracle/token0_layer1_post_ffn_residual_oracle.py` and
  `work/oracle/token0-layer1-post-ffn-residual.md`. It reuses the layer-1 FFN
  norm oracle's full retained arrays, computes layer-1 gate/up/SwiGLU/down and
  post-FFN residual slices, and its public oracle words match the current
  runtime output exactly for the local target GGUF.
- Review gate pass 1 over the completed token-0 layer-1 FFN branch, including
  the durable oracle script/note and runtime slice comparison evidence, is
  recorded in `work/reviews/2026-05-11-layer1-ffn-branch-review-1.md`. It found
  no blocking runtime, oracle, status-gating, or branch-ordering issue.
- Review gate pass 2 over the completed token-0 layer-1 FFN branch is recorded
  in `work/reviews/2026-05-11-layer1-ffn-branch-review-2.md`. It found no
  blocking runtime/oracle ordering, guard, or maintainability issue. The required
  two-pass review gate is complete.

## Known Blockers

- No current blocker to starting layer-2 descriptor-only setup work.
- Residual maintainability risk remains in
  `src/gguf/load_header/tensor_infos.inc` because it is still over 1000 lines,
  but it is a single coherent tensor-directory walker and should be reduced with
  helper extraction only when changing that logic.

## Relevant Files

- `src/entry/_start.s`
- `src/entry/start/*.inc`
- `src/entry/start/main/*.inc`
- `src/entry/start/rodata/*.inc`
- `src/entry/start/output_slices/*.inc`
- `src/entry/start/token0_smokes/*.inc`
- `src/gguf/load_header.s`
- `src/gguf/load_header/*.inc`
- `src/infer/token0_layer1_ffn.s`
- `src/infer/token0_layer1_ffn_down.s`
- `src/math/q8_0_dot.s`
- `src/math/rmsnorm.s`
- `src/math/swiglu.s`
- `src/runtime/text.s`
- `src/sys/*.s`
- `tests/*.s`
- `Makefile`
- `work/oracle/`
- `work/oracle/token0_layer1_post_ffn_residual_oracle.py`
- `work/oracle/token0-layer1-post-ffn-residual.md`
- `work/reviews/2026-05-11-layer1-ffn-branch-review-1.md`
- `work/reviews/2026-05-11-layer1-ffn-branch-review-2.md`
- `work/reviews/2026-05-11-layer1-ffn-down-review-1.md`
- `work/reviews/2026-05-11-repository-wide-review-1.md`
- `work/reviews/2026-05-11-repository-wide-review-2.md`
- `work/STATE.md`
- `work/WORKLOG.md`
- `work/prompts/continue.md`

## Last Verification

- Review pass 2 verification passed: `make`; `make check`;
  `./mistral-asm --help`; `python3 -m py_compile work/oracle/*.py`; real target
  runtime smoke for the layer-1 FFN branch; exact scalar oracle run for
  `work/oracle/token0_layer1_post_ffn_residual_oracle.py` against the local
  target GGUF; runtime layer-1 FFN gate/up/SwiGLU/down and post-FFN residual
  words matched the oracle exactly; a temporary 24-byte empty valid GGUF kept
  the reviewed branch statuses at `0` and emitted no guarded layer-1 FFN output
  word labels; `git diff --check`; runtime source extension scan allowing `.s`
  drivers and tracked `.inc` fragments; static-link/no-dynamic-section check;
  undefined-symbol check; exported-symbol inspection; tracked-artifact and
  tracked large-file checks.

## Next Exact Step

Add descriptor-only reusable lookup coverage for `blk.2.attn_norm.weight`,
store it in a separate layer-2 scratch slot, and print found/dimension/type/offset
summary lines without reading payload bytes.
