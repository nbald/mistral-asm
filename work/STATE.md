# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish the first guarded token-0 layer-2 attention value output slice and add
durable oracle coverage for the first four `blk.2.attn_v.weight` rows.

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
- Descriptor-only reusable lookup coverage now includes
  `blk.2.attn_norm.weight` as the first layer-2 setup step. The descriptor is
  stored in a separate layer-2 scratch slot and printed as
  found/dimension/type/offset summary lines without reading payload bytes; the
  new print routine lives in a focused lookup-summary include to avoid growing
  the existing summary file toward the 1000-line threshold.
- Status-only token-0 layer-2 attention RMSNorm coverage now lives in
  `src/infer/token0_layer2_attn.s`. It consumes the retained layer-1 post-FFN
  residual and the focused `blk.2.attn_norm.weight` descriptor only after
  prerequisite status, epsilon, descriptor/type/shape, mapping-base, and full
  f32 payload bounds checks, writes a private activation buffer plus status
  word, and prints only `token0_layer2_attn_norm`.
- The layer-2 attention RMSNorm wrapper now also prints a guarded first-four
  exact-hex slice from the private `token0_layer2_attn_norm_activation` buffer
  when its status is 1. Durable external oracle coverage lives in
  `work/oracle/token0_layer2_attn_norm_oracle.py` and
  `work/oracle/token0-layer2-attn-norm.md`; the oracle recomputes the full
  layer-1 post-FFN residual before applying `blk.2.attn_norm.weight`, and its
  public words match the runtime output exactly.
- Descriptor-only reusable lookup coverage now includes `blk.2.attn_q.weight`.
  The descriptor is stored in a separate exported layer-2 scratch slot and
  printed as found/dimension/type/offset summary lines after the layer-2
  attention RMSNorm descriptor without reading payload bytes. On the local
  target GGUF it reports found `1`, two dimensions `3072` and `4096`, Q8_0 type
  `8`, and relative offset `691937280`.
- Status-only token-0 layer-2 attention query matvec coverage now lives beside
  the layer-2 attention RMSNorm path in `src/infer/token0_layer2_attn.s`. It
  consumes `token0_layer2_attn_norm_activation` and the focused
  `blk.2.attn_q.weight` descriptor only after prerequisite status,
  descriptor/type/shape, mapping-base, and full Q8_0 payload bounds checks,
  writes a private 4096-f32 query output buffer plus status word, and prints
  only `token0_layer2_attn_q_matvec`.
- The layer-2 attention query matvec wrapper now also prints a guarded
  first-four exact-hex slice from the private `token0_layer2_attn_q_output`
  buffer when its status is 1. Durable external oracle coverage lives in
  `work/oracle/token0_layer2_attn_q_oracle.py` and
  `work/oracle/token0-layer2-attn-q-output.md`; the oracle recomputes the full
  layer-1 post-FFN residual, applies layer-2 attention RMSNorm, dots the first
  four rows of `blk.2.attn_q.weight`, and matches the runtime output exactly.
- Descriptor-only reusable lookup coverage now includes `blk.2.attn_k.weight`.
  The descriptor is stored in a separate exported layer-2 scratch slot and
  printed as found/dimension/type/offset summary lines after the layer-2 query
  descriptor without reading payload bytes. On the local target GGUF it reports
  found `1`, two dimensions `3072` and `1024`, Q8_0 type `8`, and relative
  offset `675213312`.
- Status-only token-0 layer-2 attention key matvec coverage now lives beside
  the layer-2 attention RMSNorm/query paths in `src/infer/token0_layer2_attn.s`.
  It consumes `token0_layer2_attn_norm_activation` and the focused
  `blk.2.attn_k.weight` descriptor only after prerequisite status,
  descriptor/type/shape, mapping-base, and full Q8_0 payload bounds checks,
  writes a private 1024-f32 key output buffer plus status word, and prints only
  `token0_layer2_attn_k_matvec`.
- The layer-2 attention key matvec wrapper now also prints a guarded first-four
  exact-hex slice from the private `token0_layer2_attn_k_output` buffer when
  its status is 1. Durable external oracle coverage lives in
  `work/oracle/token0_layer2_attn_k_oracle.py` and
  `work/oracle/token0-layer2-attn-k-output.md`; the oracle recomputes the full
  layer-1 post-FFN residual, applies layer-2 attention RMSNorm, dots the first
  four rows of `blk.2.attn_k.weight`, and matches the runtime output exactly.
- Descriptor-only reusable lookup coverage now includes `blk.2.attn_v.weight`.
  The descriptor is stored in a separate exported layer-2 scratch slot and
  printed as found/dimension/type/offset summary lines after the layer-2 key
  descriptor without reading payload bytes. On the local target GGUF it reports
  found `1`, two dimensions `3072` and `1024`, Q8_0 type `8`, and relative
  offset `705306624`.
- Status-only token-0 layer-2 attention value matvec coverage now lives beside
  the layer-2 attention RMSNorm/query/key paths in
  `src/infer/token0_layer2_attn.s`. It consumes
  `token0_layer2_attn_norm_activation` and the focused
  `blk.2.attn_v.weight` descriptor only after prerequisite status,
  descriptor/type/shape, mapping-base, and full Q8_0 payload bounds checks,
  writes a private 1024-f32 value output buffer plus status word, and prints
  only `token0_layer2_attn_v_matvec`.

## Known Blockers

- No current blocker to publishing the first guarded layer-2 attention value
  output slice.
- Residual maintainability risk remains in
  `src/gguf/load_header/tensor_infos.inc` because it is still over 1000 lines,
  but it is a single coherent tensor-directory walker and should be reduced with
  helper extraction only when changing that logic.

## Relevant Files

- `src/entry/_start.s`
- `src/entry/start/*.inc`
- `src/entry/start/main/*.inc`
- `src/entry/start/lookup_summary/*.inc`
- `src/entry/start/rodata/*.inc`
- `src/entry/start/output_slices/*.inc`
- `src/entry/start/token0_smokes/*.inc`
- `src/gguf/load_header.s`
- `src/gguf/load_header/*.inc`
- `src/infer/token0_layer1_ffn.s`
- `src/infer/token0_layer1_ffn_down.s`
- `src/infer/token0_layer2_attn.s`
- `src/math/q8_0_dot.s`
- `src/math/rmsnorm.s`
- `src/math/swiglu.s`
- `src/runtime/text.s`
- `src/sys/*.s`
- `tests/*.s`
- `Makefile`
- `work/oracle/`
- `work/oracle/token0_layer2_attn_norm_oracle.py`
- `work/oracle/token0-layer2-attn-norm.md`
- `work/oracle/token0_layer2_attn_q_oracle.py`
- `work/oracle/token0-layer2-attn-q-output.md`
- `work/oracle/token0_layer2_attn_k_oracle.py`
- `work/oracle/token0-layer2-attn-k-output.md`
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

Layer-2 attention value matvec status verification passed: `make`;
`make check`; `./mistral-asm --help`;
`python3 -m py_compile work/oracle/*.py`; real target runtime smoke preserving
the existing layer-2 RMSNorm/query/key outputs and reporting
`token0_layer2_attn_v_matvec: 1`; temporary 24-byte empty valid GGUF reporting
zeroed layer-2 norm/query/key/value descriptor fields,
`token0_layer2_attn_norm: 0`, `token0_layer2_attn_q_matvec: 0`,
`token0_layer2_attn_k_matvec: 0`, and `token0_layer2_attn_v_matvec: 0` with no
guarded layer-2 output labels; `git diff --check`; runtime source extension
scan allowing `.s` drivers and tracked `.inc` fragments; tracked include
dependency scan; static-link/no-dynamic-section/file check; undefined-symbol
check; exported-symbol inspection for the layer-2 value matvec/status/output
symbols; tracked-artifact and tracked large-file checks.

## Next Exact Step

Publish a guarded first-four exact-hex slice from
`token0_layer2_attn_v_output` in `src/infer/token0_layer2_attn.s`: add labels
and a printer called only after `token0_layer2_attn_v_matvec_status` is 1, keep
the empty-GGUF path free of value output labels, and add durable external oracle
coverage comparing the first four `blk.2.attn_v.weight` rows against runtime
output.
