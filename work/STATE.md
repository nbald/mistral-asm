# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish a guarded layer-4 FFN RMSNorm exact-hex slice with a focused external
oracle for the first four token-0 activation words.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and
  linked with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups,
  and bounded tensor payload reads only inside guarded smoke paths.
- Token-0 coverage is complete through the layer-3 post-FFN residual. The first
  four retained layer-3 post-FFN residual words are `0x440c2692`,
  `0xc1ff9359`, `0xc2a96a19`, and `0xc15e5fea`.
- Layer-4 attention coverage includes retained descriptors for
  `blk.4.attn_norm.weight`, query/key/value/output projections, guarded
  RMSNorm, query/key/value matvecs, single-token grouped-query context, output
  projection, and a published post-attention residual slice. The first four
  layer-4 post-attention residual words are `0x440c288f`, `0xc1fe4c53`,
  `0xc2a99143`, and `0xc15f94a3`.
- The two-pass review gate for the layer-4 attention chain and the two-pass
  review gate for the layer-4 post-attention residual handoff both completed
  cleanly under `work/reviews/`.
- Layer-4 FFN scope has descriptor-only retained lookup and summary coverage for
  `blk.4.ffn_norm.weight`. On the real target it is f32 `[3072]`, relative
  offset `1016193024`.
- Layer-4 FFN RMSNorm status coverage now lives in focused
  `src/infer/token0_layer4_ffn.s`. It consumes the retained layer-4
  post-attention residual and `blk.4.ffn_norm.weight`, computes and retains
  `token0_layer4_ffn_norm_activation` on success, and currently prints only
  `token0_layer4_ffn_norm: 1` on the real target. No public layer-4 FFN norm
  exact-hex labels or oracle have been added yet.

## Known Blockers

- No functional blocker is known.
- Keep new layer-4 FFN work in focused modules. `src/infer/token0_layer4_attn.s`
  is 945 lines and should only receive minimal wiring.
- `src/infer/token0_layer3_ffn.s` is 942 lines,
  `src/infer/token0_layer2_ffn.s` is 943 lines, and
  `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new
  code to them before splitting or moving work into focused modules.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/constants.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer4_cli_requests.inc`
- `src/entry/start/rodata/layer4_summary_labels.inc`
- `src/entry/start/state/layer4_globals.inc`
- `src/entry/start/state/layer4_bss.inc`
- `src/entry/start/lookup_summary/layer4.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer4.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/infer/token0_layer4_attn.s`
- `src/infer/token0_layer4_post_attn_residual.s`
- `src/infer/token0_layer4_ffn.s`
- `work/oracle/token0_layer4_post_attn_residual_oracle.py`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-4 FFN RMSNorm status-only verification passed:

- `make clean all check`
- `./mistral-asm --help`
- real-target summary/status output reported `layer4_ffn_norm_tensor_found: 1`,
  `layer4_ffn_norm_tensor_n_dimensions: 1`,
  `layer4_ffn_norm_tensor_dim0: 3072`,
  `layer4_ffn_norm_tensor_ggml_type: 0`, and
  `layer4_ffn_norm_tensor_offset: 1016193024`, with
  `token0_layer4_ffn_norm: 1`
- real-target layer-4 attention output and post-attention residual statuses
  remained `1`; the public layer-3 post-FFN residual, layer-4 attention output,
  and layer-4 post-attention residual slices still diffed cleanly against
  `work/oracle/token0_layer4_post_attn_residual_oracle.py`
- real-target output emitted no `token0_layer4_ffn_norm[0-3]_f32_hex` labels
  in this status-only step
- 24-byte zero-count GGUF reported all `layer4_ffn_norm_tensor_*` summary fields
  as `0`, kept layer-4 output/residual/FFN-norm statuses at `0`, and emitted no
  guarded layer-4 exact-hex labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- static-link/no-dynamic-section/file check and undefined-symbol check
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- exported symbol check for `run_token0_layer4_ffn_norm_status`,
  `token0_layer4_ffn_norm_status`, and
  `token0_layer4_ffn_norm_activation`
- tracked artifact and tracked large-file scans
- line-count check; new `src/infer/token0_layer4_ffn.s` is 156 lines,
  `src/infer/token0_layer4_attn.s` remains 945 lines, and
  `src/infer/token0_layer4_post_attn_residual.s` remains 223 lines

## Next Exact Step

Add a focused `work/oracle/token0_layer4_ffn_norm_oracle.py` and publish the
first four guarded `token0_layer4_ffn_norm*_f32_hex` words from
`src/infer/token0_layer4_ffn.s`, keeping the existing layer-4 residual handoff
checks intact.
