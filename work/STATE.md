# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add an external oracle comparison for the token-0 layer-1 attention RMSNorm
exact-hex slice.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, records
  tensor-info and tensor-data offsets, keeps fixed layer-0 descriptor summaries,
  and exposes reusable tensor lookup for later descriptors.
- Token-0 layer-0 smokes now cover embedding dequantization, attention RMSNorm,
  Q/K/V projections, single-token context expansion, attention output
  projection, post-attention residual, FFN RMSNorm, FFN gate/up projections,
  SwiGLU, FFN down projection, and post-FFN residual.
- Public exact-hex slices and external oracle notes exist through the
  post-FFN residual. The recorded post-FFN residual words remain
  `0xbe256913`, `0xbf15734b`, `0x40402562`, and `0xbe4c5582`.
- `gguf_lookup_tensor_info` captures `blk.1.attn_norm.weight` into a generic
  160-byte scratch descriptor; the real target reports one f32 dimension
  `3072` at relative offset `554864640`.
- The runtime now uses `token0_post_ffn_residual` plus the reusable
  `blk.1.attn_norm.weight` descriptor for a status-only layer-1 attention
  RMSNorm smoke, writing `token0_layer1_attn_norm_activation` and printing
  `token0_layer1_attn_norm: 1` on the real target.
- The layer-1 attention RMSNorm smoke now prints a guarded four-word exact-hex
  activation slice after status 1. The real target printed
  `0xc05ae197`, `0xc1210d34`, `0x426154e8`, and `0xc0a7934a`.

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
- `work/oracle/token0_post_ffn_residual_oracle.py`
- `work/oracle/token0-post-ffn-residual.md`
- `work/reviews/2026-05-10-token0-forward-review.md`
- `work/STATE.md`
- `work/WORKLOG.md`

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
  `tensor_data_offset: 0`, zeroed layer-1 lookup fields,
  `token0_post_ffn_residual: 0`, `token0_layer1_attn_norm: 0`, and no layer-1
  exact-hex labels; bad magic returned status 3; a truncated tensor directory
  returned status 3.
- The real target model under `strace -e trace=mmap,munmap,close` returned
  status 0, printed the expected layer-1 descriptor fields, preserved Q/K/V
  status 1 and the recorded post-FFN residual words, printed
  `token0_layer1_attn_norm: 1`, printed layer-1 attention RMSNorm words
  `0xc05ae197`, `0xc1210d34`, `0x426154e8`, and `0xc0a7934a`, and cleanup
  showed successful `close(3)` and final `munmap`.
- `python3 -m py_compile work/oracle/*.py` passed.
- `find src -type f ! -name '*.s' -print` produced no runtime non-assembly
  source files.
- `git ls-files` found no tracked model files, GGUFs, large logs, traces, or
  dumps.
- `git diff --check` passed.
- No external oracle script was rerun because the new public exact-hex output is
  intentionally awaiting a separate oracle comparison step.

## Next Exact Step

Add external oracle tooling and a comparison note for
`token0_layer1_attn_norm_activation`, reusing the existing post-FFN residual
oracle path and comparing the four runtime words now printed by `mistral-asm`.
