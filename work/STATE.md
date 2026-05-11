# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add a focused token-0 layer-3 FFN gate descriptor lookup and status-only gate
matvec smoke that requires `token0_layer3_ffn_norm: 1`, retains
`blk.3.ffn_gate.weight`, proves the complete Q8_0 `[3072 x 9216]` payload span
against the live mapping, fills private 9216-f32 output storage, and publishes
a status without exact-hex output words.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads only inside guarded smoke paths.
- Token-0 smoke coverage reaches the layer-3 FFN RMSNorm activation. The public
  layer-3 slices now include:
  - attention output: `0x3ce80ee7`, `0x3da84154`, `0xbd1e4c02`,
    `0xbd11752d`
  - post-attention residual: `0x440c1f18`, `0xc20054b6`, `0xc2a825d4`,
    `0xc15e3502`
  - FFN RMSNorm: `0x422e5251`, `0xc01a339f`, `0xbffb06aa`, `0xbf19ba93`
- Layer-3 retained descriptors now cover attention norm/query/key/value/output
  and FFN norm. On the real target, `blk.3.ffn_norm.weight` is found with
  dimensions `3072`, type `0`, and relative offset `892502016`.
- Added `src/infer/token0_layer3_ffn.s`. Its first smoke requires
  `token0_layer3_post_attn_residual: 1`, rechecks
  `blk.3.ffn_norm.weight`, bounds the full f32 payload, fills private
  3072-f32 activation storage, publishes `token0_layer3_ffn_norm`, and emits
  the first four guarded exact-hex words.
- Added the focused external oracle script and note for layer-3 FFN RMSNorm.
  The runtime/oracle diff is empty for the layer-3 attention output,
  post-attention residual, and new FFN RMSNorm public labels.
- The two-pass review gate for the completed layer-3 attention chain is already
  complete. Feature work has resumed into the layer-3 FFN branch.

## Known Blockers

- No functional blocker to the layer-3 FFN gate step.
- Layer-3 FFN gate/up/down descriptors are not retained yet; add them in
  focused layer-3 state/bootstrap/summary work as each smoke needs them.
- Keep layer-3 FFN work in focused layer-3 files. Do not grow the near-limit
  layer-2 modules for layer-3 work.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new
  code to it before splitting or moving work into a focused module.
- `src/infer/token0_layer2_ffn.s` is 943 lines. Do not add substantial new code
  there before splitting or moving work into a focused module.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/constants.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer3_cli_requests.inc`
- `src/entry/start/rodata/layer3_summary_labels.inc`
- `src/entry/start/state/layer3_globals.inc`
- `src/entry/start/state/layer3_bss.inc`
- `src/entry/start/main/bootstrap/layer3.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/entry/start/lookup_summary/layer3.inc`
- `src/infer/token0_layer3_ffn.s`
- `work/oracle/token0_layer3_ffn_norm_oracle.py`
- `work/oracle/token0-layer3-ffn-norm.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 FFN RMSNorm verification passed:

- `make clean all check`
- `./mistral-asm --help`
- real-target run reported `layer3_ffn_norm_tensor_found: 1`,
  `token0_layer3_post_attn_residual: 1`, and `token0_layer3_ffn_norm: 1`
- focused runtime/oracle diff was empty for the layer-3 attention output,
  layer-3 post-attention residual, and new layer-3 FFN RMSNorm public labels
- 24-byte header-only GGUF kept the layer-3 FFN norm descriptor fields,
  `token0_layer3_attn_output_matvec`, `token0_layer3_post_attn_residual`, and
  `token0_layer3_ffn_norm` at `0`, and emitted no guarded layer-3 attention
  output, post-attention residual, or FFN RMSNorm exact-hex labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- layer-3 FFN norm symbol inspection
- inference source line-count check
- tracked artifact and tracked large-file scans

## Next Exact Step

Add a focused token-0 layer-3 FFN gate descriptor lookup and status-only gate
matvec smoke that requires `token0_layer3_ffn_norm: 1`, retains
`blk.3.ffn_gate.weight`, proves the complete Q8_0 `[3072 x 9216]` payload span
against the live mapping, fills private 9216-f32 output storage, and publishes
a status without exact-hex output words.
