# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Run review gate pass 1 over the token-0 layer-4 post-attention residual handoff
before starting layer-4 FFN scope.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and
  linked with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups,
  and bounded tensor payload reads only inside guarded smoke paths.
- Token-0 layer-3 smoke coverage publishes guarded exact-hex slices through the
  complete post-FFN residual. The first four layer-3 post-FFN residual words
  are `0x440c2692`, `0xc1ff9359`, `0xc2a96a19`, and `0xc15e5fea`.
- Layer-3 retained descriptors cover attention norm/query/key/value/output and
  FFN norm/gate/up/down. `src/infer/token0_layer3_ffn.s` owns layer-3 FFN
  norm/gate/up/SwiGLU, and `src/infer/token0_layer3_ffn_down.s` owns layer-3
  FFN down plus post-FFN residual storage.
- The two-pass review gate for the token-0 layer-3 FFN/down/post-residual chain
  completed cleanly; feature work resumed in focused layer-4 entry fragments.
- Layer-4 attention scope now has descriptor-only retained lookup and summary
  coverage for `blk.4.attn_norm.weight`. On the real target it is f32
  `[3072]`, relative offset `925937664`.
- `src/infer/token0_layer4_attn.s` now owns guarded token-0 layer-4 attention
  RMSNorm coverage. It requires the retained layer-3
  post-FFN residual, captured RMSNorm epsilon, the exact f32 `[3072]`
  `blk.4.attn_norm.weight` descriptor, and a bounded payload span before
  filling retained layer-4 attention norm activation storage.
- The first guarded layer-4 attention RMSNorm exact-hex slice is published and
  covered by `work/oracle/token0_layer4_attn_norm_oracle.py`. The first four
  layer-4 attention RMSNorm words are `0x420c4b32`, `0xc0768887`,
  `0xc14b813f`, and `0xbffefae6`.
- Layer-4 attention scope now also has descriptor-only retained lookup and
  summary coverage for `blk.4.attn_q.weight`. On the real target it is Q8_0
  `[3072,4096]`, relative offset `939319296`.
- `src/infer/token0_layer4_attn.s` now also owns guarded token-0 layer-4
  attention query matvec coverage. It requires the retained layer-4 attention
  RMSNorm activation, exact Q8_0 `[3072,4096]` `blk.4.attn_q.weight`
  descriptor, and a bounded payload span before filling private query output
  storage and reporting `token0_layer4_attn_q_matvec`.
- The first guarded layer-4 attention query exact-hex slice is published and
  covered by `work/oracle/token0_layer4_attn_q_oracle.py`. The first four
  layer-4 attention query words are `0xbe996fc1`, `0xbefb10d3`,
  `0x3f524ef6`, and `0x3ea056cc`.
- Layer-4 attention scope now also has descriptor-only retained lookup and
  summary coverage for `blk.4.attn_k.weight`. On the real target it is Q8_0
  `[3072,1024]`, relative offset `922595328`.
- `src/infer/token0_layer4_attn.s` now also owns guarded status-only token-0
  layer-4 attention key matvec coverage. It requires the retained layer-4
  attention RMSNorm activation, exact Q8_0 `[3072,1024]`
  `blk.4.attn_k.weight` descriptor, and a bounded payload span before filling
  private key output storage and reporting `token0_layer4_attn_k_matvec`.
- The first guarded layer-4 attention key exact-hex slice is published and
  covered by `work/oracle/token0_layer4_attn_k_oracle.py`. The first four
  layer-4 attention key words are `0xbc326305`, `0x3c2ff2f1`, `0x3a8970d8`,
  and `0xbc83c191`.
- Layer-4 attention scope now also has descriptor-only retained lookup and
  summary coverage for `blk.4.attn_v.weight`. On the real target it is Q8_0
  `[3072,1024]`, relative offset `952688640`.
- `src/infer/token0_layer4_attn.s` now also owns guarded status-only token-0
  layer-4 attention value matvec coverage. It requires the retained layer-4
  attention RMSNorm activation, exact Q8_0 `[3072,1024]`
  `blk.4.attn_v.weight` descriptor, and a bounded payload span before filling
  private value output storage and reporting `token0_layer4_attn_v_matvec`.
- Layer-4 attention value output slice printing is published from
  `src/infer/token0_layer4_attn_slices.inc`, which also owns the existing
  layer-4 attention RMSNorm/query/key slice printers to keep the focused
  layer-4 attention `.s` file below the source-size guard. The first four
  layer-4 attention value words are `0x3bb659d7`, `0xbc5c2ba7`,
  `0x3bf35210`, and `0xbc1e7f5f`.
- `work/oracle/token0_layer4_attn_v_oracle.py` covers the first four
  `blk.4.attn_v.weight` rows by reusing the full layer-4 attention RMSNorm
  oracle path and ordered scalar f32 Q8_0 accumulation.
- Layer-4 attention scope now also has descriptor-only retained lookup and
  summary coverage for `blk.4.attn_output.weight`. On the real target it is
  Q8_0 `[4096,3072]`, relative offset `925949952`. The descriptor is retained
  only for future layer-4 context/output projection shape guarding; no
  layer-4 output-projection payload reads were added.
- Layer-4 attention context coverage is now status-only and retained inside
  `src/infer/token0_layer4_attn.s`. It requires layer-4 query/key/value matvec
  success plus exact retained query/key/value/output descriptor shapes, expands
  the single-token grouped-query context from the value output, reports
  `token0_layer4_attn_context`, and publishes no context exact-hex slice.
- Layer-4 attention output-projection coverage is now status-only and retained
  inside `src/infer/token0_layer4_attn.s`. It requires retained layer-4
  context success plus the exact Q8_0 `[4096,3072]`
  `blk.4.attn_output.weight` descriptor, bounds-checks the full payload span,
  runs `q8_0_matvec_f32`, reports `token0_layer4_attn_output_matvec`, and
  retains `token0_layer4_attn_output`.
- The first guarded layer-4 attention output-projection exact-hex slice is
  published from `src/infer/token0_layer4_attn_slices.inc`, with only minimal
  call wiring in `src/infer/token0_layer4_attn.s`. The first four layer-4
  attention output words are `0x3cfe6cdc`, `0x3e2382d0`, `0xbd9ca89f`, and
  `0xbd9a5c81`.
- `work/oracle/token0_layer4_attn_output_oracle.py` covers those four output
  projection rows by computing the full layer-4 value projection, expanding the
  single-token grouped-query context, and dotting the context with the first
  four `blk.4.attn_output.weight` rows using ordered scalar f32 Q8_0
  accumulation. `work/oracle/token0-layer4-attn-output.md` records the oracle
  command and exact comparison evidence.
- Review gate pass 1 for the token-0 layer-4 attention chain completed cleanly
  under `work/reviews/2026-05-11-layer4-attn-chain-review-1.md`. It found no
  blocking issues in descriptor guards, single-token context semantics,
  output-projection oracle quality, source-size pressure handling, or
  header-only guard behavior.
- Review gate pass 2 for the token-0 layer-4 attention chain completed cleanly
  under `work/reviews/2026-05-11-layer4-attn-chain-review-2.md`. The two-pass
  review gate is complete; feature work can resume in a focused layer-4
  post-attention residual module.
- `src/infer/token0_layer4_post_attn_residual.s` now owns guarded token-0
  layer-4 post-attention residual coverage. It requires
  `token0_layer3_post_ffn_residual_status`,
  `token0_layer4_attn_output_matvec_status`, and the retained layer-4 attention
  output descriptor width before filling retained
  `token0_layer4_post_attn_residual` storage and reporting
  `token0_layer4_post_attn_residual`.
- The first guarded layer-4 post-attention residual exact-hex slice is
  published from `src/infer/token0_layer4_post_attn_residual.s`. The first four
  layer-4 post-attention residual words are `0x440c288f`, `0xc1fe4c53`,
  `0xc2a99143`, and `0xc15f94a3`.
- `work/oracle/token0_layer4_post_attn_residual_oracle.py` covers those four
  residual words by reusing the layer-4 attention output oracle path and adding
  the first four layer-3 post-FFN residual words with scalar f32 rounding.
  `work/oracle/token0-layer4-post-attn-residual.md` records the oracle command
  and exact comparison evidence.

## Known Blockers

- No functional blocker is known. Because the next feature step starts layer-4
  FFN scope after the layer-4 attention/residual handoff, run review gate pass 1
  first.
- `src/infer/token0_layer4_attn.s` is 945 lines after the output-projection
  slice call wiring. Keep future edits minimal there and put substantial new
  layer-4 residual/FFN work in focused modules.
- `src/infer/token0_layer3_ffn.s` is 942 lines,
  `src/infer/token0_layer2_ffn.s` is 943 lines, and
  `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new
  code to them before splitting or moving work into focused modules.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/constants.inc`
- `src/entry/start/rodata.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer4_cli_requests.inc`
- `src/entry/start/rodata/layer4_summary_labels.inc`
- `src/entry/start/state.inc`
- `src/entry/start/state/layer4_globals.inc`
- `src/entry/start/state/layer4_bss.inc`
- `src/entry/start/lookup_summary.inc`
- `src/entry/start/lookup_summary/layer4.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer3.inc`
- `src/entry/start/main/bootstrap/layer4.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/infer/token0_layer4_attn.s`
- `src/infer/token0_layer4_attn_slices.inc`
- `src/infer/token0_layer4_post_attn_residual.s`
- `work/oracle/token0-layer4-attn-norm.md`
- `work/oracle/token0_layer4_attn_norm_oracle.py`
- `work/oracle/token0-layer4-attn-q-output.md`
- `work/oracle/token0_layer4_attn_q_oracle.py`
- `work/oracle/token0-layer4-attn-k-output.md`
- `work/oracle/token0_layer4_attn_k_oracle.py`
- `work/oracle/token0-layer4-attn-v-output.md`
- `work/oracle/token0_layer4_attn_v_oracle.py`
- `work/oracle/token0-layer4-attn-output.md`
- `work/oracle/token0_layer4_attn_output_oracle.py`
- `work/oracle/token0-layer4-post-attn-residual.md`
- `work/oracle/token0_layer4_post_attn_residual_oracle.py`
- `work/reviews/2026-05-11-layer4-attn-chain-review-1.md`
- `work/reviews/2026-05-11-layer4-attn-chain-review-2.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-4 post-attention residual slice verification passed:

- `make clean all check` and `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- real-target focused runtime/oracle diff was empty for the public layer-3
  post-FFN residual, layer-4 attention output, and layer-4 post-attention
  residual slices; the new residual words are `0x440c288f`, `0xc1fe4c53`,
  `0xc2a99143`, and `0xc15f94a3`
- 24-byte header-only GGUF reported `token0_layer4_attn_output_matvec: 0` and
  `token0_layer4_post_attn_residual: 0`, and emitted no guarded
  `token0_layer4_*_f32_hex` labels
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- exported symbol check for `run_token0_layer4_post_attn_residual_status`,
  `token0_layer4_post_attn_residual_status`, and
  `token0_layer4_post_attn_residual`
- inference/source line-count check; `src/infer/token0_layer4_attn.s` remains
  945 lines and `src/infer/token0_layer4_post_attn_residual.s` is 223 lines
- tracked artifact and tracked large-file scans

## Next Exact Step

Run review gate pass 1 over the token-0 layer-4 post-attention residual handoff,
including descriptor/status guards, exact-slice oracle quality, header-only
silence, help text accuracy, and readiness to begin focused layer-4 FFN work.
