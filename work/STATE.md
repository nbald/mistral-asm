# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Start layer-6 attention coverage with a descriptor-only
`blk.6.attn_norm.weight` lookup/setup step. Add focused layer-6 state,
rodata/summary labels, lookup summary, bootstrap wiring, help/contract text, and
Makefile include dependencies only; do not read tensor payload bytes or publish a
layer-6 attention norm status in that step.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads only inside guarded smoke paths.
- Token-0 forward coverage is complete through the layer-5 post-FFN residual.
  The first four retained layer-5 post-FFN residual words are `0x440c3ce5`,
  `0xc1fd49b3`, `0xc2a998e5`, and `0xc1616193`.
- Layer-5 attention coverage is complete through RMSNorm, Q/K/V projection
  handoff, single-token context, output projection, and post-attention residual.
- Layer-5 FFN coverage is complete through FFN RMSNorm, gate/up projections,
  SwiGLU, down projection, and post-FFN residual. Public handoffs are the FFN
  norm activation, SwiGLU output, and post-FFN residual; gate/up/down projection
  buffers remain private.
- The two-pass review gates for the completed layer-4 FFN chain, layer-5
  attention residual handoff chain, and layer-5 FFN chain completed cleanly under
  `work/reviews/`.

## Verification Status

- Latest verification for layer-5 FFN chain review gate pass 2:
  `make clean all check` passed; `python3 -m py_compile work/oracle/*.py`
  passed; the real target reported the reviewed layer-5 FFN descriptors and
  statuses as expected; the focused layer-5 post-FFN residual oracle comparison
  matched 85 exact values; a packed 24-byte zero-count GGUF kept reviewed
  descriptor flags and dependent statuses fail-closed with no guarded layer-5
  FFN exact-hex output; static-link/no-dynamic-section/no-interpreter,
  undefined-symbol, runtime source extension, include dependency, tracked
  artifact, tracked large-file, exported/local symbol, line-count, and
  whitespace scans passed.

## Known Blockers

- No functional blocker is known.
- Keep new work in focused modules. Do not add substantial code to files near or
  above 1000 lines before splitting or moving work into a focused module.
  Current watch list includes `src/infer/token0_layer2_attn.s` at 997 lines,
  `src/infer/token0_layer5_attn.s` at 996 lines,
  `src/infer/token0_layer5_ffn.s` at 952 lines,
  `src/infer/token0_layer4_attn.s` at 945 lines,
  `src/infer/token0_layer4_ffn.s` at 945 lines,
  `src/infer/token0_layer2_ffn.s` at 943 lines,
  `src/infer/token0_layer3_ffn.s` at 942 lines,
  `src/infer/token0_layer1_ffn.s` at 929 lines,
  `src/entry/start/lookup_summary/layer5.inc` at 898 lines, and
  `src/entry/start/lookup_summary.inc` at 903 lines.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/_start.s`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer5.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/entry/start/lookup_summary/layer5.inc`
- `src/entry/start/rodata/layer5_cli_requests.inc`
- `src/entry/start/rodata/layer5_summary_labels.inc`
- `src/entry/start/state/layer5_globals.inc`
- `src/entry/start/state/layer5_bss.inc`
- `src/infer/token0_layer5_ffn.s`
- `src/infer/token0_layer5_ffn_down.s`
- `work/oracle/token0_layer5_post_ffn_residual_oracle.py`
- `work/reviews/2026-05-12-layer5-ffn-chain-review-1.md`
- `work/reviews/2026-05-12-layer5-ffn-chain-review-2.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-5 FFN chain review gate pass 2 verification passed:

- `make clean all check`
- `python3 -m py_compile work/oracle/*.py`
- real-target runtime/oracle comparison matched 85 exact values against
  `work/oracle/token0_layer5_post_ffn_residual_oracle.py`
- packed 24-byte zero-count GGUF kept reviewed layer-5 FFN descriptor found
  flags and dependent statuses at `0` and emitted no guarded layer-5 FFN or
  post-FFN residual exact-hex labels
- `git diff --check`, static-link/no-dynamic-section/no-interpreter,
  undefined-symbol, runtime source extension, include dependency, tracked
  artifact, tracked large-file, exported/local symbol, and line-count scans
  passed

## Next Exact Step

Start layer-6 attention coverage with descriptor-only `blk.6.attn_norm.weight`
lookup/setup, keeping the step limited to retained descriptor metadata and
summary output with no tensor payload read or layer-6 attention norm status.
