# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Print a guarded four-word exact-hex slice from `token0_ffn_up_output` after
`token0_ffn_up_matvec_status` is 1.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, returns a
  live read-only mapping descriptor on success, and releases it explicitly after
  summary and guarded smoke output.
- The summary captures selected Mistral metadata, tensor-data base offset, the
  first tensor, `token_embd.weight`, first-layer attention norm/Q/K/V/output
  descriptors, `blk.0.ffn_norm.weight`, `blk.0.ffn_gate.weight`,
  `blk.0.ffn_up.weight`, and attention RMSNorm epsilon bits.
- Token-0 smokes now cover embedding dequantization, attention RMSNorm,
  query/key/value projections, single-token context expansion, attention output
  projection, post-attention residual, FFN RMSNorm, FFN gate projection, and FFN
  up projection.
- Public exact-hex slices exist through the FFN gate projection. Existing
  external oracle notes cover Q/K/V/output/context-equivalent output, residual,
  FFN RMSNorm, and FFN gate.
- The FFN gate matvec validates `blk.0.ffn_gate.weight` as Q8_0
  `[3072 x 9216]`, bounds the full mapped payload, writes static FFN gate
  activation storage, prints `token0_ffn_gate_matvec`, and prints the first four
  output f32 bit patterns only when the status is 1.
- The FFN up matvec validates `blk.0.ffn_up.weight` as Q8_0 `[3072 x 9216]`,
  bounds the full mapped payload, writes static FFN up activation storage, and
  prints status-only `token0_ffn_up_matvec`.

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
- `work/oracle/`

## Required Verification

- Rebuild with `as`/`ld`.
- Keep `make check`, static-link checks, future CLI usage rejection, GGUF smoke
  checks, cleanup tracing, oracle py-compile, and whitespace checks passing.
- Smoke-test the real target GGUF when the ignored local model remains present.
- Rerun existing external projection/output/residual/FFN RMSNorm/FFN gate oracle
  comparisons when their math, shared inputs, or public exact-hex slices change.

## Last Verification

- `make clean && make` passed.
- `make check` passed; the harnesses printed `q8_0_dot: ok` and `rmsnorm: ok`.
- `./mistral-asm --help` returned status 0. The unsupported prompt-generation
  form returned status 2 with the usage diagnostic.
- `readelf -d` reported no dynamic section; `readelf -l` showed only LOAD and
  GNU_STACK program headers, with no interpreter or dynamic program header.
- Synthetic fixtures `/tmp/mistral_asm_tensor_base_round.gguf`,
  `/tmp/mistral_asm_lookup_found.gguf`, and
  `/tmp/mistral_asm_lookup_absent.gguf` returned status 0, kept
  `ffn_gate_tensor_found: 0` and `ffn_up_tensor_found: 0`, and printed both
  `token0_ffn_gate_matvec: 0` and `token0_ffn_up_matvec: 0`.
- Synthetic malformed fixtures
  `/tmp/mistral_asm_lookup_malformed_later.gguf` and
  `/tmp/mistral_asm_offset_beyond_eof.gguf` returned status 3 with tensor data
  alignment or tensor directory diagnostics.
- The real target model under `models/` returned status 0, preserved existing
  Q/K/V/output/residual/FFN RMSNorm/FFN gate exact-hex slices, printed
  `ffn_up_tensor_found: 1`, `ffn_up_tensor_name: blk.0.ffn_up.weight`,
  dimensions `3072 x 9216`, ggml type `8`, offset `521441280`,
  `token0_ffn_gate_matvec: 1`, and `token0_ffn_up_matvec: 1`.
- No `token0_ffn_up_output*_f32_hex` lines are printed yet.
- Merged `strace -e trace=mmap,munmap,close` output on the real target returned
  status 0, showed the full-file read-only `mmap`, `close(3) = 0`, the FFN up
  descriptor lines, `token0_ffn_up_matvec: 1`, and final `munmap`.
- `python3 -m py_compile work/oracle/*.py` passed.
- Existing external oracle comparisons were not rerun because this step added a
  status-only FFN up projection smoke and did not alter existing runtime math,
  shared inputs, or public exact-hex slices.
- `git diff --check` passed.

## Next Exact Step

Print a guarded four-word exact-hex slice from `token0_ffn_up_output` after
`token0_ffn_up_matvec_status` is 1.
