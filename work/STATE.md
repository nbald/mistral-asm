# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add a guarded token-0 post-attention residual smoke that sums
`token_embedding_activation` and `token0_attn_output` into a 3072-f32 static
buffer, prints a status and the first four exact-hex words, and does not add new
tensor payload reads.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and
  linked with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, returns a
  live read-only mapping descriptor on success, and releases it explicitly after
  summary and guarded smoke output.
- The summary captures selected Mistral metadata, the first tensor descriptor,
  `token_embd.weight`, `blk.0.attn_norm.weight`, `blk.0.attn_q.weight`,
  `blk.0.attn_k.weight`, `blk.0.attn_v.weight`,
  `blk.0.attn_output.weight`, and the attention RMSNorm epsilon bits.
- Scalar Q8_0 helpers, token-0 embedding dequantization, scalar f32 RMSNorm,
  query projection, key projection, value projection, single-token context, and
  output projection smokes are wired. Query/key/value/output slices have
  external oracle notes and exact-hex comparisons.
- The token-0 single-token attention context smoke expands the computed
  1024-f32 value projection into a 4096-f32 static context by repeating each
  128-f32 KV-head block for its four query heads. It uses
  `blk.0.attn_output.weight` only as a descriptor shape guard.
- The context smoke now exposes guarded `token0_attn_context0..3_f32_hex`
  words. On the real target, those four words exactly match
  `token0_attn_v_output0..3_f32_hex`.
- The guarded output-projection smoke validates `token0_attn_context_status`
  and the retained `blk.0.attn_output.weight` descriptor as exact 4096x3072
  Q8_0, proves the full matrix payload fits in the live mapping, multiplies the
  static 4096-f32 context into a 3072-f32 static buffer, and prints
  `token0_attn_output_matvec` plus guarded `token0_attn_output0..3_f32_hex`
  words.
- The verification-only output projection oracle parses the target GGUF
  externally, recomputes token 0 attention RMSNorm, all 1024 value rows, the
  repeated 4096-f32 single-token context, and the first four output projection
  rows. Its context and output words match the runtime exact-hex slices.

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

## Required Verification

- Rebuild with `as`/`ld`.
- Keep `make check`, static-link checks, future CLI usage rejection, GGUF smoke
  checks, cleanup tracing, and whitespace checks passing.
- Smoke-test the real target GGUF when the ignored local model remains present.
- Rerun the external query/key/value projection oracle comparisons when
  projection math or shared token-0 inputs change.
- Rerun the external output projection oracle comparison when value projection,
  context expansion, output projection math, or shared token-0 inputs change.

## Last Verification

- `make clean && make` passed.
- `make check` passed; the harnesses printed `q8_0_dot: ok` and `rmsnorm: ok`.
- `./mistral-asm --help` returned status 0 and reported the output projection
  smoke milestone; the current unsupported prompt generation form returned
  status 2 with the usage diagnostic.
- `readelf -d` reported no dynamic section; `readelf -l` showed only LOAD and
  GNU_STACK program headers, with no interpreter or dynamic program header.
- Synthetic fixtures `/tmp/mistral_asm_tensor_base_round.gguf`,
  `/tmp/mistral_asm_lookup_found.gguf`, and
  `/tmp/mistral_asm_lookup_absent.gguf` returned status 0, printed
  `attn_output_tensor_found: 0`, and kept `token0_attn_context: 0` and
  `token0_attn_output_matvec: 0` with no context or output word slices.
- Synthetic malformed fixtures
  `/tmp/mistral_asm_lookup_malformed_later.gguf` and
  `/tmp/mistral_asm_offset_beyond_eof.gguf` returned status 3 with tensor data
  alignment or tensor directory diagnostics.
- The real target model under `models/` returned status 0, printed
  `blk.0.attn_output.weight` as Q8_0 with dimensions 4096 and 3072 at relative
  offset 431185920, kept `token0_attn_context: 1`, printed context words
  `0x3ca3b3bc`, `0x3c9bf3e4`, `0x3c29a3e4`, and `0xbb17585e`, matching the
  first four value-projection words exactly, printed
  `token0_attn_output_matvec: 1`, and printed output words `0xbd553ed5`,
  `0xbe2c4b4d`, `0x3f7c2d02`, and `0x3d799d1a`.
- `strace -e trace=mmap,munmap,close` on the real target returned status 0,
  showed `close(3) = 0`, printed the guarded value, context, and output words
  plus `token0_attn_output_matvec: 1` before final cleanup, and showed
  `munmap(..., 3651679520) = 0`.
- `python3 work/oracle/token0_attn_output_oracle.py` on the real target printed
  context words `0x3ca3b3bc`, `0x3c9bf3e4`, `0x3c29a3e4`, and `0xbb17585e`,
  and output words `0xbd553ed5`, `0xbe2c4b4d`, `0x3f7c2d02`, and
  `0x3d799d1a`, exactly matching the runtime slices.
- The external query/key/value projection oracles were not rerun because this
  step added only output-projection verification tooling and notes, not runtime
  projection math or shared token-0 inputs.
- `git diff --check` passed.

## Next Exact Step

Add a guarded token-0 post-attention residual smoke that sums
`token_embedding_activation` and `token0_attn_output` into a 3072-f32 static
buffer, prints a status and the first four exact-hex words, and does not add new
tensor payload reads.
