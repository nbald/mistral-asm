# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add a guarded token-0 query projection matvec smoke using the retained
`blk.0.attn_q.weight` descriptor and `token0_attn_norm_activation`, write into
static output storage, and print a status. Leave numerical oracle comparison for
a later atomic step.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and
  linked with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, walks
  metadata and tensor descriptors with bounds checks, records the aligned
  tensor-data base, and returns a live read-only mapping descriptor to `_start`.
- The summary captures tensor and metadata counts, architecture, context length,
  layer count, vocab size, tensor-data base, the first tensor descriptor,
  `token_embd.weight`, `blk.0.attn_norm.weight`, `blk.0.attn_q.weight`, and
  `mistral3.attention.layer_norm_rms_epsilon` as a found flag plus exact f32
  bits.
- Scalar Q8_0 helpers cover block dot, row dot, row-major matvec, row dequant,
  and checked token-embedding dequantization with no-libc verifier coverage.
- Scalar f32 RMSNorm exists as a documented primitive with no-libc verifier
  coverage.
- `_start` prints the retained summary fields, keeps the model mapping live
  through guarded token ID 0 embedding dequantization and first attention
  RMSNorm smokes, loads RMSNorm epsilon from the captured metadata, prints the
  retained first-layer attention query projection descriptor, then calls
  `gguf_release_mapping`.
- Synthetic parser fixtures that are not target-shaped skip payload smokes and
  print zero smoke statuses while preserving summary behavior.

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
- Keep `make check`, static-link checks, future CLI usage rejection, GGUF smoke
  checks, and whitespace checks passing.
- Smoke-test the real target GGUF when the ignored local model remains present.
- Verify explicit cleanup of any live model mapping.

## Last Verification

- `make clean`, `make`, and `make check` passed; the harnesses printed
  `q8_0_dot: ok` and `rmsnorm: ok`.
- `./mistral-asm --help` returned status 0; the future prompt generation form
  returned status 2 with the usage diagnostic.
- `readelf -d` reported no dynamic section, and `readelf -l` reported no
  interpreter or dynamic program headers.
- Synthetic fixtures `/tmp/mistral_asm_tensor_base_round.gguf`,
  `/tmp/mistral_asm_lookup_found.gguf`, and
  `/tmp/mistral_asm_lookup_absent.gguf` returned status 0, printed
  `attn_norm_rms_epsilon_found: 0`,
  `attn_norm_rms_epsilon_f32_hex: 0x00000000`, kept
  `attn_q_tensor_found: 0`, and kept
  `token0_embedding_dequant: 0` plus `token0_attn_norm: 0`.
- Synthetic malformed fixtures
  `/tmp/mistral_asm_lookup_malformed_later.gguf` and
  `/tmp/mistral_asm_offset_beyond_eof.gguf` returned status 3 with tensor
  directory diagnostics.
- The real target model under `models/` returned status 0, printed
  `attn_norm_rms_epsilon_found: 1`,
  `attn_norm_rms_epsilon_f32_hex: 0x3727c5ac`, retained
  `token_embd.weight` as Q8_0 with dimensions 3072 and 131072, retained
  `blk.0.attn_norm.weight` as f32 with dimension 3072, retained
  `blk.0.attn_q.weight` as Q8_0 with dimensions 3072 and 4096 at relative
  offset 444555264, and printed `token0_embedding_dequant: 1` plus
  `token0_attn_norm: 1`.
- `strace -e trace=mmap,munmap,close` on the real target showed `mmap`,
  `close(3) = 0`, successful summary/smoke output including the retained
  query projection descriptor, then
  `munmap(..., 3651679520) = 0`.
- `git diff --check` passed after the final work-file updates.

## Next Exact Step

Add a guarded token-0 query projection matvec smoke using the retained
`blk.0.attn_q.weight` descriptor and `token0_attn_norm_activation`, write into
static output storage, and print a status. Leave numerical oracle comparison for
a later atomic step.
