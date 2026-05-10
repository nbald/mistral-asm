# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add descriptor-only reusable lookup coverage for `blk.1.ffn_gate.weight` and
`blk.1.ffn_up.weight`, storing separate layer-1 descriptor slots and printing
found/dim/type/offset summaries without reading payload bytes.

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

## Known Blockers

- No current blocker for the next descriptor-only feature step.
- Residual maintainability risk remains: `src/entry/_start.s` still owns entry
  dispatch, descriptor lookup sequencing, descriptor/slice printing, static
  runtime buffers, and token-0 smoke orchestration. Prefer further
  behavior-preserving splits before large graph expansions.

## Relevant Files

- `src/entry/_start.s`
- `src/gguf/load_header.s`
- `src/math/q8_0_dot.s`
- `src/math/rmsnorm.s`
- `src/math/swiglu.s`
- `src/runtime/text.s`
- `src/sys/*.s`
- `tests/*.s`
- `Makefile`
- `work/oracle/`
- `work/reviews/2026-05-11-repository-wide-review-1.md`
- `work/reviews/2026-05-11-repository-wide-review-2.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

- Behavior-preserving helper split verification passed: `make clean && make`;
  `./mistral-asm --help` matched the pre-split baseline exactly; real target
  smoke filtered to the current layer-1 handoff labels matched the pre-split
  baseline exactly, showing `layer1_ffn_norm_tensor_found: 1`,
  `token0_layer1_attn_output_matvec: 1`,
  `token0_layer1_post_attn_residual: 1`,
  `token0_layer1_ffn_norm: 1`, and words `0xbec8ddb4`, `0xc11f7d85`,
  `0x40d46234`, `0xbfe2ec8e`; `make check`; `git diff --check`; runtime
  source purity scan; static-link inspection; tracked-artifact and large-file
  scans; and exported-symbol inspection for `build/runtime/text.o`.

## Next Exact Step

Add descriptor-only reusable lookup coverage for `blk.1.ffn_gate.weight` and
`blk.1.ffn_up.weight`, storing separate layer-1 descriptor slots and printing
found/dim/type/offset summaries without reading payload bytes.
