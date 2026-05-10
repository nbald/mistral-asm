# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add a retained descriptor for `blk.0.attn_norm.weight` so the runtime can find
the first layer RMSNorm weights. Do not apply RMSNorm in `_start` yet.

## Completed Work

- The runtime remains pure GNU `as` Intel assembly and is built with `as` plus
  `ld`; `_start` uses Linux syscalls directly.
- The GGUF loader validates the narrow v3 little-endian target shape, walks
  metadata and tensor-info descriptors with bounds checks, records the aligned
  tensor-data base, and returns a live read-only mapping descriptor to `_start`.
- The summary captures tensor count, metadata count, architecture, context
  length, block/layer count, tokenizer vocabulary size, first tensor descriptor,
  and a retained descriptor for `token_embd.weight`.
- The tensor directory walker still validates all descriptors after the retained
  lookup and rejects malformed later descriptors, misaligned payload offsets,
  and payload starts beyond EOF.
- Scalar Q8_0 math covers block dot, row dot, row-major matvec, row dequant, and
  checked token-embedding dequantization, with no-libc assembly fixtures in
  `make check-q8_0-dot`.
- Scalar f32 RMSNorm exists as a documented assembly primitive, is linked into
  the runtime object set, and is covered by a no-libc harness in
  `make check-rmsnorm`; `_start` does not call it yet.
- `_start` keeps the validated model mapping live through summary output, runs a
  guarded token ID 0 `token_embd.weight` dequant smoke into static f32 activation
  storage, prints `token0_embedding_dequant: 1` when the smoke runs, then calls
  `gguf_release_mapping`.
- The token-0 smoke requires a retained two-dimensional Q8_0 descriptor, a
  nonzero 32-multiple embedding width no larger than the static 3072-f32 buffer,
  a nonzero row count, non-overflowing tensor-data-base plus relative offset,
  and one complete Q8_0 row inside the mmap before calling the math helper.
- Narrow synthetic GGUF fixtures that are useful for parser smoke checks but are
  not target-shaped skip the payload smoke and print a zero
  `token0_embedding_dequant` status while preserving their summary behavior.

## Known Blockers

None.

## Relevant Files

- `src/entry/_start.s`
- `src/gguf/load_header.s`
- `src/math/q8_0_dot.s`
- `src/math/rmsnorm.s`
- `tests/q8_0_dot_harness.s`
- `tests/rmsnorm_harness.s`
- `Makefile`
- `work/STATE.md`
- `work/WORKLOG.md`

## Required Verification

- Rebuild with `as`/`ld`.
- Keep `make check`, including the Q8_0 and RMSNorm harnesses, GGUF loader
  lookup/base-offset smoke checks, future CLI usage rejection, static-link
  checks, and whitespace checks passing.
- Smoke-test the real target GGUF when the ignored local model remains present.
- Verify explicit cleanup of any live model mapping.

## Last Verification

- `make clean`, `make`, and `make check` passed; the harnesses printed
  `q8_0_dot: ok` and `rmsnorm: ok`.
- `./mistral-asm --help` returned status 0 and describes the
  token-embedding dequant smoke milestone.
- Invoking the future prompt generation form returned the usage error with
  status 2.
- Synthetic fixtures `/tmp/mistral_asm_tensor_base_round.gguf`,
  `/tmp/mistral_asm_lookup_found.gguf`, and
  `/tmp/mistral_asm_lookup_absent.gguf` returned status 0 and printed
  `token0_embedding_dequant: 0`.
- Synthetic fixtures `/tmp/mistral_asm_lookup_malformed_later.gguf` and
  `/tmp/mistral_asm_offset_beyond_eof.gguf` returned status 3 with the expected
  tensor-directory diagnostics.
- The real target model under `models/` returned status 0, retained
  `token_embd.weight` as Q8_0 with dimensions 3072 and 131072, and printed
  `token0_embedding_dequant: 1`.
- `strace -e trace=mmap,munmap,close` on the real target showed `mmap`,
  `close(3) = 0`, the summary plus successful dequant smoke, then
  `munmap(..., 3651679520) = 0`.
- `readelf -d` reported no dynamic section; `readelf -l` reported no interpreter
  or dynamic program headers.
- `git diff --check` passed.

## Next Exact Step

Add a retained descriptor for `blk.0.attn_norm.weight` so the runtime can find
the first layer RMSNorm weights. Do not apply RMSNorm in `_start` yet.
