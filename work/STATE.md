# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add descriptor-only layer-4 FFN up setup for `blk.4.ffn_up.weight`.

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
- Layer-4 FFN RMSNorm scope has retained lookup and summary coverage for
  `blk.4.ffn_norm.weight`. On the real target it is f32 `[3072]`, relative
  offset `1016193024`.
- Layer-4 FFN RMSNorm coverage lives in focused
  `src/infer/token0_layer4_ffn.s`. It consumes the retained layer-4
  post-attention residual and `blk.4.ffn_norm.weight`, computes and retains
  `token0_layer4_ffn_norm_activation` on success, and publishes the first four
  guarded exact-hex activation words. The real-target words are `0x423a3384`,
  `0xc014dd2f`, `0xc0183cf3`, and `0xbf63db6c`, matching
  `work/oracle/token0_layer4_ffn_norm_oracle.py`.
- Layer-4 FFN gate descriptor coverage has retained lookup and summary output
  for `blk.4.ffn_gate.weight`. On the real target it is Q8_0 `[3072 x 9216]`,
  relative offset `986112000`.
- Layer-4 FFN gate matvec coverage now consumes the retained layer-4 FFN
  RMSNorm activation and `blk.4.ffn_gate.weight`, proves the complete Q8_0
  payload span, writes the private 9216-f32 gate output buffer on success, and
  publishes the first four guarded exact-hex output words. The real-target
  words are `0x3ee0150a`, `0xbdd9edb2`, `0xbfbf1ff1`, and `0x3f5b31a5`,
  matching `work/oracle/token0_layer4_ffn_gate_oracle.py`.

## Known Blockers

- No functional blocker is known.
- Keep new layer-4 FFN work in focused modules. `src/infer/token0_layer4_attn.s`
  is 945 lines and should only receive minimal wiring.
- `src/infer/token0_layer4_ffn.s` is 502 lines after the gate output slice step
  and still has room for the next focused layer-4 FFN branch work.
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
- `work/oracle/token0_layer4_ffn_norm_oracle.py`
- `work/oracle/token0_layer4_ffn_gate_oracle.py`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-4 FFN gate output slice verification passed:

- `make clean all check`
- `./mistral-asm --help`
- real-target output reported the retained `layer4_ffn_gate_tensor_*`
  descriptor as Q8_0 `[3072 x 9216]` at relative offset `986112000`, kept
  layer-4 attention output, post-attention residual, and FFN RMSNorm statuses
  at `1`, and reported `token0_layer4_ffn_gate_matvec: 1`
- real-target output published
  `token0_layer4_ffn_gate_output0_f32_hex: 0x3ee0150a`,
  `token0_layer4_ffn_gate_output1_f32_hex: 0xbdd9edb2`,
  `token0_layer4_ffn_gate_output2_f32_hex: 0xbfbf1ff1`, and
  `token0_layer4_ffn_gate_output3_f32_hex: 0x3f5b31a5`
- the public layer-3 post-FFN residual, layer-4 attention output, layer-4
  post-attention residual, and layer-4 FFN RMSNorm slices diffed cleanly
  alongside the new layer-4 FFN gate output slice against
  `work/oracle/token0_layer4_ffn_gate_oracle.py`
- 24-byte zero-count GGUF reported all `layer4_ffn_gate_tensor_*` summary
  fields as `0`, kept layer-4 output/residual/FFN-norm/gate-matvec statuses at
  `0`, and emitted no guarded layer-4 exact-hex labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- static-link/no-dynamic-section/file check and undefined-symbol check
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- exported symbol check for `run_token0_layer4_ffn_gate_matvec_status` and
  `token0_layer4_ffn_gate_matvec_status`
- tracked artifact and tracked large-file scans
- line-count check; `src/infer/token0_layer4_ffn.s` is 502 lines,
  `src/infer/token0_layer4_attn.s` remains 945 lines, and
  `src/gguf/load_header/tensor_infos.inc` remains the known 1172-line
  tensor-directory walker

## Next Exact Step

Add descriptor-only layer-4 FFN up setup for `blk.4.ffn_up.weight`.
