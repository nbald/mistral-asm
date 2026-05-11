# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish the first guarded layer-2 FFN RMSNorm activation slice and add a
focused oracle note for `blk.2.ffn_norm.weight`.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support is intentionally narrow: v3 little-endian target GGUF parsing,
  metadata summaries, tensor directory walking, and reusable descriptor lookups.
- Token-0 smoke coverage now reaches layer-1 post-FFN residual and then layer-2
  attention RMSNorm, query, key, and value projections.
- Focused layer-2 attention runtime code lives in
  `src/infer/token0_layer2_attn.s`. It owns the layer-2 RMSNorm activation and
  Q/K/V output buffers, guards all tensor payload reads by status, type, shape,
  mapping base, and complete payload bounds, and publishes first-four exact-hex
  slices only after successful statuses.
- The first four `token0_layer2_attn_v_output*_f32_hex` words are now printed
  behind `token0_layer2_attn_v_matvec_status == 1`.
- Descriptor-only coverage for `blk.2.attn_output.weight` is complete. The
  descriptor is retained in its own layer-2 scratch slot, printed immediately
  after the layer-2 value descriptor, and no output-projection payload bytes are
  read by this step.
- Descriptor-only coverage for `blk.2.ffn_norm.weight` is complete. The
  descriptor is retained in its own layer-2 scratch slot, printed immediately
  after the layer-2 output projection descriptor, and no FFN norm payload bytes
  are read by this step.
- Layer-2 single-token attention context smoke now lives in
  `src/infer/token0_layer2_attn_context.s`. It requires the retained layer-2
  value projection status and exact layer-2 value/output-projection descriptor
  shapes, expands the 1024-f32 grouped-query value output into a 4096-f32
  context by repeating each 128-f32 KV-head block for its four query heads, and
  publishes a guarded first-four context slice. It does not read
  `blk.2.attn_output.weight` payload bytes.
- Layer-2 attention output-projection status now lives in
  `src/infer/token0_layer2_attn_output.s`. It requires the retained layer-2
  context status and exact `blk.2.attn_output.weight` Q8_0 `[4096 x 3072]`
  descriptor, proves the complete mapped payload span before calling
  `q8_0_matvec_f32`, fills a private 3072-f32 output buffer on success, and
  publishes a guarded first-four exact-hex output slice only when
  `token0_layer2_attn_output_matvec_status == 1`.
- Layer-2 post-attention residual coverage now lives in
  `src/infer/token0_layer2_post_attn_residual.s`. It waits for the retained
  layer-1 post-FFN residual and layer-2 attention output-projection statuses,
  rechecks the 3072-wide output descriptor, writes a private 3072-f32 residual
  buffer with scalar f32 adds, and publishes first-four exact-hex residual
  words only when `token0_layer2_post_attn_residual_status == 1`.
- Layer-2 FFN RMSNorm status-only coverage now lives in
  `src/infer/token0_layer2_ffn.s`. It waits for the retained layer-2
  post-attention residual and `blk.2.ffn_norm.weight` descriptor, checks the
  retained RMSNorm epsilon, f32 type, `[3072]` shape, mapping base, and complete
  payload bounds, writes a private 3072-f32 activation buffer on success, and
  prints only `token0_layer2_ffn_norm` status for this step.
- Durable external oracle coverage for the layer-2 value projection lives in
  `work/oracle/token0_layer2_attn_v_oracle.py` and
  `work/oracle/token0-layer2-attn-v-output.md`. It recomputes the full upstream
  layer-1 post-FFN residual, applies layer-2 attention RMSNorm, dots the first
  four rows of `blk.2.attn_v.weight`, and matches the runtime exactly.
- Durable external oracle coverage for the layer-2 attention output projection
  lives in `work/oracle/token0_layer2_attn_output_oracle.py` and
  `work/oracle/token0-layer2-attn-output.md`. It recomputes the full upstream
  layer-1 post-FFN residual, applies layer-2 attention RMSNorm, computes all
  1024 layer-2 value rows, expands the 4096-f32 single-token grouped-query
  context, dots the first four rows of `blk.2.attn_output.weight`, and matches
  the runtime exactly.
- Durable external oracle coverage for the layer-2 post-attention residual
  lives in `work/oracle/token0_layer2_post_attn_residual_oracle.py` and
  `work/oracle/token0-layer2-post-attn-residual.md`. It reuses the layer-2
  attention output oracle path, adds the first four layer-1 post-FFN residual
  and layer-2 attention output words with f32 rounding, and matches the runtime
  exactly.
- The required repository-wide review gate and the completed layer-1 FFN branch
  review gate are already complete. Existing review notes remain under
  `work/reviews/`.
- Layer-2 attention branch review gate pass 1 is complete in
  `work/reviews/2026-05-11-layer2-attn-branch-review-1.md` with no blocking
  findings. It checked status gates, tensor shape/type/bounds checks, exact-hex
  slice publication, oracle arithmetic, documentation consistency, split risk,
  real-target behavior, and empty-GGUF guard behavior.
- Layer-2 attention branch review gate pass 2 is complete in
  `work/reviews/2026-05-11-layer2-attn-branch-review-2.md` with no blocking
  findings. It independently checked branch ordering, handoff ownership, failure
  modes, oracle coverage gaps, and readiness to resume layer-2 FFN feature work.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or small
  include fragments with Makefile-tracked dependencies.

## Known Blockers

- No current blocker to publishing the layer-2 FFN RMSNorm activation slice.
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
- `src/entry/start/constants.inc`
- `src/entry/start/state.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/lookup_summary/layer2.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/summary_labels.inc`
- `src/infer/token0_layer1_ffn.s`
- `src/infer/token0_layer1_ffn_down.s`
- `src/math/*.s`
- `src/runtime/text.s`
- `src/sys/*.s`
- `tests/*.s`
- `Makefile`
- `work/oracle/token0_layer2_attn_norm_oracle.py`
- `work/oracle/token0_layer2_attn_q_oracle.py`
- `work/oracle/token0_layer2_attn_k_oracle.py`
- `work/oracle/token0_layer2_attn_v_oracle.py`
- `work/oracle/token0_layer2_attn_output_oracle.py`
- `work/oracle/token0_layer2_post_attn_residual_oracle.py`
- `work/oracle/token0-layer2-attn-v-output.md`
- `work/oracle/token0-layer2-attn-output.md`
- `work/oracle/token0-layer2-post-attn-residual.md`
- `work/reviews/2026-05-11-layer2-attn-branch-review-2.md`
- `work/STATE.md`
- `work/WORKLOG.md`
- `work/prompts/continue.md`

## Last Verification

Layer-2 FFN RMSNorm status-only verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- real target runtime smoke printed `layer2_ffn_norm_tensor_found: 1`,
  `layer2_ffn_norm_tensor_n_dimensions: 1`, `layer2_ffn_norm_tensor_dim0: 3072`,
  `layer2_ffn_norm_tensor_ggml_type: 0`, and
  `layer2_ffn_norm_tensor_offset: 768811008`, while preserving
  `token0_layer2_attn_output_matvec: 1` and
  `token0_layer2_post_attn_residual: 1`, and newly printing
  `token0_layer2_ffn_norm: 1`
- temporary 24-byte empty valid GGUF kept the layer-2 output and FFN norm
  descriptor slots zeroed and kept the reviewed layer-2 output/residual and new
  layer-2 FFN norm statuses at `0`
- `git diff --check`
- runtime source extension scan allowing `.s` and tracked `.inc` source files
- tracked include dependency scan
- static-link/no-dynamic-section/file check
- undefined-symbol check
- exported-symbol inspection for
  `run_token0_layer2_ffn_norm_status`,
  `token0_layer2_ffn_norm_status`, and
  `token0_layer2_ffn_norm_activation`
- tracked-artifact and tracked large-file scans

## Next Exact Step

Extend `src/infer/token0_layer2_ffn.s` to print
`token0_layer2_ffn_norm0_f32_hex` through
`token0_layer2_ffn_norm3_f32_hex` only when
`token0_layer2_ffn_norm_status == 1`, and add a focused oracle note/script that
recomputes those four words from the retained layer-2 post-attention residual
path.
