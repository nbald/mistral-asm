# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add a status-only token-0 layer-3 attention context smoke using the existing
layer-3 Q/K/V outputs and retained output descriptor as a shape guard, without
reading `blk.3.attn_output.weight` payload bytes.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads only inside guarded smoke paths.
- Token-0 smoke coverage reaches the complete layer-2 FFN branch through the
  post-FFN residual. The layer-2 post-FFN residual words remain `0x440c1d48`,
  `0xc200a8d7`, `0xc2a8120a`, and `0xc15da38d`.
- Layer-3 attention coverage now includes retained descriptor lookup and summary
  output for `blk.3.attn_norm.weight`, `blk.3.attn_q.weight`,
  `blk.3.attn_k.weight`, `blk.3.attn_v.weight`, and
  `blk.3.attn_output.weight`.
- On the real target, the layer-3 output projection descriptor is found with
  dimensions `4096x3072`, type `8`, and relative offset `802258944`. The step is
  descriptor-only; static checks found no layer-3 output/context payload path.
- Existing layer-3 public slices remain guarded by their statuses. The current
  real-target words are:
  layer-3 RMSNorm `0x41be7bcf`, `0xc06721de`, `0xc13cb538`, `0xbfe354dc`;
  query `0x3de458d2`, `0x3eae6d55`, `0x3d06883d`, `0xbe14568c`;
  key `0xbaf936b2`, `0xbcf1bab9`, `0x3c7af998`, `0x3c825ee2`; and value
  `0x3a75acca`, `0x3baaa296`, `0xbbde3580`, `0x3bcdaf05`.
- The layer-3 attention exact-hex rodata labels and printer helpers for public
  RMSNorm/query/key/value slices live in the Makefile-tracked
  `src/infer/token0_layer3_attn_slices.inc` include.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or
  Makefile-tracked include fragments.

## Known Blockers

- No functional blocker to the layer-3 attention context status smoke.
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
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 output descriptor verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- real-target run reported `layer3_attn_output_tensor_found: 1`, dim0 `4096`,
  dim1 `3072`, type `8`, and offset `802258944`
- real-target run preserved `token0_layer3_attn_norm: 1`,
  `token0_layer3_attn_q_matvec: 1`, `token0_layer3_attn_k_matvec: 1`, and
  `token0_layer3_attn_v_matvec: 1`
- focused runtime/oracle diff was empty for the layer-2 post-FFN residual,
  layer-3 attention RMSNorm, and layer-3 value public labels
- temporary 24-byte empty valid GGUF kept all layer-3 descriptor fields and
  dependent statuses at `0`, including the new output descriptor fields, and
  emitted no guarded layer-3 exact-hex labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- layer-3 output descriptor-only scan found no output/context payload path
- static-link/no-dynamic-section/file check
- undefined-symbol check
- layer-3 output descriptor symbol inspection
- tracked artifact and tracked large-file scans

## Next Exact Step

Add a status-only token-0 layer-3 attention context smoke using the existing
layer-3 Q/K/V outputs and retained output descriptor as a shape guard, without
reading `blk.3.attn_output.weight` payload bytes.
