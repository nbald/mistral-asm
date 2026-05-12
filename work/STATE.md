# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Create focused layer-5 FFN down-projection module wiring for a status-only
`token0_layer5_ffn_down_matvec` smoke. Keep the existing layer-5 FFN source
from becoming a catch-all module by moving/exporting only the handoff data
needed for the new module, prove the retained `blk.5.ffn_down.weight` Q8_0
payload span, and do not publish layer-5 down exact-hex output labels yet.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads only inside guarded smoke paths.
- Token-0 coverage is complete through the layer-4 post-FFN residual. The first
  four retained layer-4 post-FFN residual words are `0x440c31ce`,
  `0xc1fe4f76`, `0xc2a982a9`, and `0xc15ff54c`.
- Layer-5 attention coverage is complete through Q/K/V projection handoff,
  single-token context, output projection, and post-attention residual. The
  first four layer-5 post-attention residual words are `0x440c34df`,
  `0xc1fcec34`, `0xc2a9b98b`, and `0xc1618569`.
- Layer-5 FFN RMSNorm compute/status and exact-hex slice coverage is complete in
  `src/infer/token0_layer5_ffn.s`. It consumes the exported layer-5
  post-attention residual, proves the retained `blk.5.ffn_norm.weight` f32
  `[3072]` payload span, writes exported `token0_layer5_ffn_norm_status` and
  `token0_layer5_ffn_norm_activation`, and publishes the first four activation
  words: `0x42131508`, `0xc00d191f`, `0xc029d085`, and `0xbf74c920`.
- Descriptor-only layer-5 FFN gate setup is complete for
  `blk.5.ffn_gate.weight`. The retained real-target descriptor is Q8_0
  `[3072 x 9216]` at relative offset `1109803008`. This step added only lookup,
  retained summary fields, summary printing, and help text; it does not read
  gate Q8_0 payload bytes or publish a gate matvec status.
- Token-0 layer-5 FFN gate matvec and exact-hex slice coverage is complete in
  `src/infer/token0_layer5_ffn.s`. It consumes
  `token0_layer5_ffn_norm_status` and the exported 3072-f32 FFN norm
  activation, requires retained `blk.5.ffn_gate.weight` as Q8_0
  `[3072 x 9216]`, proves the full mapped matrix span, writes a private
  9216-f32 gate output buffer, and publishes the first four output words only
  when `token0_layer5_ffn_gate_matvec_status` is 1: `0x3e9c4027`,
  `0xbc08dfb9`, `0x3f25e360`, and `0x3ef1f366`.
- Descriptor-only layer-5 FFN up setup is complete for `blk.5.ffn_up.weight`.
  The retained real-target descriptor is Q8_0 `[3072 x 9216]` at relative
  offset `1139896320`. This step added only lookup, retained summary fields,
  summary printing, and help/contract text; it does not read up Q8_0 payload
  bytes or publish a layer-5 up matvec status.
- Status-only token-0 layer-5 FFN up matvec coverage is complete in
  `src/infer/token0_layer5_ffn.s`. It consumes
  `token0_layer5_ffn_norm_status` and the exported 3072-f32 FFN norm
  activation, requires retained `blk.5.ffn_up.weight` as Q8_0
  `[3072 x 9216]`, proves the full mapped matrix span, fills a private
  9216-f32 up output buffer, and publishes
  `token0_layer5_ffn_up_matvec`.
- Token-0 layer-5 FFN up matvec exact-hex slice coverage is complete in
  `src/infer/token0_layer5_ffn.s`. It keeps the 9216-f32 up output buffer
  private and publishes the first four output words only when
  `token0_layer5_ffn_up_matvec_status` is 1: `0x3d47d833`, `0x3dc191f5`,
  `0x3da1c6a8`, and `0xbccb2d50`.
- Status-only token-0 layer-5 FFN SwiGLU coverage is complete in
  `src/infer/token0_layer5_ffn.s`. It consumes the private layer-5 FFN gate/up
  output buffers only when `token0_layer5_ffn_gate_matvec_status` and
  `token0_layer5_ffn_up_matvec_status` are both 1, fills a private 9216-f32
  SwiGLU buffer, and publishes only `token0_layer5_ffn_swiglu` with no SwiGLU
  exact-hex labels yet.
- Token-0 layer-5 FFN SwiGLU exact-hex slice coverage is complete in
  `src/infer/token0_layer5_ffn.s`. It keeps the 9216-f32 SwiGLU buffer private
  and publishes the first four output words only when
  `token0_layer5_ffn_swiglu_status` is 1: `0x3c0c71e4`, `0xb9ce2012`,
  `0x3d09a7d5`, and `0xbbec92a7`.
- Descriptor-only layer-5 FFN down setup is complete for
  `blk.5.ffn_down.weight`. The retained real-target descriptor is Q8_0
  `[9216 x 3072]` at relative offset `1079721984`. This step added only
  lookup, retained summary fields, summary printing, and help/contract text; it
  does not read down Q8_0 payload bytes or publish a layer-5 down matvec status.
- The two-pass review gates for the completed layer-4 FFN chain and the layer-5
  attention residual handoff chain completed cleanly under `work/reviews/`.

## Verification Status

- Latest verification for descriptor-only layer-5 FFN down setup:
  `make clean all check` passed; `python3 -m py_compile work/oracle/*.py`
  passed; help text mentions the layer-5 FFN down descriptor lookup; the real
  target reports `layer5_ffn_down_tensor_found: 1`, dimensions `9216 x 3072`,
  type `8`, and relative offset `1079721984`; the existing layer-5 FFN SwiGLU
  oracle comparison matched all 77 oracle-covered exact-hex labels; a 24-byte
  zero-count GGUF kept `layer5_ffn_down_tensor_found`,
  `layer5_ffn_gate_tensor_found`, `layer5_ffn_up_tensor_found`,
  `token0_layer5_ffn_gate_matvec`, `token0_layer5_ffn_up_matvec`, and
  `token0_layer5_ffn_swiglu` at `0`; real-target and zero-count outputs emitted
  no `token0_layer5_ffn_down*` or `layer5_ffn_down_output*` labels;
  `git diff --check`, static-link/no-dynamic-section/no-interpreter/file,
  undefined-symbol, exported/local symbol, runtime source/fragment extension,
  include dependency, tracked artifact, tracked large-file, and line-count scans
  passed.

## Known Blockers

- No functional blocker is known.
- Keep new work in focused modules. Do not add substantial code to files near or
  above 1000 lines before splitting or moving work into a focused module. Current
  watch list: `src/infer/token0_layer2_attn.s` is 997 lines,
  `src/infer/token0_layer5_attn.s` is 996 lines,
  `src/infer/token0_layer5_ffn.s` is 949 lines,
  `src/infer/token0_layer4_attn.s` is 945 lines,
  `src/infer/token0_layer4_ffn.s` is 945 lines,
  `src/infer/token0_layer2_ffn.s` is 943 lines,
  `src/infer/token0_layer3_ffn.s` is 942 lines,
  `src/infer/token0_layer1_ffn.s` is 929 lines,
  `src/entry/start/lookup_summary.inc` is 903 lines, and
  `src/entry/start/lookup_summary/layer5.inc` is 898 lines.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/constants.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer5_cli_requests.inc`
- `src/entry/start/rodata/layer5_summary_labels.inc`
- `src/entry/start/state/layer5_globals.inc`
- `src/entry/start/state/layer5_bss.inc`
- `src/entry/start/lookup_summary/layer5.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer5.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/infer/token0_layer5_ffn.s`
- `src/infer/token0_layer5_ffn_down.s` (next)
- `work/oracle/token0_layer5_ffn_norm_oracle.py`
- `work/oracle/token0_layer5_ffn_gate_oracle.py`
- `work/oracle/token0_layer5_ffn_up_oracle.py`
- `work/oracle/token0_layer5_ffn_swiglu_oracle.py`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Descriptor-only layer-5 FFN down setup verification passed:

- `make clean all check`
- `python3 -m py_compile work/oracle/*.py`
- help text mentions the layer-5 FFN down descriptor lookup
- real-target runtime output reports `layer5_ffn_down_tensor_found: 1`,
  dimensions `9216 x 3072`, type `8`, and offset `1079721984`
- real-target runtime/oracle comparison matched all 77 covered exact-hex labels
- 24-byte zero-count GGUF kept the layer-5 FFN down descriptor and dependent
  layer-5 FFN gate/up/SwiGLU statuses fail-closed
- real-target and zero-count outputs emitted no `token0_layer5_ffn_down*` or
  `layer5_ffn_down_output*` labels
- `git diff --check`, static-link/no-dynamic-section/no-interpreter/file check,
  undefined-symbol check, exported/local symbol check, runtime source/fragment
  extension scan, include dependency scan, tracked artifact scan, tracked
  large-file scan, and line-count review passed

## Next Exact Step

Create focused layer-5 FFN down-projection module wiring for a status-only
`token0_layer5_ffn_down_matvec` smoke. Keep the existing layer-5 FFN source
from becoming a catch-all module by moving/exporting only the handoff data
needed for the new module, prove the retained `blk.5.ffn_down.weight` Q8_0
payload span, and do not publish layer-5 down exact-hex output labels yet.
