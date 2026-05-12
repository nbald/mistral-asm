# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish the guarded token-0 layer-6 attention query projection exact-hex slice
and add a focused oracle for `blk.6.attn_q.weight`.

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
- Layer-6 attention coverage has descriptor setup and a guarded RMSNorm
  smoke/output slice for `blk.6.attn_norm.weight`. The smoke consumes the
  exported layer-5 post-FFN residual handoff, proves the retained f32 `[3072]`
  payload span, keeps the activation buffer private, and publishes
  `token0_layer6_attn_norm` plus the first four exact-hex words. Those words are
  `0x422d70ce`, `0xc0840f20`, `0xc140459b`, and `0xc00a013e`. The layer-6 query
  projection descriptor for `blk.6.attn_q.weight` is retained, printed as
  descriptor metadata, and consumed by a guarded status-only matvec smoke after
  the layer-6 RMSNorm activation exists. The query output buffer remains private
  and no layer-6 query exact-hex labels are emitted yet.
- The two-pass review gates for the completed layer-4 FFN chain, layer-5
  attention residual handoff chain, and layer-5 FFN chain completed cleanly under
  `work/reviews/`.

## Verification Status

- Latest verification for layer-6 attention query status smoke:
  `make clean all check` passed; `python3 -m py_compile work/oracle/*.py`
  passed; help text mentions the layer-6 query status matvec smoke; the
  real target reports `layer6_attn_norm_tensor_found: 1`, dimensions `3072`,
  ggml type `0`, offset `1173319680`, and `layer6_attn_q_tensor_found: 1`,
  dimensions `3072 x 4096`, ggml type `8`, offset `1186701312`; the real target
  reports `token0_layer6_attn_norm: 1` and `token0_layer6_attn_q_matvec: 1`;
  no `token0_layer6_attn_q_output` labels are emitted; the focused layer-6
  attention RMSNorm oracle still matched 89 exact values including epsilon and
  the layer-6 RMSNorm slice; a packed 24-byte zero-count GGUF kept the layer-6
  descriptor fields, `token0_layer5_post_ffn_residual`,
  `token0_layer6_attn_norm`, and `token0_layer6_attn_q_matvec` at `0` and
  emitted no guarded layer-6 labels; static-link,
  no-dynamic-section/no-interpreter, undefined-symbol, runtime source
  extension, include-dependency, tracked artifact, tracked large-file,
  exported/local symbol, line-count, and whitespace scans passed.

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
  `src/entry/start/lookup_summary.inc` at 904 lines, and
  `src/entry/start/lookup_summary/layer5.inc` at 898 lines.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/_start.s`
- `src/entry/start/constants.inc`
- `src/entry/start/rodata.inc`
- `src/entry/start/state.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer5.inc`
- `src/entry/start/main/bootstrap/layer6.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/entry/start/lookup_summary.inc`
- `src/entry/start/lookup_summary/layer5.inc`
- `src/entry/start/lookup_summary/layer6.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer5_cli_requests.inc`
- `src/entry/start/rodata/layer5_summary_labels.inc`
- `src/entry/start/rodata/layer6_cli_requests.inc`
- `src/entry/start/rodata/layer6_summary_labels.inc`
- `src/entry/start/state/layer5_globals.inc`
- `src/entry/start/state/layer5_bss.inc`
- `src/entry/start/state/layer6_globals.inc`
- `src/entry/start/state/layer6_bss.inc`
- `src/infer/token0_layer5_ffn.s`
- `src/infer/token0_layer5_ffn_down.s`
- `src/infer/token0_layer6_attn.s`
- `work/oracle/token0_layer5_post_ffn_residual_oracle.py`
- `work/oracle/token0_layer6_attn_norm_oracle.py`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-6 attention query status smoke verification passed:

- `make clean all check`
- `python3 -m py_compile work/oracle/*.py`
- `./mistral-asm --help`
- real target reported `blk.6.attn_norm.weight` as f32 `[3072]` at relative
  offset `1173319680`, plus `blk.6.attn_q.weight` as Q8_0 `[3072 x 4096]` at
  relative offset `1186701312`; `token0_layer6_attn_norm: 1` and
  `token0_layer6_attn_q_matvec: 1`
- real-target runtime/oracle comparison still matched 89 exact values against
  `work/oracle/token0_layer6_attn_norm_oracle.py`, including
  `token0_layer6_attn_norm0..3_f32_hex`
- real-target output emitted no `token0_layer6_attn_q_output` labels
- packed 24-byte zero-count GGUF kept layer-6 norm/query descriptor fields,
  `token0_layer5_post_ffn_residual`, `token0_layer6_attn_norm`, and
  `token0_layer6_attn_q_matvec` at `0` and emitted no guarded layer-6 labels
- static scan kept private layer-6 q slot/name/dim2/dim3 symbols and
  `token0_layer6_attn_norm_activation` plus `token0_layer6_attn_q_output`
  unexported
- `git diff --check`, static-link/no-dynamic-section/no-interpreter,
  undefined-symbol, runtime source extension, include dependency, tracked
  artifact, tracked large-file, exported/local symbol, and line-count scans
  passed

## Next Exact Step

Publish the guarded token-0 layer-6 attention query projection exact-hex slice
and add a focused oracle for `blk.6.attn_q.weight`.
