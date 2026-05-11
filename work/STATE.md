# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add guarded first-four exact-hex output slice and external oracle coverage for
the token-0 layer-2 attention output-projection result now retained by the
status-only matvec module.

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
  publishes a status line only.
- Durable external oracle coverage for the layer-2 value projection lives in
  `work/oracle/token0_layer2_attn_v_oracle.py` and
  `work/oracle/token0-layer2-attn-v-output.md`. It recomputes the full upstream
  layer-1 post-FFN residual, applies layer-2 attention RMSNorm, dots the first
  four rows of `blk.2.attn_v.weight`, and matches the runtime exactly.
- The required repository-wide review gate and the completed layer-1 FFN branch
  review gate are already complete. Existing review notes remain under
  `work/reviews/`.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or small
  include fragments with Makefile-tracked dependencies.

## Known Blockers

- No current blocker to adding layer-2 output-projection slice/oracle coverage.
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
- `work/oracle/token0-layer2-attn-v-output.md`
- `work/STATE.md`
- `work/WORKLOG.md`
- `work/prompts/continue.md`

## Last Verification

Layer-2 attention output-projection status verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- real target runtime smoke reported the layer-2 output descriptor found `1`
  with shape `[4096 x 3072]`, Q8_0 type `8`, and relative offset `678567936`;
  the prerequisite layer-2 value/context statuses stayed at `1`, and
  `token0_layer2_attn_output_matvec: 1` printed with no
  `token0_layer2_attn_output*_f32_hex` labels
- temporary 24-byte empty valid GGUF kept layer-2 value/output descriptor slots
  zeroed, kept layer-2 norm/query/key/value/context/output statuses at `0`, and
  emitted no guarded layer-2 exact-hex output labels
- `git diff --check`
- runtime source extension scan allowing `.s` and tracked `.inc` source files
- tracked include dependency scan
- static-link/no-dynamic-section/file check
- undefined-symbol check
- exported-symbol inspection for the layer-2 output runner/status/buffer
- tracked-artifact and tracked large-file scans

## Next Exact Step

Publish `token0_layer2_attn_output0..3_f32_hex` only behind
`token0_layer2_attn_output_matvec_status == 1`, add an external oracle that
recomputes the layer-2 attention output projection through the first four rows
of `blk.2.attn_output.weight`, and verify the runtime words match while the
empty valid GGUF still prints no guarded layer-2 output-projection words.
