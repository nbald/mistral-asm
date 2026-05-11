# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add descriptor-only retained lookup coverage for `blk.3.attn_output.weight`,
with separate layer-3 output descriptor storage and summary output, verified
against the real target and the 24-byte empty GGUF without reading output
projection payload bytes.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads.
- Token-0 smoke coverage reaches the complete layer-2 FFN branch through the
  post-FFN residual. The layer-2 post-FFN residual words remain `0x440c1d48`,
  `0xc200a8d7`, `0xc2a8120a`, and `0xc15da38d`.
- Layer-3 attention coverage now includes descriptor lookup and guarded output
  slices for `blk.3.attn_norm.weight`, `blk.3.attn_q.weight`,
  `blk.3.attn_k.weight`, and `blk.3.attn_v.weight`.
- On the real target, the layer-3 attention key projection now publishes
  `token0_layer3_attn_k_output*_f32_hex` only after
  `token0_layer3_attn_k_matvec: 1`. The first four words are `0xbaf936b2`,
  `0xbcf1bab9`, `0x3c7af998`, and `0x3c825ee2`, matching the focused external
  oracle.
- On the real target, the layer-3 attention value projection now publishes
  `token0_layer3_attn_v_output*_f32_hex` only after
  `token0_layer3_attn_v_matvec: 1`. The first four words are `0x3a75acca`,
  `0x3baaa296`, `0xbbde3580`, and `0x3bcdaf05`, matching the focused external
  oracle. The retained value descriptor remains found with dimensions
  `3072x1024`, type `8`, and relative offset `828997632`.
- The existing layer-3 attention exact-hex rodata labels and printer helpers
  for the RMSNorm, query, key, and value public slices now live in the
  Makefile-tracked `src/infer/token0_layer3_attn_slices.inc` include.
  `src/infer/token0_layer3_attn.s` is now 620 lines and the include is 383
  lines.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or
  Makefile-tracked include fragments.

## Known Blockers

- No functional blocker to the layer-3 attention output descriptor lookup.
- Keep layer-3 attention slice labels and printer code in
  `src/infer/token0_layer3_attn_slices.inc`; it is tracked in `Makefile` so
  edits rebuild `build/infer/token0_layer3_attn.o`.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new code
  to it before splitting or moving work into a focused module.
- `src/infer/token0_layer2_ffn.s` is 943 lines. Do not add substantial new code
  there before splitting or moving work into a focused module.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/constants.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer3_cli_requests.inc`
- `src/entry/start/rodata/layer3_summary_labels.inc`
- `src/entry/start/state/layer3_globals.inc`
- `src/entry/start/state/layer3_bss.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer3.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/lookup_summary/layer3.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/infer/token0_layer3_attn.s`
- `src/infer/token0_layer3_attn_slices.inc`
- `work/oracle/token0_layer3_attn_v_oracle.py`
- `work/oracle/token0-layer3-attn-v-output.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 attention value output slice verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- real-target runtime/oracle diff was empty for the public exact-hex labels:
  layer-2 post-FFN residual, layer-3 attention RMSNorm, and layer-3 value
  output
- real-target run printed the layer-3 value descriptor as found with dim0
  `3072`, dim1 `1024`, type `8`, and offset `828997632`
- real-target run preserved `token0_layer3_attn_norm: 1`,
  `token0_layer3_attn_q_matvec: 1`, `token0_layer3_attn_k_matvec: 1`, and
  `token0_layer3_attn_v_matvec: 1`, and printed
  `token0_layer3_attn_v_output0..3_f32_hex` as `0x3a75acca`, `0x3baaa296`,
  `0xbbde3580`, and `0x3bcdaf05`
- temporary 24-byte empty valid GGUF kept all layer-3 descriptor fields and
  dependent statuses at `0`, including `token0_layer3_attn_v_matvec: 0`, and
  emitted no guarded layer-3 norm/query/key/value output labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- corrected include dependency scan covering `.include` fragments in
  `Makefile`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- local/exported symbol inspection for the layer-3 public runners/statuses,
  private output storage, and local slice printer helpers
- tracked artifact and tracked large-file scans

## Next Exact Step

Add descriptor-only retained lookup coverage for `blk.3.attn_output.weight`,
with separate layer-3 output descriptor storage and summary output, verified
against the real target and the 24-byte empty GGUF without reading output
projection payload bytes.
