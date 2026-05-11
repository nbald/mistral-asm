# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add status-only layer-3 attention RMSNorm coverage using the retained
`blk.3.attn_norm.weight` descriptor and the layer-2 post-FFN residual handoff.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads.
- Token-0 smoke coverage reaches the complete layer-2 FFN branch through the
  post-FFN residual. The layer-2 post-FFN residual words remain `0x440c1d48`,
  `0xc200a8d7`, `0xc2a8120a`, and `0xc15da38d`.
- Layer-3 attention scope has started with descriptor-only retained lookup and
  summary coverage for `blk.3.attn_norm.weight` in focused, Makefile-tracked
  entry fragments.
- On the real target, `blk.3.attn_norm.weight` reports found `1`, dimensions
  `1`, dim0 `3072`, type `0`, and relative offset `802246656`.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or
  Makefile-tracked include fragments.

## Known Blockers

- No current blocker to the layer-3 attention RMSNorm status step.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new code
  to it before splitting or moving work into a focused module.
- `src/infer/token0_layer2_ffn.s` is 943 lines. Do not add substantial new code
  there before splitting or moving work into a focused module.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/constants.inc`
- `src/entry/start/lookup_summary.inc`
- `src/entry/start/lookup_summary/layer3.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer3.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/rodata.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer3_cli_requests.inc`
- `src/entry/start/rodata/layer3_summary_labels.inc`
- `src/entry/start/state.inc`
- `src/entry/start/state/layer3_globals.inc`
- `src/entry/start/state/layer3_bss.inc`
- `src/infer/token0_layer2_ffn_down.s`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 attention RMSNorm descriptor lookup verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- real-target run printed layer-3 attention RMSNorm descriptor found `1`,
  dimensions `1`, dim0 `3072`, type `0`, and offset `802246656`
- real-target run preserved layer-2 post-FFN residual status `1` and words
  `0x440c1d48`, `0xc200a8d7`, `0xc2a8120a`, and `0xc15da38d`
- temporary 24-byte empty valid GGUF kept the new layer-3 descriptor fields at
  `0`, kept selected layer-2 FFN/post-residual statuses at `0`, and emitted no
  guarded layer-2 post-FFN residual exact-hex labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- descriptor-only scan found no layer-3 references in `src/infer`, `src/math`,
  or `src/gguf`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- local/exported symbol inspection for the new layer-3 descriptor slot and
  summary printer

## Next Exact Step

Add status-only layer-3 attention RMSNorm coverage using the retained
`blk.3.attn_norm.weight` descriptor and the layer-2 post-FFN residual handoff.
