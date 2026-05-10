# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add a guarded status-only `token0_layer1_attn_k_matvec` smoke using the
reusable `blk.1.attn_k.weight` descriptor and the existing layer-1 attention
RMSNorm activation. Keep its output private and do not publish exact words yet.

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
- The runtime now captures `blk.1.attn_q.weight` and `blk.1.attn_k.weight` in
  separate reusable 160-byte scratch descriptors and prints descriptor-only
  fields. The real target reports query dimensions `3072x4096`, GGML type `8`,
  and relative offset `568246272`; it reports key dimensions `3072x1024`, GGML
  type `8`, and relative offset `551522304`. Empty synthetic GGUFs print zeroed
  layer-1 query/key fields.
- A guarded `token0_layer1_attn_q_matvec` smoke consumes the layer-1 attention
  RMSNorm activation and the reusable `blk.1.attn_q.weight` descriptor. It
  requires exact `3072x4096` Q8_0 shape, bounds the full mapped matrix payload,
  writes a private static output buffer, and publishes the first four raw f32
  words only when the status is 1. The real target reports status 1 and words
  `0x3f98c6d6`, `0x3e72aeb6`, `0x3e641287`, and `0x3e76b8f1`; empty synthetic
  GGUFs report status 0 and publish no layer-1 query output words.
- The external `token0_layer1_attn_q_oracle.py` recomputes the full layer-1
  attention RMSNorm activation from the existing layer-0 oracle chain, dots it
  with the first four rows of `blk.1.attn_q.weight`, and matches the runtime
  layer-1 query output words exactly. `token0_layer1_attn_norm_oracle.py` now
  keeps the full 3072-word activation available for downstream oracle checks
  while preserving its existing public four-word output.

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
- `work/oracle/token0_layer1_attn_q_oracle.py`
- `work/oracle/token0-layer1-attn-norm.md`
- `work/oracle/token0-layer1-attn-q-output.md`
- `work/reviews/2026-05-10-token0-forward-review.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

- `make && make check` passed; the harnesses printed `q8_0_dot: ok`,
  `rmsnorm: ok`, `swiglu: ok`, and `gguf_lookup: ok`.
- `python3 -m py_compile work/oracle/*.py` passed.
- `python3 work/oracle/token0_layer1_attn_q_oracle.py` on the real target GGUF
  printed layer-1 query oracle words `0x3f98c6d6`, `0x3e72aeb6`,
  `0x3e641287`, and `0x3e76b8f1`, with the recorded post-FFN residual and
  layer-1 attention RMSNorm prerequisite words unchanged.
- `./mistral-asm` on the real target GGUF printed
  `layer1_attn_k_tensor_found: 1`, dimensions `3072x1024`, GGML type `8`, and
  relative offset `551522304`, matching an external parser check. Existing
  layer-1 query output words remained `0x3f98c6d6`, `0x3e72aeb6`,
  `0x3e641287`, and `0x3e76b8f1`.
- An empty synthetic GGUF printed zeroed layer-1 key descriptor fields and kept
  `token0_layer1_attn_q_matvec: 0`.
- `find src -type f ! -name '*.s' -print` produced no runtime non-assembly
  source files.
- `git ls-files` found no tracked model files, GGUFs, large logs, traces, or
  dumps.
- `git diff --check` passed.

## Next Exact Step

Add a guarded status-only `token0_layer1_attn_k_matvec` smoke using the
reusable `blk.1.attn_k.weight` descriptor and the existing layer-1 attention
RMSNorm activation. Keep its output private and do not publish exact words yet.
