# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Retain the fixed `blk.0.attn_v.weight` descriptor in the GGUF summary and print
it, without reading value-projection payload bytes.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and
  linked with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, walks
  metadata and tensor descriptors with bounds checks, records the aligned
  tensor-data base, and returns a live read-only mapping descriptor to `_start`.
- The summary captures counts, selected Mistral metadata, the first tensor
  descriptor, `token_embd.weight`, `blk.0.attn_norm.weight`,
  `blk.0.attn_q.weight`, `blk.0.attn_k.weight`, and
  `mistral3.attention.layer_norm_rms_epsilon` as exact f32 bits.
- Scalar Q8_0 helpers cover block dot, row dot, row-major matvec, row dequant,
  and checked token-embedding dequantization with no-libc verifier coverage.
- Scalar f32 RMSNorm exists as a documented primitive with no-libc verifier
  coverage.
- `_start` prints retained summary fields, keeps the model mapping live through
  guarded token ID 0 embedding dequantization, attention RMSNorm, query
  projection, and key projection smokes, prints the first four query and key
  output f32 words as exact hex bits on success, then calls
  `gguf_release_mapping`.
- Synthetic parser fixtures that are not target-shaped skip payload smokes and
  print zero smoke statuses while preserving summary behavior.
- External oracle tooling under `work/oracle/` independently reproduces the
  current scalar f32 token-0 embedding, attention RMSNorm, and first four query
  and key projection dot products; those words match the runtime output.

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

## Required Verification

- Rebuild with `as`/`ld`.
- Keep `make check`, static-link checks, future CLI usage rejection, GGUF smoke
  checks, cleanup tracing, and whitespace checks passing.
- Smoke-test the real target GGUF when the ignored local model remains present.
- Rerun the external query/key projection oracle comparisons when projection
  math or shared token-0 inputs change.

## Last Verification

- `make clean && make` passed.
- `make check` passed; the harnesses printed `q8_0_dot: ok` and `rmsnorm: ok`.
- `./mistral-asm --help` returned status 0 and showed the query/key smoke
  milestone text; the future prompt generation form returned status 2 with the
  usage diagnostic.
- `readelf -d` reported no dynamic section, and `readelf -l` reported no
  interpreter or dynamic program headers.
- Synthetic fixtures `/tmp/mistral_asm_tensor_base_round.gguf`,
  `/tmp/mistral_asm_lookup_found.gguf`, and
  `/tmp/mistral_asm_lookup_absent.gguf` returned status 0, printed
  `attn_k_tensor_found: 0`, and kept `token0_embedding_dequant: 0`,
  `token0_attn_norm: 0`, `token0_attn_q_matvec: 0`, and
  `token0_attn_k_matvec: 0`.
- Synthetic malformed fixtures
  `/tmp/mistral_asm_lookup_malformed_later.gguf` and
  `/tmp/mistral_asm_offset_beyond_eof.gguf` returned status 3 with tensor data
  alignment or tensor directory diagnostics.
- The real target model under `models/` returned status 0, printed
  `blk.0.attn_k.weight` as Q8_0 with dimensions 3072 and 1024 at relative
  offset 427831296, kept `token0_embedding_dequant: 1`,
  `token0_attn_norm: 1`, `token0_attn_q_matvec: 1`, and
  `token0_attn_k_matvec: 1`, and printed query output slice words
  `0xbf9945a5`, `0xbf0612bc`, `0xbe09ed5f`, and `0xbf155e8e`, plus key output
  slice words `0xc028a3e3`, `0x3daaeb62`, `0xbe8a8c69`, and `0xc01d0994`.
- `strace -e trace=mmap,munmap,close` on the real target returned status 0,
  showed `close(3) = 0`, successful summary output including
  the guarded key output slice, and `munmap(..., 3651679520) = 0`.
- `python3 work/oracle/token0_attn_q_oracle.py <target.gguf>` returned status 0
  and matched the runtime query output words above.
- `python3 work/oracle/token0_attn_k_oracle.py <target.gguf>` returned status 0
  and matched the runtime key output words above.
- `python3 -m py_compile` passed for both projection oracle scripts.
- `git diff --check` passed.

## Next Exact Step

Add fixed `blk.0.attn_v.weight` descriptor plumbing to the GGUF summary and
runtime output, with synthetic fixtures keeping the descriptor absent and the
real target printing its type, dimensions, and relative offset.
