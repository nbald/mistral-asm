# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Use the captured `blk.1.attn_norm.weight` descriptor for a status-only
layer-1 attention RMSNorm smoke over `token0_post_ffn_residual`, leaving exact
hex output and oracle comparison for a later step.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, maps the
  model read-only, records the tensor-info directory start offset and
  tensor-data base offset, and summarizes selected Mistral metadata plus token
  embedding, first-layer attention, and first-layer FFN norm/gate/up/down tensor
  descriptors.
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
- `gguf_lookup_tensor_info` now provides a reusable exported helper that
  rescans a validated tensor-info directory from the retained start offset,
  matches one requested tensor name, and copies the descriptor into a generic
  caller-owned 160-byte slot without adding another fixed summary slot.
- A pure assembly `gguf_lookup` harness covers successful descriptor capture,
  absent-name clearing, and malformed unaligned relative-offset rejection.
- The runtime uses the reusable lookup helper after validation to capture
  `blk.1.attn_norm.weight` into a separate scratch descriptor slot and prints
  found, dimension, type, and relative-offset summary fields. This smoke is
  non-math and leaves the existing token-0 layer-0 path on the fixed
  descriptors.

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
- `tests/gguf_lookup_harness.s`
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
- Keep `make check` including the Q8_0 dot, RMSNorm, SwiGLU, and GGUF lookup
  harnesses passing.
- Keep CLI usage rejection, static-link checks, synthetic GGUF smoke/error
  checks, cleanup tracing, oracle py-compile, runtime source purity, and
  whitespace checks passing.
- Smoke-test the real target GGUF when the ignored local model remains present.
- Rerun affected external oracle comparisons when math, shared inputs, or public
  exact-hex slices change.

## Last Verification

- `make clean` and `make` passed.
- `make check` passed; the harnesses printed `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- `./mistral-asm --help` returned status 0. The unsupported prompt-generation
  form returned status 2 with the usage diagnostic.
- `readelf -d` reported no dynamic section; `readelf -l` showed only LOAD and
  GNU_STACK program headers, with no interpreter or dynamic program header.
- Synthetic valid and malformed GGUF fixtures preserved expected behavior:
  valid empty input returned status 0 with `tensor_infos_offset: 24`,
  `tensor_data_offset: 0`, zeroed layer-1 lookup fields, and post-FFN residual
  status 0; bad magic returned status 3; a truncated tensor directory returned
  status 3.
- The real target model under `strace -e trace=mmap,munmap,close` returned
  status 0, printed `tensor_infos_offset: 7867981`,
  `tensor_data_offset: 7882016`,
  `layer1_attn_norm_tensor_found: 1`,
  `layer1_attn_norm_tensor_n_dimensions: 1`,
  `layer1_attn_norm_tensor_dim0: 3072`,
  `layer1_attn_norm_tensor_ggml_type: 0`, and
  `layer1_attn_norm_tensor_offset: 554864640`; it also preserved
  exact-target Q/K/V matvec status 1, `token0_post_ffn_residual: 1`, and the
  recorded post-FFN residual words `0xbe256913`, `0xbf15734b`, `0x40402562`,
  and `0xbe4c5582`; cleanup showed successful `close(3)` and final `munmap`.
- A Python parser cross-check reported the same `blk.1.attn_norm.weight`
  descriptor: one dimension `3072`, type `0`, relative offset `554864640`.
- A final filtered real-target smoke after relink preserved the same layer-1
  descriptor fields and post-FFN residual exact words.
- `python3 -m py_compile work/oracle/*.py` passed.
- `find src -type f ! -name '*.s' -print` produced no runtime non-assembly
  source files.
- `git ls-files` found no tracked model files, GGUFs, large logs, traces, or
  dumps.
- `git diff --check` passed.
- No external oracle script was rerun because runtime math, shared oracle
  inputs, and public exact-hex outputs were unchanged.

## Next Exact Step

In `src/entry/_start.s`, add a guarded layer-1 attention RMSNorm smoke that
uses `token0_post_ffn_residual` as input and the reusable
`blk.1.attn_norm.weight` descriptor as weights, records a status flag, and
prints only the status for this first math step.
