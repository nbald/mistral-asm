# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add external token-0 FFN down oracle tooling and a comparison note for the new
public FFN down exact-hex slice.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, returns a
  live read-only mapping descriptor on success, and releases it explicitly after
  summary and guarded smoke output.
- The summary captures selected Mistral metadata, tensor-data base offset,
  `token_embd.weight`, first-layer attention tensors, FFN norm/gate/up/down
  tensor descriptors, and attention RMSNorm epsilon bits.
- Token-0 smokes cover embedding dequantization, attention RMSNorm, Q/K/V
  projections, single-token context expansion, attention output projection,
  post-attention residual, FFN RMSNorm, FFN gate/up projections, FFN SwiGLU, and
  FFN down projection.
- Public exact-hex slices exist through the FFN down output. External oracle
  notes exist through the FFN SwiGLU activation; no FFN down oracle comparison
  note exists yet.
- The real target reports `blk.0.ffn_down.weight` as Q8_0 dimensions
  `9216 x 3072` at relative offset `461266944`.
- The runtime computes a guarded token-0 FFN down matvec from
  `token0_ffn_swiglu_output` through `blk.0.ffn_down.weight`. It requires
  `token0_ffn_swiglu_status == 1`, exact Q8_0 `[9216 x 3072]` shape, and a
  bounded full matrix span before reading payload bytes; on success it writes
  3072 f32 values to static `token0_ffn_down_output` and prints a guarded
  four-word exact-hex slice.

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
- `work/STATE.md`
- `work/WORKLOG.md`
- `work/oracle/`

## Required Verification

- Rebuild with `as`/`ld`.
- Keep `make check` including the Q8_0 dot, RMSNorm, and SwiGLU harnesses
  passing.
- Keep CLI usage rejection, static-link checks, synthetic GGUF smoke/error
  checks, cleanup tracing, oracle py-compile, runtime source purity, and
  whitespace checks passing.
- Smoke-test the real target GGUF when the ignored local model remains present.
- Rerun existing external projection/output/residual/FFN RMSNorm/FFN gate/FFN
  up/SwiGLU oracle comparisons when their math, shared inputs, or public
  exact-hex slices change.

## Last Verification

- `make clean && make` passed.
- `make check` passed; the harnesses printed `q8_0_dot: ok`, `rmsnorm: ok`,
  and `swiglu: ok`.
- `./mistral-asm --help` returned status 0. The unsupported prompt-generation
  form returned status 2 with the usage diagnostic.
- `readelf -d` reported no dynamic section; `readelf -l` showed only LOAD and
  GNU_STACK program headers, with no interpreter or dynamic program header.
- Synthetic fixtures `/tmp/mistral_asm_tensor_base_round.gguf`,
  `/tmp/mistral_asm_lookup_found.gguf`, and
  `/tmp/mistral_asm_lookup_absent.gguf` returned status 0, kept
  `ffn_gate_tensor_found: 0`, `ffn_up_tensor_found: 0`, and
  `ffn_down_tensor_found: 0`, and printed the FFN gate/up matvec, SwiGLU, and
  FFN down matvec statuses as 0.
- Synthetic malformed fixtures
  `/tmp/mistral_asm_lookup_malformed_later.gguf` and
  `/tmp/mistral_asm_offset_beyond_eof.gguf` returned status 3 with the expected
  tensor alignment/directory diagnostics.
- The real target model under `models/` returned status 0, preserved existing
  FFN SwiGLU exact-hex words `0xbe697324`, `0xbe7a2af9`, `0xbe66d77d`, and
  `0xbe30ee21`, printed `token0_ffn_down_matvec: 1`, and printed FFN down
  words `0xbde9febc`, `0xbec5ccf0`, `0x3ffe1c83`, and `0xbe862464`.
- `strace -e trace=mmap,munmap,close` on the real target returned status 0,
  showed the full-file read-only `mmap`, successful `close(3)`, FFN down
  descriptor output, `token0_ffn_down_matvec: 1`, the FFN down exact-hex slice,
  and final `munmap`.
- `python3 -m py_compile work/oracle/*.py` passed.
- `find src -type f ! -name '*.s' -print` produced no runtime non-assembly
  source files.
- `git diff --check` passed.

## Next Exact Step

Add external token-0 FFN down oracle tooling and a comparison note that
recomputes the full token-0 path through FFN SwiGLU, dots it with the first four
`blk.0.ffn_down.weight` rows, and compares those words with the runtime slice.
