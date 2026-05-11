# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add descriptor-only coverage for `blk.2.ffn_gate.weight` in the entry-side
lookup chain, retaining it in its own scratch slot and printing found,
dimension count, dim0, dim1, type, and relative offset without reading payload
bytes.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support is intentionally narrow: v3 little-endian target GGUF parsing,
  metadata summaries, tensor directory walking, and reusable descriptor lookups.
- Token-0 smoke coverage now reaches the layer-2 post-attention residual and
  layer-2 FFN RMSNorm activation.
- Focused layer-2 attention runtime code owns layer-2 attention RMSNorm, Q/K/V,
  context, output projection, and post-attention residual buffers with guarded
  exact-hex slices under matching success statuses.
- Layer-2 FFN RMSNorm coverage lives in `src/infer/token0_layer2_ffn.s`. It
  waits for the retained layer-2 post-attention residual and
  `blk.2.ffn_norm.weight` descriptor, checks epsilon metadata, f32 `[3072]`
  shape, mapping base, and complete payload bounds, fills a private 3072-f32
  activation buffer, and prints `token0_layer2_ffn_norm0_f32_hex` through
  `token0_layer2_ffn_norm3_f32_hex` only when
  `token0_layer2_ffn_norm_status == 1`.
- Durable external oracle coverage for the layer-2 FFN RMSNorm slice lives in
  `work/oracle/token0_layer2_ffn_norm_oracle.py` and
  `work/oracle/token0-layer2-ffn-norm.md`. It recomputes the full upstream
  layer-1 post-FFN residual, layer-2 attention RMSNorm/value/context/output, the
  full layer-2 post-attention residual, then applies `blk.2.ffn_norm.weight` and
  matches the runtime first-four exact-hex words.
- Existing focused oracle notes cover the layer-2 attention value, attention
  output projection, and post-attention residual handoff slices.
- The repository-wide, layer-1 FFN branch, and layer-2 attention branch review
  gates are complete with no blocking findings. Review notes remain under
  `work/reviews/`.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or small
  include fragments with Makefile-tracked dependencies.

## Known Blockers

- No current blocker to adding descriptor-only coverage for
  `blk.2.ffn_gate.weight`.
- The next descriptor step must not read `blk.2.ffn_gate.weight` payload bytes.
- `src/infer/token0_layer2_attn.s` is 997 lines after the value slice step. Do
  not add substantial new code to it before splitting or moving the next
  responsibility into a focused module.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `src/entry/_start.s`
- `src/entry/start/**/*.inc`
- `src/gguf/load_header.s`
- `src/gguf/load_header/*.inc`
- `src/infer/token0_layer2_attn.s`
- `src/infer/token0_layer2_attn_context.s`
- `src/infer/token0_layer2_attn_output.s`
- `src/infer/token0_layer2_post_attn_residual.s`
- `src/infer/token0_layer2_ffn.s`
- `src/infer/token0_layer1_ffn.s`
- `src/infer/token0_layer1_ffn_down.s`
- `src/math/*.s`
- `src/runtime/text.s`
- `src/sys/*.s`
- `tests/*.s`
- `Makefile`
- `work/oracle/token0_layer2_ffn_norm_oracle.py`
- `work/oracle/token0-layer2-ffn-norm.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-2 FFN RMSNorm activation-slice verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- real target runtime smoke printed `token0_layer2_ffn_norm: 1` followed by
  `0x40522d9d`, `0xbf5d5852`, `0x3fc92f4e`, and `0x3f3f5579` for
  `token0_layer2_ffn_norm0_f32_hex` through
  `token0_layer2_ffn_norm3_f32_hex`
- `work/oracle/token0_layer2_ffn_norm_oracle.py` on the target model matched
  those four runtime words exactly while preserving the reviewed layer-2
  attention output and post-attention residual public words
- temporary 24-byte empty valid GGUF kept `layer2_ffn_norm_tensor_*` fields
  zeroed, kept `token0_layer2_attn_output_matvec`,
  `token0_layer2_post_attn_residual`, and `token0_layer2_ffn_norm` at `0`, and
  emitted no guarded layer-2 FFN norm exact-hex words
- `git diff --check`
- runtime source extension scan allowing `.s` and tracked `.inc` source files
- tracked include dependency scan
- static-link/no-dynamic-section/file check
- undefined-symbol check
- exported-symbol inspection for `run_token0_layer2_ffn_norm_status`,
  `token0_layer2_ffn_norm_status`, and `token0_layer2_ffn_norm_activation`
- tracked-artifact and tracked large-file scans

## Next Exact Step

Add descriptor-only coverage for `blk.2.ffn_gate.weight` in the entry-side
lookup chain, retaining it in its own scratch slot and printing found,
dimension count, dim0, dim1, type, and relative offset without reading payload
bytes.
