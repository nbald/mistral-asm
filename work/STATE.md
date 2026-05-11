# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add descriptor-only runtime coverage for `blk.2.attn_output.weight` so the
next layer-2 single-token attention context/output steps can be shape-gated.

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

- No current blocker to adding descriptor-only `blk.2.attn_output.weight`
  coverage.
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

Layer-2 attention value output slice verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- real target runtime smoke printed `token0_layer2_attn_v_matvec: 1` and value
  words `0x3d38e19b`, `0x3ae7765b`, `0xbd4bbba8`, `0xbf48b85f`
- `python3 work/oracle/token0_layer2_attn_v_oracle.py <target.gguf>` printed
  the same four layer-2 value words
- temporary 24-byte empty valid GGUF kept layer-2 norm/query/key/value statuses
  at `0` and emitted no guarded layer-2 norm/Q/K/V output labels
- `git diff --check`
- runtime source extension scan allowing `.s` and tracked `.inc` source files
- tracked include dependency scan
- static-link/no-dynamic-section/file check
- undefined-symbol check
- exported-symbol inspection for the layer-2 value wrapper/status/output symbols
- tracked-artifact and tracked large-file scans

## Next Exact Step

Add descriptor-only reusable lookup coverage for `blk.2.attn_output.weight` in
a focused place that does not grow `src/infer/token0_layer2_attn.s` past the
1000-line threshold. Store the descriptor in its own layer-2 scratch slot,
publish found/dimension/type/offset summary lines after the layer-2 value
descriptor, avoid reading output-projection payload bytes, update help/state
docs, and verify on the real target plus an empty valid GGUF.
