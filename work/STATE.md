# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add a status-only `token0_layer1_attn_v_matvec` smoke using the reusable
`blk.1.attn_v.weight` descriptor, without publishing value output words yet.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- The GGUF loader validates the narrow v3 little-endian target shape, records
  tensor-info and tensor-data offsets, keeps fixed layer-0 descriptor summaries,
  and exposes reusable descriptor lookup through `gguf_lookup_tensor_info`.
- Token-0 layer-0 smokes run through embedding dequantization, attention, FFN,
  post-FFN residual, and exact public slices matched by external oracle notes.
- Layer-1 attention RMSNorm uses `token0_post_ffn_residual` plus the reusable
  `blk.1.attn_norm.weight` descriptor. The real target prints status 1 and
  exact words `0xc05ae197`, `0xc1210d34`, `0x426154e8`, and `0xc0a7934a`,
  matching the external oracle.
- The runtime captures reusable layer-1 descriptors for `blk.1.attn_q.weight`,
  `blk.1.attn_k.weight`, and `blk.1.attn_v.weight`. The real target reports
  query dimensions `3072x4096`, type `8`, offset `568246272`; key dimensions
  `3072x1024`, type `8`, offset `551522304`; and value dimensions
  `3072x1024`, type `8`, offset `581615616`.
- The guarded `token0_layer1_attn_q_matvec` smoke writes a private output buffer
  and publishes the first four raw f32 words only when status is 1. The real
  target reports `0x3f98c6d6`, `0x3e72aeb6`, `0x3e641287`, and `0x3e76b8f1`,
  matching the external oracle.
- The guarded `token0_layer1_attn_k_matvec` smoke consumes the layer-1 attention
  RMSNorm activation and reusable `blk.1.attn_k.weight` descriptor. It requires
  exact `3072x1024` Q8_0 shape, bounds the full mapped matrix payload, writes a
  private output buffer, and publishes the first four raw f32 words only when
  status is 1. The real target reports `0x3fb2a129`, `0x405dbdbe`,
  `0x3f5611d3`, and `0x3f1e325d`.
- External oracle tooling now independently recomputes the published
  `token0_layer1_attn_k_output` slice from the full layer-0 FFN and layer-1
  attention RMSNorm chain. The oracle matches the runtime key words exactly.

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
- `work/oracle/token0_layer1_attn_norm_oracle.py`
- `work/oracle/token0_layer1_attn_q_oracle.py`
- `work/oracle/token0_layer1_attn_k_oracle.py`
- `work/oracle/token0-layer1-attn-norm.md`
- `work/oracle/token0-layer1-attn-q-output.md`
- `work/oracle/token0-layer1-attn-k-output.md`
- `work/reviews/2026-05-10-token0-forward-review.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

- `make && make check` passed; the harnesses printed `q8_0_dot: ok`,
  `rmsnorm: ok`, `swiglu: ok`, and `gguf_lookup: ok`.
- `./mistral-asm` on the real target GGUF printed
  `layer1_attn_v_tensor_found: 1`, dimensions `3072x1024`, type `8`, and
  offset `581615616`; an external descriptor parser reported the same
  `blk.1.attn_v.weight` fields.
- A temporary empty valid GGUF printed zeroed layer-1 query/key/value descriptor
  fields and kept `token0_layer1_attn_norm`, `token0_layer1_attn_q_matvec`, and
  `token0_layer1_attn_k_matvec` at 0.
- Existing layer-1 query/key public output words stayed unchanged on the real
  target.
- `python3 -m py_compile work/oracle/*.py`, `git diff --check`, runtime source
  purity scan, static-link inspection, tracked artifact scan, and `--help`
  smoke passed.

## Next Exact Step

Add a status-only `token0_layer1_attn_v_matvec` smoke using the reusable
`blk.1.attn_v.weight` descriptor, without publishing value output words yet.
