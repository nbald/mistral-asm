# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Build a guarded token-0 single-token attention-context smoke: expand the
computed 1024-value `token0_attn_v_output` into a 4096-value context by
repeating each KV-head value block for its query-head group, print only a
`token0_attn_context` status, and do not read `blk.0.attn_output.weight`
payload bytes in that step.

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
  query projection, key projection, and value projection smokes are wired.
  Query/key/value output slices have external oracle notes and exact-hex
  comparisons.
- The output projection descriptor step is descriptor plumbing only: the runtime
  prints the retained `blk.0.attn_output.weight` directory entry but does not
  read its payload.

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
- `./mistral-asm --help` returned status 0 with the output-descriptor milestone
  text; the future prompt generation form returned status 2 with the usage
  diagnostic.
- `readelf -d` reported no dynamic section, and `readelf -l` reported no
  interpreter or dynamic program headers.
- Synthetic fixtures `/tmp/mistral_asm_tensor_base_round.gguf`,
  `/tmp/mistral_asm_lookup_found.gguf`, and
  `/tmp/mistral_asm_lookup_absent.gguf` returned status 0, printed
  `attn_output_tensor_found: 0`, and kept token-0 payload smoke statuses at 0.
- Synthetic malformed fixtures
  `/tmp/mistral_asm_lookup_malformed_later.gguf` and
  `/tmp/mistral_asm_offset_beyond_eof.gguf` returned status 3 with tensor data
  alignment or tensor directory diagnostics.
- The real target model under `models/` returned status 0, kept token-0
  embedding, RMSNorm, query, key, and value smoke statuses at 1, printed
  `blk.0.attn_output.weight` as Q8_0 with dimensions 4096 and 3072 at relative
  offset 431185920, and kept the existing Q/K/V output words unchanged.
- `strace -e trace=mmap,munmap,close` on the real target returned status 0,
  showed `close(3) = 0`, printed the output descriptor and guarded value output
  words before final cleanup, and showed `munmap(..., 3651679520) = 0`.
- `nm -n build/entry/_start.o` confirmed the entry BSS summary layout places
  `gguf_summary_attn_output_tensor_found` at offset `0x408` and shifts
  `gguf_summary_attn_norm_rms_epsilon_found` to offset `0x4a8`, matching the
  loader constants.
- `git diff --check` passed.

## Next Exact Step

Build a guarded token-0 single-token attention-context smoke: expand the
computed 1024-value `token0_attn_v_output` into a 4096-value context by
repeating each KV-head value block for its query-head group, print only a
`token0_attn_context` status, and do not read `blk.0.attn_output.weight`
payload bytes in that step.
