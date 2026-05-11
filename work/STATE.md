# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add guarded status-only token-0 layer-4 attention key matvec coverage for
`blk.4.attn_k.weight`.

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
  `[3072,1024]`, relative offset `922595328`. The descriptor is summary-only
  in the current committed step; no layer-4 key payload bytes are read yet.

## Known Blockers

- No functional blocker to the layer-4 attention key matvec step.
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
- `work/oracle/token0-layer4-attn-norm.md`
- `work/oracle/token0_layer4_attn_norm_oracle.py`
- `work/oracle/token0-layer4-attn-q-output.md`
- `work/oracle/token0_layer4_attn_q_oracle.py`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-4 attention key descriptor verification passed:

- `make clean all check`
- `make all check && ./mistral-asm --help`
- real-target run reported `layer4_attn_norm_tensor_found: 1`,
  `layer4_attn_norm_tensor_n_dimensions: 1`,
  `layer4_attn_norm_tensor_dim0: 3072`,
  `layer4_attn_norm_tensor_ggml_type: 0`, and
  `layer4_attn_norm_tensor_offset: 925937664`
- real-target run reported `layer4_attn_q_tensor_found: 1`,
  `layer4_attn_q_tensor_n_dimensions: 2`,
  `layer4_attn_q_tensor_dim0: 3072`,
  `layer4_attn_q_tensor_dim1: 4096`,
  `layer4_attn_q_tensor_ggml_type: 8`, and
  `layer4_attn_q_tensor_offset: 939319296`
- real-target run reported `layer4_attn_k_tensor_found: 1`,
  `layer4_attn_k_tensor_n_dimensions: 2`,
  `layer4_attn_k_tensor_dim0: 3072`,
  `layer4_attn_k_tensor_dim1: 1024`,
  `layer4_attn_k_tensor_ggml_type: 8`, and
  `layer4_attn_k_tensor_offset: 922595328`
- real-target run kept the published layer-3 post-FFN residual words unchanged
  and reported `token0_layer4_attn_norm: 1` and
  `token0_layer4_attn_q_matvec: 1`
- real-target runtime/oracle diff stayed empty for the layer-3 post-FFN
  residual prerequisite slice, layer-4 attention RMSNorm slice, and layer-4
  attention query output slice
- real-target run reported layer-4 attention query output words
  `0xbe996fc1`, `0xbefb10d3`, `0x3f524ef6`, and `0x3ea056cc`
- 24-byte header-only GGUF kept all layer-4 attention norm, query, and key
  descriptor fields at `0`, and reported `token0_layer4_attn_norm: 0`
- 24-byte header-only GGUF reported `token0_layer4_attn_q_matvec: 0` and
  emitted no guarded layer-4 query output labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- layer-4 descriptor symbol inspection, including the new key descriptor slot
- inference source line-count check
- tracked artifact and tracked large-file scans
- post-documentation `make all check`

## Next Exact Step

Add guarded status-only token-0 layer-4 attention key matvec coverage for
`blk.4.attn_k.weight`.
