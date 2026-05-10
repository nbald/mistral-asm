# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add an external oracle comparison for the four-word
`token0_post_ffn_residual` exact-hex slice.

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
- Public exact-hex slices exist through the post-FFN residual. External oracle
  notes exist through the FFN down output. The FFN down oracle recomputes the
  full token-0 path through the 9216-word SwiGLU activation, dots it with the
  first four `blk.0.ffn_down.weight` rows, and matches runtime words exactly.
- The real target reports `blk.0.ffn_down.weight` as Q8_0 dimensions
  `9216 x 3072` at relative offset `461266944`.

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
- The real target model under `strace -e trace=mmap,munmap,close` returned
  status 0, printed `token0_post_ffn_residual: 1`, and printed post-FFN
  residual words `0xbe256913`, `0xbf15734b`, `0x40402562`, and `0xbe4c5582`;
  cleanup showed successful `close(3)` and final `munmap`.
- A direct float32 add check verified those four post-FFN residual words from
  the printed post-attention residual and FFN down output words.
- Synthetic valid fixtures returned status 0 with FFN down and post-FFN
  residual smokes skipped and no post-FFN residual word labels. Synthetic
  malformed fixtures returned status 3 with the expected bad-magic and
  malformed tensor diagnostics.
- `python3 -m py_compile work/oracle/*.py` passed.
- `find src -type f ! -name '*.s' -print` produced no runtime non-assembly
  source files.
- `git diff --check` passed.

## Next Exact Step

Add `work/oracle/token0_post_ffn_residual_oracle.py` and a comparison note that
recompute the current token-0 path through FFN down, add the first four
post-attention residual and FFN down words as float32, and compare exactly with
the runtime `token0_post_ffn_residual*_f32_hex` output.
