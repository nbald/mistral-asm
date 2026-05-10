# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add a status-only `token0_layer1_attn_q_matvec` smoke using the already
confirmed `blk.1.attn_q.weight` descriptor, without publishing output words yet.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, records
  tensor-info and tensor-data offsets, keeps fixed layer-0 descriptor summaries,
  and exposes reusable descriptor lookup through `gguf_lookup_tensor_info`.
- Token-0 layer-0 smokes run through embedding dequantization, attention, FFN,
  post-FFN residual, and exact public slices matched by external oracle notes.
  The post-FFN residual words remain `0xbe256913`, `0xbf15734b`,
  `0x40402562`, and `0xbe4c5582`.
- Layer-1 attention RMSNorm uses `token0_post_ffn_residual` plus the reusable
  `blk.1.attn_norm.weight` descriptor. The real target prints status 1 and
  exact words `0xc05ae197`, `0xc1210d34`, `0x426154e8`, and `0xc0a7934a`,
  matching the external oracle.
- The runtime now also captures `blk.1.attn_q.weight` in a separate reusable
  160-byte scratch descriptor and prints descriptor-only fields. The real target
  reports dimensions `3072x4096`, GGML type `8` (`Q8_0`), and relative offset
  `568246272`; empty synthetic GGUFs print zeroed layer-1 query fields.

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
- `work/oracle/token0_attn_q_oracle.py`
- `work/oracle/token0_post_ffn_residual_oracle.py`
- `work/oracle/token0_layer1_attn_norm_oracle.py`
- `work/oracle/token0-layer1-attn-norm.md`
- `work/reviews/2026-05-10-token0-forward-review.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

- `make clean`, `make`, and `make check` passed; the harnesses printed
  `q8_0_dot: ok`, `rmsnorm: ok`, `swiglu: ok`, and `gguf_lookup: ok`.
- `./mistral-asm --help` returned status 0. The unsupported prompt-generation
  form returned status 2 with the usage diagnostic.
- `readelf -d` reported no dynamic section; `readelf -l` showed only LOAD and
  GNU_STACK program headers, with no interpreter or dynamic program header.
- Synthetic valid and malformed GGUF fixtures preserved expected behavior:
  valid empty input returned status 0 with `tensor_infos_offset: 24`,
  `tensor_data_offset: 0`, zeroed layer-1 norm and query lookup fields,
  `token0_post_ffn_residual: 0`, `token0_layer1_attn_norm: 0`, and no layer-1
  exact-hex labels; bad magic returned status 3; a truncated tensor directory
  returned status 3.
- The real target model under `strace -e trace=mmap,munmap,close` returned
  status 0, printed `layer1_attn_q_tensor_found: 1`,
  `layer1_attn_q_tensor_n_dimensions: 2`, dimensions `3072` and `4096`, type
  `8`, offset `568246272`, preserved the recorded post-FFN residual and
  layer-1 attention RMSNorm words, and cleanup showed successful `close(3)` and
  final `munmap`.
- The external GGUF parser in `work/oracle/token0_attn_q_oracle.py` reported
  the same `blk.1.attn_q.weight` type, dimensions, and relative offset.
- `python3 -m py_compile work/oracle/*.py` passed.
- `find src -type f ! -name '*.s' -print` produced no runtime non-assembly
  source files.
- `git ls-files` found no tracked model files, GGUFs, large logs, traces, or
  dumps.
- `git diff --check` passed.

## Next Exact Step

Add a status-only `token0_layer1_attn_q_matvec` smoke that consumes
`token0_layer1_attn_norm_activation` and the reusable `blk.1.attn_q.weight`
descriptor, verifies exact target dimensions and mapping bounds, writes a
private static output buffer, and prints only the status flag.
