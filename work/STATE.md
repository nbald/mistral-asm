# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish the first guarded layer-2 FFN gate matvec exact-hex output slice and
add/update external oracle coverage for the first four f32 words.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target GGUF parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads.
- Token-0 smoke coverage now reaches layer-2 post-attention residual, layer-2
  FFN RMSNorm activation, and a status-only layer-2 FFN gate matvec.
- `src/infer/token0_layer2_ffn.s` owns layer-2 FFN norm status/activation and
  layer-2 FFN gate matvec status/output storage. The gate path requires
  `token0_layer2_ffn_norm_status == 1`, retained `blk.2.ffn_gate.weight`
  descriptor shape/type `Q8_0 [3072 x 9216]`, mapping base, and complete payload
  bounds before filling its private 9216-f32 output buffer. It currently prints
  only `token0_layer2_ffn_gate_matvec`.
- Durable external oracle coverage exists through the layer-2 FFN RMSNorm slice
  in `work/oracle/token0_layer2_ffn_norm_oracle.py` and
  `work/oracle/token0-layer2-ffn-norm.md`.
- Repository-wide, layer-1 FFN branch, and layer-2 attention branch review gates
  are complete with no blocking findings.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or
  Makefile-tracked include fragments.

## Known Blockers

- No current blocker to publishing the guarded layer-2 FFN gate output slice.
- The gate output buffer is intentionally module-private; publish through a
  focused printer in `src/infer/token0_layer2_ffn.s` unless a later handoff
  needs a different owner.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new code
  to it before splitting or moving work into a focused module.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `src/infer/token0_layer2_ffn.s`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/math/q8_0_dot.s`
- `work/oracle/token0_layer2_ffn_norm_oracle.py`
- `work/oracle/token0-layer2-ffn-norm.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-2 FFN gate matvec status-only verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- real target runtime smoke printed retained `layer2_ffn_gate_tensor_*` metadata,
  preserved the reviewed layer-2 FFN RMSNorm exact-hex words, and printed
  `token0_layer2_ffn_gate_matvec: 1`
- temporary 24-byte empty valid GGUF kept `layer2_ffn_norm_tensor_*`,
  `layer2_ffn_gate_tensor_*`, `token0_layer2_attn_output_matvec`,
  `token0_layer2_post_attn_residual`, `token0_layer2_ffn_norm`, and
  `token0_layer2_ffn_gate_matvec` at `0`
- `git diff --check`
- runtime source extension scan allowing `.s` and tracked `.inc` source files
- tracked include dependency scan
- static-link/no-dynamic-section/file check
- undefined-symbol check
- exported-symbol inspection for `run_token0_layer2_ffn_gate_matvec_status` and
  `token0_layer2_ffn_gate_matvec_status`
- tracked-artifact and tracked large-file scans

## Next Exact Step

Publish the first guarded layer-2 FFN gate matvec exact-hex output slice and
add/update external oracle coverage for the first four f32 words.
