# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add status-only token-0 layer-5 FFN gate matvec coverage. It should consume
`token0_layer5_ffn_norm_status` and `token0_layer5_ffn_norm_activation`, require
the retained `blk.5.ffn_gate.weight` descriptor as Q8_0 `[3072 x 9216]`, prove
the full mapped payload span before reading matrix bytes, write a private
9216-f32 gate output buffer, and print only `token0_layer5_ffn_gate_matvec`.
Do not publish gate exact-hex output labels yet.

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
- The two-pass review gates for the completed layer-4 FFN chain and the layer-5
  attention residual handoff chain completed cleanly under `work/reviews/`.

## Verification Status

- Latest verification for descriptor-only layer-5 FFN gate setup: `make all
  check` and final `make clean all check` passed; `python3 -m py_compile
  work/oracle/*.py` passed; `--help`
  mentions the layer-5 FFN gate descriptor lookup; the real target reports
  `layer5_ffn_gate_tensor_found: 1`, dimensions `3072` and `9216`, ggml type
  `8`, and relative offset `1109803008`; no `token0_layer5_ffn_gate*` labels
  appear; the layer-5 FFN norm oracle comparison matched all 64
  oracle-covered labels; a 24-byte zero-count GGUF kept the new descriptor
  fields and dependent layer-5 statuses at `0` and emitted no layer-5 FFN norm
  exact-hex labels; `git diff --check`, static-link/no-dynamic-section/
  no-interpreter/file, undefined-symbol, exported/local symbol, runtime
  source/fragment extension, include dependency, tracked artifact, tracked
  large-file, and line-count scans passed.

## Known Blockers

- No functional blocker is known.
- Keep new work in focused modules. Do not add substantial code to files near or
  above 1000 lines before splitting or moving work into a focused module. Current
  watch list: `src/infer/token0_layer5_attn.s` is 996 lines,
  `src/infer/token0_layer2_attn.s` is 997 lines,
  `src/infer/token0_layer4_attn.s` is 945 lines,
  `src/infer/token0_layer4_ffn.s` is 945 lines,
  `src/infer/token0_layer2_ffn.s` is 943 lines, and
  `src/infer/token0_layer3_ffn.s` is 942 lines.
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
- `src/entry/start/main/bootstrap/layer5.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/infer/token0_layer5_ffn.s`
- `work/oracle/token0_layer5_ffn_norm_oracle.py`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Descriptor-only layer-5 FFN gate setup verification passed:

- `make all check`; final `make clean all check`
- `python3 -m py_compile work/oracle/*.py`
- `./mistral-asm --help` mentions the layer-5 FFN gate descriptor lookup
- real-target descriptor summary for `blk.5.ffn_gate.weight`: Q8_0
  `[3072 x 9216]`, offset `1109803008`
- no `token0_layer5_ffn_gate*` labels emitted
- layer-5 FFN norm oracle comparison matched all 64 covered labels
- 24-byte zero-count GGUF kept the new descriptor fields and dependent layer-5
  statuses at `0`
- `git diff --check`, static-link/no-dynamic-section/no-interpreter/file check,
  undefined-symbol check, exported/local symbol check, runtime source/fragment
  extension scan, include dependency scan, tracked artifact scan, tracked
  large-file scan, and line-count review passed

## Next Exact Step

Add status-only token-0 layer-5 FFN gate matvec coverage in
`src/infer/token0_layer5_ffn.s`. Require `token0_layer5_ffn_norm_status`, the
exported 3072-f32 FFN norm activation, and the retained `blk.5.ffn_gate.weight`
Q8_0 `[3072 x 9216]` descriptor; prove the full matrix payload span, write a
private 9216-f32 gate output buffer, print `token0_layer5_ffn_gate_matvec`, and
do not emit gate exact-hex labels yet.
