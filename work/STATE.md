# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Retain and print the fixed `blk.0.attn_output.weight` descriptor in the GGUF
summary. Keep this as descriptor plumbing only; do not read output-projection
payload bytes in the same step.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and
  linked with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, returns a
  live read-only mapping descriptor on success, and releases it explicitly after
  summary and guarded smoke output.
- The summary captures selected Mistral metadata, the first tensor descriptor,
  `token_embd.weight`, `blk.0.attn_norm.weight`, `blk.0.attn_q.weight`,
  `blk.0.attn_k.weight`, `blk.0.attn_v.weight`, and the attention RMSNorm
  epsilon bits.
- Scalar Q8_0 helpers, token-0 embedding dequantization, scalar f32 RMSNorm,
  query projection, key projection, and value projection smokes are wired.
  Query/key/value output slices have external oracle notes and exact-hex
  comparisons.
- The value projection smoke validates the retained `blk.0.attn_v.weight`
  descriptor as a bounded two-dimensional Q8_0 matrix, reads the mapped payload
  through `q8_0_matvec_f32`, writes `token0_attn_v_output`, and exposes a
  guarded four-word f32 hex slice.

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

## Required Verification

- Rebuild with `as`/`ld`.
- Keep `make check`, static-link checks, future CLI usage rejection, GGUF smoke
  checks, cleanup tracing, and whitespace checks passing.
- Smoke-test the real target GGUF when the ignored local model remains present.
- Rerun the external query/key/value projection oracle comparisons when
  projection math or shared token-0 inputs change.

## Last Verification

- `make clean && make` passed.
- `make check` passed; the harnesses printed `q8_0_dot: ok` and `rmsnorm: ok`.
- `./mistral-asm --help` returned status 0 with the query/key/value smoke
  milestone text; the future prompt generation form returned status 2 with the
  usage diagnostic.
- `readelf -d` reported no dynamic section, and `readelf -l` reported no
  interpreter or dynamic program headers.
- Synthetic fixtures `/tmp/mistral_asm_tensor_base_round.gguf`,
  `/tmp/mistral_asm_lookup_found.gguf`, and
  `/tmp/mistral_asm_lookup_absent.gguf` returned status 0, printed
  `attn_v_tensor_found: 0`, and kept `token0_embedding_dequant: 0`,
  `token0_attn_norm: 0`, `token0_attn_q_matvec: 0`,
  `token0_attn_k_matvec: 0`, and `token0_attn_v_matvec: 0`.
- Synthetic malformed fixtures
  `/tmp/mistral_asm_lookup_malformed_later.gguf` and
  `/tmp/mistral_asm_offset_beyond_eof.gguf` returned status 3 with tensor data
  alignment or tensor directory diagnostics.
- The real target model under `models/` returned status 0, kept token-0
  embedding, RMSNorm, query, key, and value smoke statuses at 1, and printed
  value words `0x3ca3b3bc`, `0x3c9bf3e4`, `0x3c29a3e4`, and `0xbb17585e`.
- `strace -e trace=mmap,munmap,close` on the real target returned status 0,
  showed `close(3) = 0`, the guarded value output words before final cleanup,
  and `munmap(..., 3651679520) = 0`.
- Query, key, and value oracle scripts matched the runtime output words exactly:
  query `0xbf9945a5`, `0xbf0612bc`, `0xbe09ed5f`, `0xbf155e8e`;
  key `0xc028a3e3`, `0x3daaeb62`, `0xbe8a8c69`, `0xc01d0994`;
  value `0x3ca3b3bc`, `0x3c9bf3e4`, `0x3c29a3e4`, `0xbb17585e`.
- The ignored target model contains `blk.0.attn_output.weight` as Q8_0 with
  dimensions 4096 and 3072 at relative offset 431185920.
- `git diff --check` passed.

## Next Exact Step

Retain and print the fixed `blk.0.attn_output.weight` descriptor in the GGUF
summary. Keep this as descriptor plumbing only; do not read output-projection
payload bytes in the same step.
