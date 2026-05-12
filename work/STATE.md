# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish the first guarded token-0 layer-5 FFN RMSNorm exact-hex slice with a
focused external oracle. It should print only when `token0_layer5_ffn_norm` is
1 and the first four activation words match the oracle.

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
- Token-0 layer-5 attention RMSNorm compute coverage is complete in the
  focused `src/infer/token0_layer5_attn.s` module. The smoke deliberately
  exports and consumes the layer-4 post-FFN residual handoff, proves the
  retained `blk.5.attn_norm.weight` f32 `[3072]` payload span, writes a private
  3072-f32 activation buffer, and publishes `token0_layer5_attn_norm`.
- The first guarded token-0 layer-5 attention RMSNorm exact-hex slice is
  published. It prints only when `token0_layer5_attn_norm` is 1 and the first
  four activation words match the focused external oracle:
  `0x42218b53`, `0xc076c4e6`, `0xc1466897`, and `0xc0005a54`.
- Descriptor-only layer-5 attention query setup is complete for
  `blk.5.attn_q.weight`. The retained real-target descriptor is Q8_0
  `[3072 x 4096]` at relative offset `1063010304`. This step added only
  lookup and summary wiring in existing focused layer-5 include fragments; it
  does not read query Q8_0 payload bytes or add a query matvec status.
- Status-only token-0 layer-5 attention query matvec coverage is complete in
  `src/infer/token0_layer5_attn.s`. The smoke requires
  `token0_layer5_attn_norm` status, the retained `blk.5.attn_q.weight`
  descriptor as Q8_0 `[3072 x 4096]`, and a proven full matrix payload span
  inside the live mapping before reading query bytes. It writes a private
  4096-f32 output buffer and publishes `token0_layer5_attn_q_matvec`.
- The first guarded token-0 layer-5 attention query exact-hex slice is
  published. It prints only when `token0_layer5_attn_q_matvec` is 1 and the
  first four query output words match the focused external oracle:
  `0xbe8aee1e`, `0x3e5db4f8`, `0xbee5a1db`, and `0x3be44a75`.
- Descriptor-only layer-5 attention key setup is complete for
  `blk.5.attn_k.weight`. The retained real-target descriptor is Q8_0
  `[3072 x 1024]` at relative offset `1046286336`. This step added only
  lookup, retained summary fields, summary printing, and help/contract text; it
  does not read key Q8_0 payload bytes or add a key matvec status.
- Status-only token-0 layer-5 attention key matvec coverage is complete in
  `src/infer/token0_layer5_attn.s`. The smoke requires
  `token0_layer5_attn_norm` status, the retained `blk.5.attn_k.weight`
  descriptor as Q8_0 `[3072 x 1024]`, and a proven full matrix payload span
  inside the live mapping before reading key bytes. It writes a private
  1024-f32 output buffer and publishes `token0_layer5_attn_k_matvec`.
- The first guarded token-0 layer-5 attention key exact-hex slice is
  published. It prints only when `token0_layer5_attn_k_matvec` is 1 and the
  first four key output words match the focused external oracle:
  `0xbce30a54`, `0x3b2c5263`, `0x3ceab318`, and `0x3c848c77`.
- Descriptor-only layer-5 attention value setup is complete for
  `blk.5.attn_v.weight`. The retained real-target descriptor is Q8_0
  `[3072 x 1024]` at relative offset `1076379648`. This step added only
  lookup, retained summary fields, summary printing, and help/contract text; it
  does not read value Q8_0 payload bytes or publish a value matvec status.
- Status-only token-0 layer-5 attention value matvec coverage is complete in
  `src/infer/token0_layer5_attn.s`. The smoke requires
  `token0_layer5_attn_norm` status, the retained `blk.5.attn_v.weight`
  descriptor as Q8_0 `[3072 x 1024]`, and a proven full matrix payload span
  inside the live mapping before reading value bytes. It writes a private
  1024-f32 value output buffer and publishes `token0_layer5_attn_v_matvec`,
  without adding value exact-hex output labels.
- The first guarded token-0 layer-5 attention value exact-hex slice is
  published. It prints only when `token0_layer5_attn_v_matvec` is 1 and the
  first four value output words match the focused external oracle:
  `0x3c308045`, `0x3af0e7ba`, `0xbc4405eb`, and `0xbb67db55`.
- Review gate pass 1 for the completed layer-5 attention norm/query/key/value
  chain completed cleanly under
  `work/reviews/2026-05-12-layer5-attn-qkv-review-1.md`. No blocking runtime
  findings were recorded.
- Review gate pass 2 for the completed layer-5 attention norm/query/key/value
  chain completed cleanly under
  `work/reviews/2026-05-12-layer5-attn-qkv-review-2.md`. No blocking runtime
  findings were recorded. The next feature step can resume, but should start
  with descriptor-only layer-5 attention output setup and keep context work out
  of `src/infer/token0_layer5_attn.s`.
- Descriptor-only layer-5 attention output-projection setup is complete for
  `blk.5.attn_output.weight`. The retained real-target descriptor is Q8_0
  `[4096 x 3072]` at relative offset `1049640960`. This step added only lookup,
  retained summary fields, summary printing, and help text; it does not read
  output-projection Q8_0 payload bytes or publish context/output-projection
  status labels.
- Explicit layer-5 Q/K/V projection handoff coverage is complete in the focused
  `src/infer/token0_layer5_attn_qkv_handoff.s` module. The layer-5 query, key,
  and value projection buffers are now exported from
  `src/infer/token0_layer5_attn.s`, but consumers must gate reads through
  `token0_layer5_attn_qkv_handoff_status`. The handoff status validates the
  three projection statuses and retained Q/K/V descriptor shapes, prints
  `token0_layer5_attn_qkv_handoff`, and deliberately does not read projection
  buffer bytes, derive context values, or read `blk.5.attn_output.weight`
  payload bytes.
- Status-only token-0 layer-5 single-token attention context coverage is
  complete in the focused `src/infer/token0_layer5_attn_context.s` module. It
  consumes the explicit Q/K/V projection handoff, borrows the exported layer-5
  value projection buffer, uses retained Q/K/V and output-projection
  descriptors only as shape guards, writes an exported 4096-f32
  `token0_layer5_attn_context` buffer, prints `token0_layer5_attn_context`,
  and deliberately does not read `blk.5.attn_output.weight` payload bytes or
  emit context exact-hex labels.
- Status-only token-0 layer-5 attention output-projection matvec coverage is
  complete in the focused `src/infer/token0_layer5_attn_output.s` module. It
  consumes `token0_layer5_attn_context_status` and the exported 4096-f32 context
  buffer, requires the retained `blk.5.attn_output.weight` descriptor as Q8_0
  `[4096 x 3072]`, proves the full mapped payload span before reading matrix
  bytes, writes a private 3072-f32 output buffer, and prints only
  `token0_layer5_attn_output_matvec`.
- The first guarded token-0 layer-5 attention output-projection exact-hex slice
  is published in `src/infer/token0_layer5_attn_output.s`. It prints only when
  `token0_layer5_attn_output_matvec` is 1 and the first four output words match
  the focused external oracle: `0x3d443070`, `0x3e31a0d5`, `0xbddb87ff`, and
  `0xbdc80eb7`.
- Review gate pass 1 for the completed layer-5 attention Q/K/V handoff,
  single-token context, and output-projection matvec/slice chain completed
  cleanly under
  `work/reviews/2026-05-12-layer5-attn-output-chain-review-1.md`. No blocking
  runtime findings were recorded. The next residual implementation must either
  keep the residual add in `src/infer/token0_layer5_attn_output.s` or introduce
  an explicit output-buffer export/handoff before another module consumes the
  private output-projection buffer.
- Review gate pass 2 for the completed layer-5 attention Q/K/V handoff,
  single-token context, and output-projection matvec/slice chain completed
  cleanly under
  `work/reviews/2026-05-12-layer5-attn-output-chain-review-2.md`. No blocking
  runtime findings were recorded. The selected next handoff choice is to keep
  the post-attention residual add in `src/infer/token0_layer5_attn_output.s`,
  publish a new layer-5 post-attention residual status/buffer from that module,
  and keep the raw output-projection buffer private.
- Layer-5 post-attention residual output-slice coverage is complete in the
  focused `src/infer/token0_layer5_attn_output.s` module. It requires
  `token0_layer4_post_ffn_residual_status` and
  `token0_layer5_attn_output_matvec_status`, repeats the 3072-wide
  `blk.5.attn_output.weight` output guard, writes an exported 3072-f32
  `token0_layer5_post_attn_residual` buffer for later FFN work, and keeps the
  raw layer-5 output-projection buffer private. The first four residual words
  are `0x440c34df`, `0xc1fcec34`, `0xc2a9b98b`, and `0xc1618569`.
- Review gate pass 1 for the completed layer-5 attention Q/K/V handoff,
  single-token context, output-projection matvec/slice, and post-attention
  residual handoff chain completed cleanly under
  `work/reviews/2026-05-12-layer5-attn-residual-chain-review-1.md`. No blocking
  runtime findings were recorded. A second review-gate pass is still required
  before layer-5 FFN feature work resumes.
- Review gate pass 2 for the completed layer-5 attention Q/K/V handoff,
  single-token context, output-projection matvec/slice, and post-attention
  residual handoff chain completed cleanly under
  `work/reviews/2026-05-12-layer5-attn-residual-chain-review-2.md`. No blocking
  runtime findings were recorded. Layer-5 FFN work can resume with
  descriptor-only `blk.5.ffn_norm.weight` setup.
- Descriptor-only layer-5 FFN RMSNorm setup is complete for
  `blk.5.ffn_norm.weight`. The retained real-target descriptor is f32
  `[3072]` at relative offset `1139884032`. This step added only lookup,
  retained summary fields, summary printing, and help/contract text; it does
  not read `token0_layer5_post_attn_residual`, read f32 payload bytes, or
  publish a layer-5 FFN RMSNorm runtime status.
- Token-0 layer-5 FFN RMSNorm compute/status coverage is complete in the
  focused `src/infer/token0_layer5_ffn.s` module. It requires
  `token0_layer5_post_attn_residual_status`, proves the retained
  `blk.5.ffn_norm.weight` f32 `[3072]` payload span, writes exported
  `token0_layer5_ffn_norm_status` and a 3072-f32
  `token0_layer5_ffn_norm_activation` handoff for later FFN work, prints only
  `token0_layer5_ffn_norm`, and deliberately emits no layer-5 FFN norm
  exact-hex labels yet.

## Verification Status

- Latest verification for token-0 layer-5 FFN RMSNorm compute/status:
  `make clean all check` passed before the help edit and `make all check`
  passed after it; `python3 -m py_compile work/oracle/*.py` passed; `--help`
  mentions the layer-5 FFN RMSNorm descriptor/status smoke; the real target
  reported `token0_layer5_ffn_norm: 1` while existing layer-5
  handoff/context/output/residual statuses stayed at `1`; comparison against
  `work/oracle/token0_layer5_attn_output_oracle.py` matched all 61 existing
  oracle-covered `_f32_hex` labels; no `token0_layer5_ffn_norm*_f32_hex`
  labels were emitted; a 24-byte zero-count GGUF kept
  `layer5_ffn_norm_tensor_found`, handoff, context, output-matvec,
  post-attention residual, and FFN norm statuses at `0`; `git diff --check`,
  runtime source/fragment extension, static-link/no-dynamic-section/
  no-interpreter/file, undefined-symbol, exported/local symbol,
  no-output-slice, tracked artifact, tracked large-file, and line-count scans
  passed.

## Known Blockers

- No functional blocker is known.
- Keep new layer-4 FFN work in focused modules. `src/infer/token0_layer4_ffn.s`
  is 945 lines and should not receive substantial layer-4 FFN down code; use a
  focused module for down-matvec or residual work.
- `src/infer/token0_layer4_attn.s` is 945 lines and should only receive minimal
  wiring.
- `src/infer/token0_layer5_attn.s` is 996 lines after the minimal Q/K/V buffer
  export and handoff-comment updates. Do not add further layer-5 attention
  feature code there before splitting or moving work into focused
  Makefile-tracked modules/fragments. The explicit Q/K/V handoff and context
  status now exist, and the output-projection matvec/slice plus
  post-attention residual handoff live in a focused module.
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
- `src/infer/token0_layer5_attn_qkv_handoff.s`
- `src/infer/token0_layer5_attn_context.s`
- `src/infer/token0_layer5_attn_output.s`
- `src/infer/token0_layer5_ffn.s`
- `work/oracle/token0_layer4_post_attn_residual_oracle.py`
- `work/oracle/token0_layer4_ffn_norm_oracle.py`
- `work/oracle/token0_layer4_ffn_gate_oracle.py`
- `work/oracle/token0_layer4_ffn_up_oracle.py`
- `work/oracle/token0_layer4_ffn_swiglu_oracle.py`
- `work/oracle/token0_layer4_ffn_down_oracle.py`
- `work/oracle/token0_layer4_post_ffn_residual_oracle.py`
- `work/oracle/token0_layer5_attn_norm_oracle.py`
- `work/oracle/token0_layer5_attn_q_oracle.py`
- `work/oracle/token0_layer5_attn_k_oracle.py`
- `work/oracle/token0_layer5_attn_v_oracle.py`
- `work/oracle/token0_layer5_attn_output_oracle.py`
- `work/reviews/2026-05-12-layer5-attn-qkv-review-1.md`
- `work/reviews/2026-05-12-layer5-attn-qkv-review-2.md`
- `work/reviews/2026-05-12-layer5-attn-output-chain-review-1.md`
- `work/reviews/2026-05-12-layer5-attn-output-chain-review-2.md`
- `work/reviews/2026-05-12-layer5-attn-residual-chain-review-1.md`
- `work/reviews/2026-05-12-layer5-attn-residual-chain-review-2.md`
- `work/reviews/2026-05-12-layer4-ffn-chain-review-1.md`
- `work/reviews/2026-05-12-layer4-ffn-chain-review-2.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Token-0 layer-5 FFN RMSNorm compute/status verification passed:

- `make clean all check` before the help edit; `make all check` after it
- `python3 -m py_compile work/oracle/*.py`
- `./mistral-asm --help` mentions the layer-5 FFN RMSNorm descriptor/status
  smoke
- real-target runtime reported `token0_layer5_ffn_norm: 1`
- real-target runtime/oracle comparison matched all 61 existing exact-hex
  labels covered by `work/oracle/token0_layer5_attn_output_oracle.py`
- no `token0_layer5_ffn_norm*_f32_hex` labels were emitted
- a 24-byte zero-count GGUF kept `layer5_ffn_norm_tensor_found`,
  `token0_layer5_attn_qkv_handoff`, `token0_layer5_attn_context`,
  `token0_layer5_attn_output_matvec`, `token0_layer5_post_attn_residual`, and
  `token0_layer5_ffn_norm` at `0`
- `git diff --check`, static-link/no-dynamic-section/no-interpreter/file check,
  undefined-symbol check, runtime source/fragment extension scan, include
  dependency scan, exported/local symbol check, no-output-slice scan, tracked
  artifact scan, tracked large-file scan, and line-count review passed

## Next Exact Step

Publish the first guarded token-0 layer-5 FFN RMSNorm exact-hex slice with a
focused external oracle. It should print only when `token0_layer5_ffn_norm` is
1 and the first four activation words match the oracle.
