# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Begin layer-3 attention scope with descriptor-only retained lookup/summary
coverage for `blk.3.attn_norm.weight` in focused Makefile-tracked layer-3
entry fragments.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target GGUF parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads.
- Token-0 smoke coverage now reaches the complete layer-2 FFN branch through
  the post-FFN residual. Public guarded exact-hex slices exist for layer-2
  post-attention residual, FFN RMSNorm, gate/up projections, SwiGLU activation,
  FFN-down projection, and post-FFN residual.
- Descriptor-only retained lookup and summary coverage includes
  `blk.2.ffn_down.weight`. The real target reports found `1`, dimensions `2`,
  dim0 `9216`, dim1 `3072`, type `8`, and relative offset `708648960`.
- `src/infer/token0_layer2_ffn.s` owns layer-2 FFN norm status/activation,
  gate/up matvec status/output storage, and module-owned SwiGLU output storage.
- `src/infer/token0_layer2_ffn_down.s` owns layer-2 FFN-down status/output
  storage and layer-2 post-FFN residual status/output storage. It emits the
  residual slice only after `token0_layer2_post_ffn_residual_status == 1`.
- The layer-2 FFN-down exact-hex words are `0x440c0a37`, `0xc2008554`,
  `0xc2a866d8`, and `0xc15e77da`.
- The layer-2 post-FFN residual exact-hex words are `0x440c1d48`,
  `0xc200a8d7`, `0xc2a8120a`, and `0xc15da38d`.
- Focused external oracle coverage exists through the layer-2 post-FFN residual
  slice in `work/oracle/`.
- Repository-wide, layer-1 FFN branch, and layer-2 attention branch review
  gates are complete with no blocking findings.
- Layer-2 FFN branch review gate pass 1 is complete with no blocking findings.
  The pass checked live-mmap ordering, descriptor and bounds gates, retained
  buffer dependencies, status-gated slice printing, oracle coverage, and module
  sizes.
- Layer-2 FFN branch review gate pass 2 is complete with no blocking findings.
  The pass checked exported and internal contracts, handoff ownership, CLI and
  orchestration wiring, Makefile dependency coverage, symbol surface, and
  readiness to resume feature work in focused layer-3 files/fragments.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or
  Makefile-tracked include fragments.

## Known Blockers

- No current blocker to the layer-3 attention descriptor-only lookup step.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new code
  to it before splitting or moving work into a focused module.
- `src/infer/token0_layer2_ffn.s` is 943 lines. Do not add substantial new code
  there before splitting or moving work into a focused module.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `src/infer/token0_layer2_ffn.s`
- `src/infer/token0_layer2_ffn_down.s`
- `src/infer/token0_layer2_post_attn_residual.s`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/entry/start/lookup_summary/layer2.inc`
- `src/entry/start/state.inc`
- `src/math/q8_0_dot.s`
- `src/math/rmsnorm.s`
- `src/math/swiglu.s`
- `work/oracle/token0_layer2_ffn_norm_oracle.py`
- `work/oracle/token0-layer2-ffn-norm.md`
- `work/oracle/token0_layer2_ffn_gate_oracle.py`
- `work/oracle/token0-layer2-ffn-gate.md`
- `work/oracle/token0_layer2_ffn_up_oracle.py`
- `work/oracle/token0-layer2-ffn-up.md`
- `work/oracle/token0_layer2_ffn_swiglu_oracle.py`
- `work/oracle/token0-layer2-ffn-swiglu.md`
- `work/oracle/token0_layer2_ffn_down_oracle.py`
- `work/oracle/token0-layer2-ffn-down.md`
- `work/oracle/token0_layer2_post_ffn_residual_oracle.py`
- `work/oracle/token0-layer2-post-ffn-residual.md`
- `work/reviews/2026-05-11-layer2-ffn-branch-review-1.md`
- `work/reviews/2026-05-11-layer2-ffn-branch-review-2.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-2 FFN branch review gate pass 2 verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- focused real-target runtime/oracle diff for layer-2 post-attention residual,
  FFN norm/gate/up/SwiGLU/down, and post-FFN residual exact-hex labels was empty
- real target printed all reviewed layer-2 FFN/post-residual statuses at `1`;
  post-FFN residual words remained `0x440c1d48`, `0xc200a8d7`, `0xc2a8120a`,
  and `0xc15da38d`
- temporary 24-byte empty valid GGUF kept layer-2 FFN descriptors and
  `token0_layer2_post_attn_residual`, `token0_layer2_ffn_norm`,
  `token0_layer2_ffn_gate_matvec`, `token0_layer2_ffn_up_matvec`,
  `token0_layer2_ffn_swiglu`, `token0_layer2_ffn_down_matvec`, and
  `token0_layer2_post_ffn_residual` at `0`, and emitted no guarded layer-2
  FFN/post-residual exact-hex labels
- `git diff --check`
- runtime source extension scan allowing `.s` and tracked `.inc` source files
- tracked include dependency scan
- static-link/no-dynamic-section/file check
- undefined-symbol check
- exported/local symbol inspection for
  the reviewed layer-2 FFN runners, statuses, and retained handoff buffers
- tracked-artifact and tracked large-file scans

## Next Exact Step

Begin layer-3 attention scope with descriptor-only retained lookup/summary
coverage for `blk.3.attn_norm.weight` in focused Makefile-tracked layer-3
entry fragments.
