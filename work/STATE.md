# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add descriptor-only retained lookup/summary coverage for
`blk.3.attn_k.weight` in focused layer-3 entry fragments, with no key matvec or
payload reads.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads.
- Token-0 smoke coverage reaches the complete layer-2 FFN branch through the
  post-FFN residual. The layer-2 post-FFN residual words remain `0x440c1d48`,
  `0xc200a8d7`, `0xc2a8120a`, and `0xc15da38d`.
- Layer-3 attention scope has started with descriptor-only retained lookup and
  summary coverage for `blk.3.attn_norm.weight` in focused, Makefile-tracked
  entry fragments.
- On the real target, `blk.3.attn_norm.weight` reports found `1`, dimensions
  `1`, dim0 `3072`, type `0`, and relative offset `802246656`.
- Token-0 layer-3 attention RMSNorm coverage now lives in focused
  `src/infer/token0_layer3_attn.s`. It waits for the retained layer-2 post-FFN
  residual, rechecks the retained layer-3 RMSNorm descriptor and epsilon,
  bounds the full 3072-f32 weight span inside the live mapping, fills private
  layer-3 norm activation storage, and publishes `token0_layer3_attn_norm`.
- The layer-3 attention RMSNorm smoke now publishes a guarded first-four-word
  exact-hex activation slice. On the real target it prints `0x41be7bcf`,
  `0xc06721de`, `0xc13cb538`, and `0xbfe354dc`, matching the focused external
  oracle.
- Descriptor-only retained lookup coverage now includes `blk.3.attn_q.weight`
  with no layer-3 query payload reads. On the real target it reports found `1`,
  dimensions `2`, dim0 `3072`, dim1 `4096`, type `8`, and relative offset
  `815628288`.
- Layer-3 attention query matvec coverage consumes the retained
  `blk.3.attn_q.weight` descriptor and `token0_layer3_attn_norm` activation.
  It bounds the full row-major Q8_0 [3072 x 4096] payload and fills private
  `token0_layer3_attn_q_output` storage before setting
  `token0_layer3_attn_q_matvec`.
- The layer-3 attention query smoke now publishes a guarded first-four-word
  exact-hex output slice only after `token0_layer3_attn_q_matvec: 1`. On the
  real target it prints `0x3de458d2`, `0x3eae6d55`, `0x3d06883d`, and
  `0xbe14568c`, matching the focused external oracle.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or
  Makefile-tracked include fragments.

## Known Blockers

- No current blocker to the layer-3 attention key descriptor step.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new code
  to it before splitting or moving work into a focused module.
- `src/infer/token0_layer2_ffn.s` is 943 lines. Do not add substantial new code
  there before splitting or moving work into a focused module.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/constants.inc`
- `src/entry/start/lookup_summary.inc`
- `src/entry/start/lookup_summary/layer3.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer3.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/rodata.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer3_cli_requests.inc`
- `src/entry/start/rodata/layer3_summary_labels.inc`
- `src/entry/start/state.inc`
- `src/entry/start/state/layer3_globals.inc`
- `src/entry/start/state/layer3_bss.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/infer/token0_layer3_attn.s`
- `src/infer/token0_layer2_ffn_down.s`
- `work/oracle/token0_layer3_attn_norm_oracle.py`
- `work/oracle/token0-layer3-attn-norm.md`
- `work/oracle/token0_layer3_attn_q_oracle.py`
- `work/oracle/token0-layer3-attn-q-output.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 attention query output-slice verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- real-target run printed layer-3 attention RMSNorm descriptor found `1`,
  dimensions `1`, dim0 `3072`, type `0`, and offset `802246656`, then printed
  layer-3 attention query descriptor found `1`, dimensions `2`, dim0 `3072`,
  dim1 `4096`, type `8`, and offset `815628288`; it also preserved
  `token0_layer2_post_ffn_residual: 1`, `token0_layer3_attn_norm: 1`, the
  known guarded exact-hex words, and printed `token0_layer3_attn_q_matvec: 1`
  followed by guarded layer-3 query output words `0x3de458d2`, `0x3eae6d55`,
  `0x3d06883d`, and `0xbe14568c`
- real-target runtime/oracle diff was empty for the layer-2 post-FFN residual,
  layer-3 attention RMSNorm, and layer-3 attention query output public
  exact-hex labels
- temporary 24-byte empty valid GGUF kept the layer-3 descriptor fields at `0`,
  including the new query descriptor slot, kept `token0_layer2_post_ffn_residual`
  and `token0_layer3_attn_norm` at `0`, printed
  `token0_layer3_attn_q_matvec: 0`, and emitted no guarded layer-2 post-FFN
  residual, layer-3 attention RMSNorm, or layer-3 attention query exact-hex
  output labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- local/exported symbol inspection for the layer-3 query matvec runner, status,
  internal smoke helper, guarded slice printer, and private output storage
- tracked artifact and tracked large-file scans

## Next Exact Step

Add descriptor-only retained lookup/summary coverage for
`blk.3.attn_k.weight` in focused layer-3 entry fragments, with no key matvec or
payload reads.
