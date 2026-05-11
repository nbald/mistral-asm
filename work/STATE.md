# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add a guarded status-only token-0 layer-4 FFN SwiGLU activation smoke using the
retained gate and up outputs, with no public exact-hex slice yet.

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

## Known Blockers

- No functional blocker is known.
- Keep new layer-4 FFN work in focused modules. `src/infer/token0_layer4_ffn.s`
  is 748 lines and still has room for the next focused layer-4 FFN branch work.
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
- `work/oracle/token0_layer4_post_attn_residual_oracle.py`
- `work/oracle/token0_layer4_ffn_norm_oracle.py`
- `work/oracle/token0_layer4_ffn_gate_oracle.py`
- `work/oracle/token0_layer4_ffn_up_oracle.py`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-4 FFN up output-slice verification passed:

- `make clean all check`
- `./mistral-asm --help`
- real-target output reported `layer4_ffn_up_tensor_found: 1`,
  `layer4_ffn_up_tensor_n_dimensions: 2`, dim0 `3072`, dim1 `9216`,
  ggml_type `8`, relative offset `1016205312`, and
  `token0_layer4_ffn_up_matvec: 1`
- real-target output kept layer-4 FFN RMSNorm and FFN gate matvec statuses at
  `1`, and emitted `token0_layer4_ffn_up_output*_f32_hex` as `0x3f630ab2`,
  `0x3e49f608`, `0x3ee1a851`, and `0x3dfb29a1`
- the public layer-3 post-FFN residual, layer-4 attention output, layer-4
  post-attention residual, layer-4 FFN RMSNorm, and layer-4 FFN gate output
  slices plus the new layer-4 FFN up output slice diffed cleanly against
  `work/oracle/token0_layer4_ffn_up_oracle.py`
- 24-byte zero-count GGUF reported all `layer4_ffn_norm_tensor_*`,
  `layer4_ffn_gate_tensor_*`, and `layer4_ffn_up_tensor_*` summary fields as
  `0`, kept layer-4 output/residual/FFN-norm/gate-matvec/up-matvec statuses at
  `0`, and emitted no guarded layer-4 exact-hex labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- static-link/no-dynamic-section/file check and undefined-symbol check
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- exported symbol check for the six `layer4_ffn_up_tensor_*` descriptor fields;
  exported symbol check for `token0_layer4_ffn_up_matvec_status` and
  `run_token0_layer4_ffn_up_matvec_status`
- tracked artifact and tracked large-file scans
- line-count check; `src/entry/start/lookup_summary/layer4.inc` is 795 lines,
  `src/infer/token0_layer4_ffn.s` is 748 lines,
  `src/infer/token0_layer4_attn.s` remains 945 lines, and
  `src/gguf/load_header/tensor_infos.inc` remains the known 1172-line
  tensor-directory walker

## Next Exact Step

Add a guarded status-only token-0 layer-4 FFN SwiGLU activation smoke requiring
both layer-4 FFN gate and up matvec statuses, compute `silu(gate) * up` into
private 9216-f32 storage, publish status only, and keep the 24-byte zero-count
GGUF silent.
