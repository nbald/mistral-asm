# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add a guarded token-0 FFN SwiGLU activation smoke that computes
`silu(token0_ffn_gate_output) * token0_ffn_up_output` into static f32 storage
and prints status only.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, returns a
  live read-only mapping descriptor on success, and releases it explicitly after
  summary and guarded smoke output.
- The summary captures selected Mistral metadata, tensor-data base offset, the
  first tensor, `token_embd.weight`, first-layer attention norm/Q/K/V/output
  descriptors, `blk.0.ffn_norm.weight`, `blk.0.ffn_gate.weight`,
  `blk.0.ffn_up.weight`, `blk.0.ffn_down.weight`, and attention RMSNorm epsilon
  bits.
- Token-0 smokes cover embedding dequantization, attention RMSNorm, Q/K/V
  projections, single-token context expansion, attention output projection,
  post-attention residual, FFN RMSNorm, FFN gate projection, and FFN up
  projection.
- Public exact-hex slices and external oracle notes exist through the FFN up
  projection.
- This step retained and prints the `blk.0.ffn_down.weight` descriptor. The real
  target reports Q8_0 dimensions `9216 x 3072` at relative offset `461266944`.
  No FFN down payload bytes are read yet.

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
- Rerun existing external projection/output/residual/FFN RMSNorm/FFN gate/FFN up
  oracle comparisons when their math, shared inputs, or public exact-hex slices
  change.

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
  `ffn_gate_tensor_found: 0`, `ffn_up_tensor_found: 0`, and
  `ffn_down_tensor_found: 0`, and printed both FFN matvec statuses as 0.
- Synthetic malformed fixtures
  `/tmp/mistral_asm_lookup_malformed_later.gguf` and
  `/tmp/mistral_asm_offset_beyond_eof.gguf` returned status 3 with the expected
  tensor alignment/directory diagnostics.
- The real target model under `models/` returned status 0, preserved existing
  token-0 exact-hex slices through FFN up, printed `ffn_down_tensor_found: 1`,
  `ffn_down_tensor_name: blk.0.ffn_down.weight`, dimensions `9216 x 3072`,
  ggml type `8`, and offset `461266944`.
- `strace -e trace=mmap,munmap,close` on the real target returned status 0,
  showed the full-file read-only `mmap`, `close(3) = 0`, the FFN down descriptor
  lines, FFN up output words, and final `munmap`.
- A Python parser cross-check reported `blk.0.ffn_down.weight: type 8 dims
  9216x3072 offset 461266944`.
- `python3 -m py_compile work/oracle/*.py` passed.
- `git diff --check` passed.

## Next Exact Step

Add a guarded token-0 FFN SwiGLU activation smoke that computes
`silu(token0_ffn_gate_output) * token0_ffn_up_output` into static f32 storage
and prints status only.
