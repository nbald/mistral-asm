# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Print a guarded four-word exact-hex slice from `token0_ffn_gate_output` after
`token0_ffn_gate_matvec_status` is 1, preserving status-only skip behavior for
synthetic fixtures.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, returns a
  live read-only mapping descriptor on success, and releases it explicitly after
  summary and guarded smoke output.
- The summary captures selected Mistral metadata, tensor-data base offset, the
  first tensor, `token_embd.weight`, first-layer attention norm/Q/K/V/output
  descriptors, `blk.0.ffn_norm.weight`, `blk.0.ffn_gate.weight`, and attention
  RMSNorm epsilon bits.
- Token-0 smokes currently cover embedding dequantization, attention RMSNorm,
  query/key/value projections, single-token context expansion, attention output
  projection, post-attention residual, FFN RMSNorm, and FFN gate projection. The
  query/key/value/output/residual/FFN RMSNorm exact-hex slices have external
  oracle notes; the FFN gate projection is status-only for now.
- The FFN gate matvec step validates the retained `blk.0.ffn_gate.weight`
  descriptor as Q8_0 `[3072 x 9216]`, bounds the full mapped payload, writes
  static FFN gate activation storage, and prints `token0_ffn_gate_matvec`.

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
- `work/oracle/token0_attn_q_oracle.py`
- `work/oracle/token0-attn-q-output.md`
- `work/oracle/token0_attn_k_oracle.py`
- `work/oracle/token0-attn-k-output.md`
- `work/oracle/token0_attn_v_oracle.py`
- `work/oracle/token0-attn-v-output.md`
- `work/oracle/token0_attn_output_oracle.py`
- `work/oracle/token0-attn-output.md`
- `work/oracle/token0_post_attn_residual_oracle.py`
- `work/oracle/token0-post-attn-residual.md`
- `work/oracle/token0_ffn_norm_oracle.py`
- `work/oracle/token0-ffn-norm.md`

## Required Verification

- Rebuild with `as`/`ld`.
- Keep `make check`, static-link checks, future CLI usage rejection, GGUF smoke
  checks, cleanup tracing, and whitespace checks passing.
- Smoke-test the real target GGUF when the ignored local model remains present.
- Rerun the external query/key/value projection oracle comparisons when
  projection math or shared token-0 inputs change.
- Rerun the external output projection oracle comparison when value projection,
  context expansion, output projection math, or shared token-0 inputs change.
- Rerun the external residual oracle comparison when residual math or shared
  token-0 inputs change.
- Rerun the external FFN RMSNorm oracle comparison when residual math, FFN
  RMSNorm math, `blk.0.ffn_norm.weight` handling, or shared token-0 inputs
  change.
- Add and rerun an external FFN gate oracle after exposing a public FFN gate
  exact-hex slice; until then the gate smoke is status-only.

## Last Verification

- `make clean && make` passed.
- `make check` passed; the harnesses printed `q8_0_dot: ok` and `rmsnorm: ok`.
- `./mistral-asm --help` returned status 0 and reported the FFN gate matvec
  milestone; the unsupported prompt generation form returned status 2 with the
  usage diagnostic.
- `readelf -d` reported no dynamic section; `readelf -l` showed only LOAD and
  GNU_STACK program headers, with no interpreter or dynamic program header.
- Synthetic fixtures `/tmp/mistral_asm_tensor_base_round.gguf`,
  `/tmp/mistral_asm_lookup_found.gguf`, and
  `/tmp/mistral_asm_lookup_absent.gguf` returned status 0, kept
  `ffn_gate_tensor_found: 0`, and printed `token0_ffn_gate_matvec: 0`.
- Synthetic malformed fixtures
  `/tmp/mistral_asm_lookup_malformed_later.gguf` and
  `/tmp/mistral_asm_offset_beyond_eof.gguf` returned status 3 with tensor data
  alignment or tensor directory diagnostics.
- The real target model under `models/` returned status 0, printed
  `blk.0.ffn_gate.weight` as Q8_0 with dimensions `3072 x 9216` at relative
  offset `491347968`, kept the existing token-0 attention/residual/FFN norm
  exact-hex slices, and printed `token0_ffn_gate_matvec: 1`.
- Merged `strace -e trace=mmap,munmap,close` output on the real target returned
  status 0, showed the full-file read-only `mmap`, `close(3) = 0`, and final
  `munmap`.
- `python3 -m py_compile work/oracle/*.py` passed.
- Existing external projection/output/residual/FFN RMSNorm oracle scripts were
  not rerun because this downstream status-only gate step did not alter their
  math, shared inputs, or public exact-hex slices.
- `git diff --check` passed.

## Next Exact Step

Print a guarded four-word exact-hex slice from `token0_ffn_gate_output` after
`token0_ffn_gate_matvec_status` is 1, preserving status-only skip behavior for
synthetic fixtures.
