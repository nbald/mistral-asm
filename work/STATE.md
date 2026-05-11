# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add descriptor-only retained lookup coverage for `blk.3.attn_v.weight` in the
focused layer-3 entry fragments, with no layer-3 value matvec or payload read.

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
  slices for `blk.3.attn_norm.weight`, `blk.3.attn_q.weight`, and
  `blk.3.attn_k.weight`.
- On the real target, the layer-3 attention key projection now publishes
  `token0_layer3_attn_k_output*_f32_hex` only after
  `token0_layer3_attn_k_matvec: 1`. The first four words are `0xbaf936b2`,
  `0xbcf1bab9`, `0x3c7af998`, and `0x3c825ee2`, matching the focused external
  oracle.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or
  Makefile-tracked include fragments.

## Known Blockers

- No current blocker to the layer-3 attention value descriptor step.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new code
  to it before splitting or moving work into a focused module.
- `src/infer/token0_layer2_ffn.s` is 943 lines. Do not add substantial new code
  there before splitting or moving work into a focused module.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer3_cli_requests.inc`
- `src/entry/start/rodata/layer3_summary_labels.inc`
- `src/entry/start/state/layer3_globals.inc`
- `src/entry/start/state/layer3_bss.inc`
- `src/entry/start/main/bootstrap/layer3.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/lookup_summary/layer3.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/infer/token0_layer3_attn.s`
- `work/oracle/token0_layer3_attn_k_oracle.py`
- `work/oracle/token0-layer3-attn-k-output.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 attention key output slice verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- focused `work/oracle/token0_layer3_attn_k_oracle.py` run on the real target
- real-target runtime/oracle diff was empty for the layer-2 post-FFN residual,
  layer-3 attention RMSNorm, and layer-3 attention key output public labels
- real-target run printed layer-3 attention norm/query/key descriptors as found
  with the expected dimensions, types, and offsets, preserved
  `token0_layer3_attn_q_matvec: 1`, and printed
  `token0_layer3_attn_k_matvec: 1`
- temporary 24-byte empty valid GGUF kept all layer-3 descriptor fields and
  dependent statuses at `0` and emitted no guarded layer-2 post-FFN residual,
  layer-3 attention RMSNorm, layer-3 query, or layer-3 key exact-hex output
  labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- local/exported symbol inspection for the layer-3 key descriptor fields,
  runner, status slot, private output buffer, smoke helper, and slice printer
- tracked artifact and tracked large-file scans

## Next Exact Step

Add descriptor-only retained lookup coverage for `blk.3.attn_v.weight` in the
focused layer-3 entry fragments, with no layer-3 value matvec or payload read.
