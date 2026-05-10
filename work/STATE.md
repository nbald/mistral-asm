# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish the first four raw f32 words of `token0_layer1_ffn_norm_activation`
behind the existing `token0_layer1_ffn_norm_status` gate and verify the real
target plus an empty valid GGUF skip.

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
  `blk.1.attn_k.weight`, `blk.1.attn_v.weight`, and
  `blk.1.attn_output.weight`. The real target reports query dimensions
  `3072x4096`, type `8`, offset `568246272`; key dimensions `3072x1024`,
  type `8`, offset `551522304`; value dimensions `3072x1024`, type `8`,
  offset `581615616`; and output dimensions `4096x3072`, type `8`, offset
  `554876928`.
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
- The guarded `token0_layer1_attn_v_matvec` smoke consumes the layer-1
  attention RMSNorm activation and reusable `blk.1.attn_v.weight` descriptor.
  It requires exact `3072x1024` Q8_0 shape, bounds the full mapped matrix
  payload, writes a private output buffer, and publishes the first four raw f32
  words only when status is 1. The real target reports `0x3d6bd91b`,
  `0x3d763224`, `0x3d709b92`, and `0xbcca1ab6`.
- External oracle tooling now independently recomputes the published
  `token0_layer1_attn_v_output` slice from the full layer-0 FFN and layer-1
  attention RMSNorm chain. The oracle matches the runtime value words exactly.
- The guarded `token0_layer1_attn_context_smoke` consumes the layer-1 value
  projection output and uses `blk.1.attn_output.weight` only as an exact Q8_0
  `4096x3072` shape guard. It expands the `1024` f32 grouped-query value output
  into a private `4096` f32 context buffer and publishes the first four raw f32
  words only when status is 1. The real target reports `0x3d6bd91b`,
  `0x3d763224`, `0x3d709b92`, and `0xbcca1ab6`, matching the first four
  layer-1 value projection words because the first query head receives the
  first KV-head value block unchanged.
- An external oracle note now documents the one-token grouped-query context
  rule for `token0_layer1_attn_context`: softmax over a single key/value entry
  is 1, each KV-head value block is copied into four query heads, and the first
  four published context words therefore equal the first four independently
  recomputed layer-1 value projection words.
- The guarded `token0_layer1_attn_output_matvec` smoke consumes the private
  `token0_layer1_attn_context` buffer and reusable
  `blk.1.attn_output.weight` descriptor. It requires exact Q8_0 `4096x3072`
  shape, bounds the complete mapped matrix payload, writes a private
  `3072`-f32 output buffer, and publishes the first four raw f32 words only when
  status is 1. The real target reports `0x3deaa744`, `0x3cb6f294`,
  `0xbf14cf4f`, and `0xbced5550`.
- External oracle tooling now independently recomputes the published
  `token0_layer1_attn_output` slice from the full layer-1 value projection,
  one-token grouped-query context, and `blk.1.attn_output.weight`. The oracle
  matches the runtime output-projection words exactly.
- The guarded `token0_layer1_post_attn_residual` smoke consumes the private
  `token0_post_ffn_residual` and `token0_layer1_attn_output` buffers, requires
  the layer-1 output descriptor to retain the exact 3072-row hidden width, and
  writes a private 3072-f32 residual buffer only when prerequisites are present.
  It now publishes the first four raw f32 words only when status is 1. The real
  target reports `0xbd4055c4`, `0xbf0fbbb6`, `0x401af18e`, and `0xbe6a002c`;
  an empty valid GGUF reports status 0 and emits no layer-1 post-attention
  residual word labels.
- External oracle tooling now independently recomputes the published
  `token0_layer1_post_attn_residual` slice from the full layer-0 post-FFN
  residual plus the first four layer-1 attention output-projection words. The
  oracle matches the runtime residual words exactly.
- The runtime now captures a reusable descriptor slot for
  `blk.1.ffn_norm.weight` without reading its tensor payload. The real target
  reports found `1`, dimensions `3072`, type `0`, and offset `645120000`,
  matching an independent GGUF parser cross-check.
- The guarded status-only `token0_layer1_ffn_norm_smoke` consumes the private
  `token0_layer1_post_attn_residual` buffer and reusable
  `blk.1.ffn_norm.weight` descriptor, requires exact f32 `[3072]` shape, bounds
  the complete mapped weight span, writes a private 3072-f32 activation buffer,
  and prints only `token0_layer1_ffn_norm: 1` on the real target. An empty valid
  GGUF reports status 0 and emits no layer-1 FFN norm word labels.

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
- `work/oracle/token0_layer1_attn_v_oracle.py`
- `work/oracle/token0_layer1_attn_output_oracle.py`
- `work/oracle/token0_layer1_post_attn_residual_oracle.py`
- `work/oracle/token0-layer1-attn-norm.md`
- `work/oracle/token0-layer1-attn-q-output.md`
- `work/oracle/token0-layer1-attn-k-output.md`
- `work/oracle/token0-layer1-attn-v-output.md`
- `work/oracle/token0-layer1-attn-context.md`
- `work/oracle/token0-layer1-attn-output.md`
- `work/oracle/token0-layer1-post-attn-residual.md`
- `work/reviews/2026-05-10-token0-forward-review.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

- `make` and `make check` passed after adding the status-only layer-1 FFN
  RMSNorm smoke; harnesses printed `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- `./mistral-asm` on the real target GGUF printed
  `token0_layer1_ffn_norm: 1`; established layer-1 output-projection and
  post-attention residual exact-hex words stayed unchanged.
- A temporary empty valid GGUF printed `token0_layer1_ffn_norm: 0` and emitted
  no `token0_layer1_ffn_norm*_f32_hex` labels.
- `python3 -m py_compile work/oracle/*.py`, `./mistral-asm --help`,
  `git diff --check`, runtime source purity scan, static-link inspection,
  tracked artifact scan, status-only label scan, and cleanup tracing passed.
  Cleanup tracing showed `close(3)` before final `munmap`.

## Next Exact Step

Publish the first four raw f32 words of `token0_layer1_ffn_norm_activation`
only when `token0_layer1_ffn_norm_status` is 1, then verify the real target
plus an empty valid GGUF skip.
