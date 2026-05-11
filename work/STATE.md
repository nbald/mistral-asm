# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add a guarded token-0 layer-4 post-FFN residual status smoke using the retained
layer-4 post-attention residual and the retained layer-4 FFN down output.

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
- Layer-4 FFN RMSNorm descriptor, status, and output-slice coverage is complete
  for `blk.4.ffn_norm.weight`. The real-target descriptor is f32 `[3072]` at
  relative offset `1016193024`; the first four activation words are
  `0x423a3384`, `0xc014dd2f`, `0xc0183cf3`, and `0xbf63db6c`.
- Layer-4 FFN gate descriptor, status, and output-slice coverage is complete for
  `blk.4.ffn_gate.weight`. The real-target descriptor is Q8_0
  `[3072 x 9216]` at relative offset `986112000`; the first four output words
  are `0x3ee0150a`, `0xbdd9edb2`, `0xbfbf1ff1`, and `0x3f5b31a5`.
- Layer-4 FFN up descriptor, status, and output-slice coverage is complete for
  `blk.4.ffn_up.weight`. The retained real-target descriptor is Q8_0
  `[3072 x 9216]` at relative offset `1016205312`; the first four output words
  are `0x3f630ab2`, `0x3e49f608`, `0x3ee1a851`, and `0x3dfb29a1`.
- Layer-4 FFN SwiGLU status and output-slice coverage is complete. It requires
  both layer-4 FFN gate and up matvec statuses, computes `silu(gate) * up` into
  the retained 9216-f32 `token0_layer4_ffn_swiglu_output` buffer, and publishes
  the first four activation words: `0x3e718adc`, `0xbc22c98e`,
  `0xbdf73ee4`, and `0x3d96f05d`.
- Descriptor-only layer-4 FFN down setup is complete for
  `blk.4.ffn_down.weight`. The retained real-target descriptor is Q8_0
  `[9216 x 3072]` at relative offset `956030976`.
- Layer-4 FFN down matvec status and output-slice coverage is complete in the
  focused `src/infer/token0_layer4_ffn_down.s` module. It requires the retained
  layer-4 FFN SwiGLU status and the Q8_0 `[9216 x 3072]` down descriptor,
  proves the mapped payload span, writes a private 3072-f32 down output buffer,
  and publishes the first four output words: `0x3e13ea6f`, `0xbac8ccef`,
  `0x3ce99bed`, and `0xbcc152bc`.

## Known Blockers

- No functional blocker is known.
- Keep new layer-4 FFN work in focused modules. `src/infer/token0_layer4_ffn.s`
  is 945 lines and should not receive substantial layer-4 FFN down code; use a
  focused module for down-matvec or residual work.
- `src/infer/token0_layer4_attn.s` is 945 lines and should only receive minimal
  wiring.
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
- `src/infer/token0_layer4_ffn_down.s`
- `work/oracle/token0_layer4_post_attn_residual_oracle.py`
- `work/oracle/token0_layer4_ffn_norm_oracle.py`
- `work/oracle/token0_layer4_ffn_gate_oracle.py`
- `work/oracle/token0_layer4_ffn_up_oracle.py`
- `work/oracle/token0_layer4_ffn_swiglu_oracle.py`
- `work/oracle/token0_layer4_ffn_down_oracle.py`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-4 FFN down output-slice verification passed:

- `make clean all check`; after the help text update, `make all check`
- `./mistral-asm --help`
- real-target output reported `token0_layer4_ffn_down_matvec: 1` and emitted
  `token0_layer4_ffn_down_output{0..3}_f32_hex` as `0x3e13ea6f`,
  `0xbac8ccef`, `0x3ce99bed`, and `0xbcc152bc`
- the real-target runtime/oracle diff was empty for 32 public exact-hex labels
  through layer-4 FFN down against
  `work/oracle/token0_layer4_ffn_down_oracle.py`
- 24-byte zero-count GGUF kept layer-4 FFN norm/gate/up/SwiGLU/down statuses at
  `0` and emitted no guarded layer-4 down exact-hex labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- static-link/no-dynamic-section/file check and undefined-symbol check
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- symbol check for `run_token0_layer4_ffn_down_matvec_status`,
  `token0_layer4_ffn_down_matvec_status`,
  `print_token0_layer4_ffn_down_output_slice`, and private
  `token0_layer4_ffn_down_output`
- tracked artifact and tracked large-file scans
- line-count check; `src/infer/token0_layer4_ffn_down.s` is 263 lines,
  `src/entry/start/lookup_summary/layer4.inc` is 898 lines,
  `src/infer/token0_layer4_ffn.s` is 945 lines,
  `src/infer/token0_layer4_attn.s` is 945 lines,
  `src/infer/token0_layer3_ffn.s` is 942 lines,
  `src/infer/token0_layer2_ffn.s` is 943 lines,
  `src/infer/token0_layer2_attn.s` is 997 lines, and
  `src/gguf/load_header/tensor_infos.inc` remains the known 1172-line
  tensor-directory walker

## Next Exact Step

Add a status-only `token0_layer4_post_ffn_residual` smoke in the focused
layer-4 FFN down/residual module: require `token0_layer4_post_attn_residual`
and `token0_layer4_ffn_down_matvec` statuses, guard the retained down output
width at 3072, write a private 3072-f32 residual buffer, print only the status,
and verify real-target status `1` plus zero-count GGUF status `0` with no new
residual exact-hex labels yet.
