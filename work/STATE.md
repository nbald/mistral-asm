# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add status-only token-0 layer-2 FFN SwiGLU activation coverage in the focused
FFN module, guarded by successful layer-2 FFN gate and up matvec statuses, while
keeping the SwiGLU output buffer private until a later output-slice step.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target GGUF parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads.
- Token-0 smoke coverage now reaches layer-2 post-attention residual, layer-2
  FFN RMSNorm activation, layer-2 FFN gate matvec output, and layer-2 FFN up
  matvec output.
- The retained entry-side lookup chain now captures and prints
  `blk.2.ffn_up.weight` descriptor fields (`found`, dimension count, dim0,
  dim1, type, and relative offset) after the layer-2 FFN gate descriptor. This
  descriptor-only step does not read FFN up payload bytes.
- `src/infer/token0_layer2_ffn.s` owns layer-2 FFN norm status/activation and
  layer-2 FFN gate/up matvec status/output storage. Both projection paths
  require `token0_layer2_ffn_norm_status == 1`, retained Q8_0
  `[3072 x 9216]` descriptors, mapping base, and complete payload bounds before
  filling their private 9216-f32 output buffers. The gate path prints its
  status and first four exact-hex output words; the up path now does the same.
- Durable external oracle coverage exists through the layer-2 FFN RMSNorm and
  gate slices in `work/oracle/token0_layer2_ffn_norm_oracle.py`,
  `work/oracle/token0-layer2-ffn-norm.md`,
  `work/oracle/token0_layer2_ffn_gate_oracle.py`, and
  `work/oracle/token0-layer2-ffn-gate.md`.
- Durable external oracle coverage for the layer-2 FFN up slice now exists in
  `work/oracle/token0_layer2_ffn_up_oracle.py` and
  `work/oracle/token0-layer2-ffn-up.md`; the first four up words are
  `0x4289660c`, `0x3ef6cc7e`, `0xc1421f69`, and `0x3e00b19d`.
- Repository-wide, layer-1 FFN branch, and layer-2 attention branch review gates
  are complete with no blocking findings.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or
  Makefile-tracked include fragments.

## Known Blockers

- No current blocker to adding status-only layer-2 FFN SwiGLU coverage.
- The layer-2 FFN gate and up output buffers are intentionally module-private
  until a later SwiGLU handoff needs to read them.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new code
  to it before splitting or moving work into a focused module.
- `src/infer/token0_layer2_ffn.s` is 747 lines after the up output slice. Keep
  new work focused and split before it approaches the 1000-line threshold.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `src/infer/token0_layer2_ffn.s`
- `src/entry/start/constants.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/summary_labels.inc`
- `src/entry/start/lookup_summary/layer2.inc`
- `src/entry/start/state.inc`
- `src/math/q8_0_dot.s`
- `work/oracle/token0_layer2_ffn_norm_oracle.py`
- `work/oracle/token0-layer2-ffn-norm.md`
- `work/oracle/token0_layer2_ffn_gate_oracle.py`
- `work/oracle/token0-layer2-ffn-gate.md`
- `work/oracle/token0_layer2_ffn_up_oracle.py`
- `work/oracle/token0-layer2-ffn-up.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-2 FFN up output-slice verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- `python3 work/oracle/token0_layer2_ffn_up_oracle.py ...` printed
  `oracle_token0_layer2_ffn_up_output0_f32_hex` through
  `oracle_token0_layer2_ffn_up_output3_f32_hex` as `0x4289660c`,
  `0x3ef6cc7e`, `0xc1421f69`, and `0x3e00b19d`
- real target runtime smoke printed `token0_layer2_ffn_up_matvec: 1` and the
  same four guarded up output words after the retained `blk.2.ffn_up.weight`
  Q8_0 `[3072 x 9216]` descriptor, while preserving the reviewed layer-2 FFN
  RMSNorm and gate output words
- temporary 24-byte empty valid GGUF kept `layer2_ffn_norm_tensor_*`,
  `layer2_ffn_gate_tensor_*`, `layer2_ffn_up_tensor_*`,
  `token0_layer2_attn_output_matvec`, `token0_layer2_post_attn_residual`,
  `token0_layer2_ffn_norm`, `token0_layer2_ffn_gate_matvec`, and
  `token0_layer2_ffn_up_matvec` at `0`, and emitted no guarded layer-2 FFN
  norm/gate/up output words
- `git diff --check`
- runtime source extension scan allowing `.s` and tracked `.inc` source files
- tracked include dependency scan
- static-link/no-dynamic-section/file check
- undefined-symbol check
- exported-symbol inspection for the retained layer-2 FFN norm/gate/up status
  symbols, with `token0_layer2_ffn_up_output` remaining private
- tracked-artifact and tracked large-file scans

## Next Exact Step

Add status-only token-0 layer-2 FFN SwiGLU activation coverage in
`src/infer/token0_layer2_ffn.s`, guarded by both layer-2 FFN gate and up matvec
statuses, then verify the real target reports the new status as `1` and the
empty valid GGUF keeps it at `0` without printing SwiGLU output words.
