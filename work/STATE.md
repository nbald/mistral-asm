# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish the first guarded exact-hex slice for the token-0 layer-5 attention
RMSNorm activation by adding a focused external oracle and printing the first
four activation words only when the existing layer-5 RMSNorm status is 1.

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
- Layer-4 post-FFN residual output-slice coverage is complete in the focused
  layer-4 FFN down/residual module. It requires
  `token0_layer4_post_attn_residual` and
  `token0_layer4_ffn_down_matvec` statuses, repeats the 3072-wide
  `blk.4.ffn_down.weight` output guard, writes a private 3072-f32 residual
  buffer, and publishes the first four residual words: `0x440c31ce`,
  `0xc1fe4f76`, `0xc2a982a9`, and `0xc15ff54c`.
- The two-pass review gate for the completed layer-4 FFN/down/post-FFN residual
  chain completed cleanly under
  `work/reviews/2026-05-12-layer4-ffn-chain-review-1.md` and
  `work/reviews/2026-05-12-layer4-ffn-chain-review-2.md`. No blocking runtime
  findings were recorded. Layer-5 work can resume, but must export the
  layer-4 post-FFN residual handoff deliberately when it first consumes that
  private buffer.
- Descriptor-only layer-5 attention RMSNorm setup is complete for
  `blk.5.attn_norm.weight`. The retained real-target descriptor is f32
  `[3072]` at relative offset `1049628672`. This step added only lookup and
  summary wiring in focused layer-5 include fragments; it does not read the
  layer-4 post-FFN residual buffer or any layer-5 f32 payload bytes.
- Status-only token-0 layer-5 attention RMSNorm coverage is complete in the
  focused `src/infer/token0_layer5_attn.s` module. The smoke deliberately
  exports and consumes the layer-4 post-FFN residual handoff, proves the
  retained `blk.5.attn_norm.weight` f32 `[3072]` payload span, writes a private
  3072-f32 activation buffer, and publishes only `token0_layer5_attn_norm`.
  No layer-5 activation exact-hex labels are emitted yet.

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
- `src/entry/start/rodata/layer5_cli_requests.inc`
- `src/entry/start/rodata/layer4_summary_labels.inc`
- `src/entry/start/rodata/layer5_summary_labels.inc`
- `src/entry/start/state/layer4_globals.inc`
- `src/entry/start/state/layer5_globals.inc`
- `src/entry/start/state/layer4_bss.inc`
- `src/entry/start/state/layer5_bss.inc`
- `src/entry/start/lookup_summary/layer4.inc`
- `src/entry/start/lookup_summary/layer5.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer4.inc`
- `src/entry/start/main/bootstrap/layer5.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/infer/token0_layer4_attn.s`
- `src/infer/token0_layer4_post_attn_residual.s`
- `src/infer/token0_layer4_ffn.s`
- `src/infer/token0_layer4_ffn_down.s`
- `src/infer/token0_layer5_attn.s`
- `work/oracle/token0_layer4_post_attn_residual_oracle.py`
- `work/oracle/token0_layer4_ffn_norm_oracle.py`
- `work/oracle/token0_layer4_ffn_gate_oracle.py`
- `work/oracle/token0_layer4_ffn_up_oracle.py`
- `work/oracle/token0_layer4_ffn_swiglu_oracle.py`
- `work/oracle/token0_layer4_ffn_down_oracle.py`
- `work/oracle/token0_layer4_post_ffn_residual_oracle.py`
- `work/reviews/2026-05-12-layer4-ffn-chain-review-1.md`
- `work/reviews/2026-05-12-layer4-ffn-chain-review-2.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-5 attention RMSNorm status-only verification passed:

- `make clean all check`
- after help/comment updates, `make all check`
- `./mistral-asm --help` mentions the layer-5 attention RMSNorm descriptor
  lookup/status smoke
- real-target output reported `layer5_attn_norm_tensor_found: 1`,
  `layer5_attn_norm_tensor_n_dimensions: 1`,
  `layer5_attn_norm_tensor_dim0: 3072`,
  `layer5_attn_norm_tensor_ggml_type: 0`, and
  `layer5_attn_norm_tensor_offset: 1049628672`, then
  `token0_layer5_attn_norm: 1`
- the filtered real-target runtime/oracle diff was empty for the exact-hex
  labels covered by `work/oracle/token0_layer4_post_ffn_residual_oracle.py`
- both the real target and a 24-byte zero-count GGUF emitted no
  `token0_layer5*_f32_hex` labels
- the 24-byte zero-count GGUF kept the layer-5 descriptor fields,
  `token0_layer4_post_ffn_residual`, and `token0_layer5_attn_norm` at `0`
- `git diff --check`
- static-link/no-dynamic-section/file check and undefined-symbol check
- exported-symbol inspection confirmed `token0_layer4_post_ffn_residual`,
  `token0_layer4_post_ffn_residual_status`, and
  `token0_layer5_attn_norm_status`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- tracked artifact and tracked large-file scans
- line-count check; the new layer-5 source module is small and the known
  near-limit files remain under the same constraints as the previous state

## Next Exact Step

Publish the first guarded token-0 layer-5 attention RMSNorm exact-hex slice by
adding a focused oracle for the retained activation and printing the first four
activation words only when `token0_layer5_attn_norm` is 1.
