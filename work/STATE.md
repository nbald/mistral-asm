# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add descriptor-only layer-5 FFN up setup for `blk.5.ffn_up.weight`: retain and
print the descriptor summary, update help text, and do not read up payload bytes
or publish a layer-5 up matvec status yet.

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
- The two-pass review gates for the completed layer-4 FFN chain and the layer-5
  attention residual handoff chain completed cleanly under `work/reviews/`.

## Verification Status

- Latest verification for layer-5 FFN gate exact-hex slice coverage: `make
  clean all check` passed; `python3 -m py_compile work/oracle/*.py` passed;
  `--help` mentions layer-5 FFN gate descriptor lookup/gate matvec output
  slice; the real target reports `token0_layer5_ffn_gate_matvec: 1` and the
  four gate words `0x3e9c4027`, `0xbc08dfb9`, `0x3f25e360`, and `0x3ef1f366`;
  the focused layer-5 FFN gate oracle comparison matched all 69
  oracle-covered exact-hex labels on the final clean-built binary; a 24-byte
  zero-count GGUF kept `layer5_ffn_gate_tensor_found`,
  `token0_layer5_ffn_norm`, and `token0_layer5_ffn_gate_matvec` at `0` and
  emitted no layer-5 FFN gate output exact-hex labels; `git diff --check`,
  static-link/no-dynamic-section/no-interpreter/file, undefined-symbol,
  exported/local symbol, runtime source/fragment extension, include dependency,
  tracked artifact, tracked large-file, and line-count scans passed.

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
- `work/oracle/token0_layer5_ffn_gate_oracle.py`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-5 FFN gate exact-hex slice verification passed:

- `make clean all check`
- `python3 -m py_compile work/oracle/*.py`
- `./mistral-asm --help` mentions the layer-5 FFN gate descriptor lookup/gate
  matvec output slice
- real-target descriptor summary for `blk.5.ffn_gate.weight`: Q8_0
  `[3072 x 9216]`, offset `1109803008`
- real target reported `token0_layer5_ffn_gate_matvec: 1`
- real target published `token0_layer5_ffn_gate_output0_f32_hex` through
  `token0_layer5_ffn_gate_output3_f32_hex` as `0x3e9c4027`, `0xbc08dfb9`,
  `0x3f25e360`, and `0x3ef1f366`
- layer-5 FFN gate oracle comparison matched all 69 covered exact-hex labels
  on the final clean-built binary
- 24-byte zero-count GGUF kept the descriptor fields and dependent layer-5
  statuses at `0`, including `token0_layer5_ffn_gate_matvec: 0`, and emitted no
  layer-5 FFN gate output exact-hex labels
- `git diff --check`, static-link/no-dynamic-section/no-interpreter/file check,
  undefined-symbol check, exported/local symbol check, runtime source/fragment
  extension scan, include dependency scan, tracked artifact scan, tracked
  large-file scan, and line-count review passed

## Next Exact Step

Add descriptor-only layer-5 FFN up setup for `blk.5.ffn_up.weight` in the
layer-5 descriptor lookup path. Retain found/n_dims/dim0/dim1/type/offset,
print the summary and help text, verify the real-target descriptor is Q8_0
`[3072 x 9216]`, and keep this step descriptor-only with no up payload reads or
`token0_layer5_ffn_up_matvec` status.
