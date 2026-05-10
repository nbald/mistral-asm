# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Print a guarded four-word exact-hex slice from `token0_ffn_norm_activation` when
`token0_ffn_norm_status` is 1, without changing the FFN RMSNorm math path.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, returns a
  live read-only mapping descriptor on success, and releases it explicitly after
  summary and guarded smoke output.
- The summary captures selected Mistral metadata, tensor-data base offset, the
  first tensor, `token_embd.weight`, first-layer attention norm/Q/K/V/output
  descriptors, `blk.0.ffn_norm.weight`, and attention RMSNorm epsilon bits.
- Token-0 smokes currently cover embedding dequantization, attention RMSNorm,
  query/key/value projections, single-token context expansion, attention output
  projection, post-attention residual, and FFN RMSNorm. The
  query/key/value/output/residual exact-hex slices have external oracle notes.
- The latest step added a guarded FFN RMSNorm smoke. It consumes
  `blk.0.ffn_norm.weight` only after `token0_post_attn_residual` is available,
  validates the retained descriptor as f32 `[3072]`, proves the mapped payload
  span is in bounds, writes `token0_ffn_norm_activation`, and prints only
  `token0_ffn_norm`.

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

## Last Verification

- `make clean && make` passed.
- `make check` passed; the harnesses printed `q8_0_dot: ok` and `rmsnorm: ok`.
- `./mistral-asm --help` returned status 0 and reported the FFN RMSNorm smoke
  milestone; the current unsupported prompt generation form returned status 2
  with the usage diagnostic.
- `readelf -d` reported no dynamic section; `readelf -l` showed only LOAD and
  GNU_STACK program headers, with no interpreter or dynamic program header.
- Synthetic fixtures `/tmp/mistral_asm_tensor_base_round.gguf`,
  `/tmp/mistral_asm_lookup_found.gguf`, and
  `/tmp/mistral_asm_lookup_absent.gguf` returned status 0, printed
  `ffn_norm_tensor_found: 0`, and kept `token0_post_attn_residual: 0` and
  `token0_ffn_norm: 0`.
- Synthetic malformed fixtures
  `/tmp/mistral_asm_lookup_malformed_later.gguf` and
  `/tmp/mistral_asm_offset_beyond_eof.gguf` returned status 3 with tensor data
  alignment or tensor directory diagnostics.
- The real target model under `models/` returned status 0, printed
  `blk.0.ffn_norm.weight` as f32 with dimension 3072 at relative offset
  521428992, kept the existing token-0 attention and residual statuses at 1,
  printed `token0_ffn_norm: 1`, and preserved the previous exact-hex slices
  through post-attention residual.
- `strace -e trace=mmap,munmap,close` on the real target returned status 0,
  showed the full-file read-only `mmap`, `close(3) = 0`, printed the FFN norm
  descriptor and `token0_ffn_norm: 1`, then showed final `munmap`.
- The external projection/residual oracles were not rerun because this step
  did not change their math or shared token-0 inputs.
- `git diff --check` passed.

## Next Exact Step

Print a guarded four-word exact-hex slice from `token0_ffn_norm_activation` when
`token0_ffn_norm_status` is 1, without changing the FFN RMSNorm math path.
