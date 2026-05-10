# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Begin the behavior-preserving `_start.s` reorganization by extracting generic
entry/output helper functions into a focused runtime `.s` module and updating
the `Makefile` without changing runtime output.

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

## Known Blockers

- Feature work remains stopped until at least one behavior-preserving split
  reduces `_start.s` responsibility before adding layer-1 FFN gate/up descriptor
  coverage.
- Both repository-wide review passes found the same important maintainability
  blocker: `src/entry/_start.s` is 8,176 lines and now owns entry dispatch,
  descriptor lookup sequencing, descriptor/slice printing, static runtime
  buffers, and token-0 smoke orchestration.

## Relevant Files

- `src/entry/_start.s`
- `src/gguf/load_header.s`
- `src/math/q8_0_dot.s`
- `src/math/rmsnorm.s`
- `src/math/swiglu.s`
- `src/sys/*.s`
- `tests/*.s`
- `Makefile`
- `work/oracle/`
- `work/reviews/2026-05-11-repository-wide-review-1.md`
- `work/reviews/2026-05-11-repository-wide-review-2.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

- Repository-wide review pass 2 verification passed: `make clean && make &&
  make check`; `./mistral-asm --help`; real target smoke filtered to the
  current layer-1 handoff labels, showing `layer1_ffn_norm_tensor_found: 1`,
  `token0_layer1_attn_output_matvec: 1`,
  `token0_layer1_post_attn_residual: 1`,
  `token0_layer1_ffn_norm: 1`, and words `0xbec8ddb4`, `0xc11f7d85`,
  `0x40d46234`, `0xbfe2ec8e`; oracle py-compile; runtime `.s` purity scan;
  static-link inspection; tracked-artifact and large-file scans; and
  `git diff --check`.

## Next Exact Step

Move `str_eq_exact`, `write_u64_decimal`, `write_u32_hex`, and
`write_bounded_c_string` out of `src/entry/_start.s` into a new focused runtime
`.s` module, update the `Makefile`, and verify that help output and the current
target smoke output are unchanged.
