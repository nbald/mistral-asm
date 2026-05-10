# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Prepare layer iteration by retaining the validated tensor-info directory start
offset in the GGUF summary and printing it alongside the tensor-data base
offset.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, maps the
  model read-only, records the tensor-data base offset, and summarizes selected
  Mistral metadata plus token embedding, first-layer attention, and first-layer
  FFN norm/gate/up/down tensor descriptors.
- Token-0 smokes cover embedding dequantization, attention RMSNorm, Q/K/V
  projections, single-token context expansion, attention output projection,
  post-attention residual, FFN RMSNorm, FFN gate/up projections, FFN SwiGLU,
  FFN down projection, and post-FFN residual addition.
- Public exact-hex slices and external oracle notes exist through the post-FFN
  residual. The post-FFN residual oracle reuses the full FFN down oracle path,
  adds the first four post-attention residual and FFN down words with f32
  rounding, and matches runtime words exactly.
- The real target reports `blk.0.ffn_down.weight` as Q8_0 dimensions
  `9216 x 3072` at relative offset `461266944`.
- A token-0 forward review was recorded in
  `work/reviews/2026-05-10-token0-forward-review.md`. It found that Q/K/V
  projection smokes can print four public slice words after writing fewer than
  four rows for non-target synthetic shapes, and that the `_start` contract is
  stale because it omits the post-FFN residual add.
- The review finding has been fixed: Q/K/V projection smokes now require exact
  target output row counts before setting status 1, and the `_start` contract
  includes the guarded post-FFN residual add.

## Known Blockers

None.

## Relevant Files

- `src/entry/_start.s`
- `src/gguf/load_header.s`
- `src/math/q8_0_dot.s`
- `src/math/rmsnorm.s`
- `src/math/swiglu.s`
- `tests/q8_0_dot_harness.s`
- `tests/rmsnorm_harness.s`
- `tests/swiglu_harness.s`
- `Makefile`
- `work/oracle/token0_ffn_down_oracle.py`
- `work/oracle/token0-ffn-down.md`
- `work/oracle/token0_post_ffn_residual_oracle.py`
- `work/oracle/token0-post-ffn-residual.md`
- `work/reviews/2026-05-10-token0-forward-review.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Required Verification

- Rebuild with `as`/`ld`.
- Keep `make check` including the Q8_0 dot, RMSNorm, and SwiGLU harnesses
  passing.
- Keep CLI usage rejection, static-link checks, synthetic GGUF smoke/error
  checks, cleanup tracing, oracle py-compile, runtime source purity, and
  whitespace checks passing.
- Smoke-test the real target GGUF when the ignored local model remains present.
- Rerun affected external oracle comparisons when math, shared inputs, or public
  exact-hex slices change.

## Last Verification

- `make clean` and `make` passed.
- `make check` passed; the harnesses printed `q8_0_dot: ok`, `rmsnorm: ok`,
  and `swiglu: ok`.
- `./mistral-asm --help` returned status 0. The unsupported prompt-generation
  form returned status 2 with the usage diagnostic.
- `readelf -d` reported no dynamic section; `readelf -l` showed only LOAD and
  GNU_STACK program headers, with no interpreter or dynamic program header.
- Synthetic valid and malformed GGUF fixtures preserved expected behavior:
  valid empty input returned status 0 with post-FFN residual status 0, bad
  magic returned status 3, and a truncated tensor directory returned status 3.
- A disposable partial-row Q/K/V GGUF fixture under `/tmp` proved the tightened
  guards: embedding dequantization and attention RMSNorm returned status 1,
  all three Q/K/V matvec smokes returned status 0, and no Q/K/V public exact-hex
  slice labels were emitted.
- The real target model under `strace -e trace=mmap,munmap,close` returned
  status 0, printed exact-target Q/K/V matvec status 1 plus
  `token0_post_ffn_residual: 1`, and preserved the recorded post-FFN residual
  words `0xbe256913`, `0xbf15734b`, `0x40402562`, and `0xbe4c5582`; cleanup
  showed successful `close(3)` and final `munmap`.
- `python3 -m py_compile work/oracle/*.py` passed.
- `find src -type f ! -name '*.s' -print` produced no runtime non-assembly
  source files.
- `git ls-files` found no tracked model files, GGUFs, large logs, traces, or
  dumps.
- `git diff --check` passed.
- No external oracle script was rerun because runtime math, shared oracle
  inputs, and public exact-hex outputs were unchanged.

## Next Exact Step

In `src/gguf/load_header.s` and `src/entry/_start.s`, retain the validated
tensor-info directory start offset in the GGUF summary and print it alongside
the tensor-data base offset.
