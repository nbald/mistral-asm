# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add descriptor-only coverage for `blk.2.ffn_up.weight` in the retained
entry-side lookup chain.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target GGUF parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads.
- Token-0 smoke coverage now reaches layer-2 post-attention residual, layer-2
  FFN RMSNorm activation, and layer-2 FFN gate matvec output.
- `src/infer/token0_layer2_ffn.s` owns layer-2 FFN norm status/activation and
  layer-2 FFN gate matvec status/output storage. The gate path requires
  `token0_layer2_ffn_norm_status == 1`, retained `blk.2.ffn_gate.weight`
  descriptor shape/type `Q8_0 [3072 x 9216]`, mapping base, and complete payload
  bounds before filling its private 9216-f32 output buffer. It prints
  `token0_layer2_ffn_gate_matvec` and the first four exact-hex gate output
  words only when the guarded matvec succeeds.
- Durable external oracle coverage exists through the layer-2 FFN RMSNorm and
  gate slices in `work/oracle/token0_layer2_ffn_norm_oracle.py`,
  `work/oracle/token0-layer2-ffn-norm.md`,
  `work/oracle/token0_layer2_ffn_gate_oracle.py`, and
  `work/oracle/token0-layer2-ffn-gate.md`.
- Repository-wide, layer-1 FFN branch, and layer-2 attention branch review gates
  are complete with no blocking findings.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or
  Makefile-tracked include fragments.

## Known Blockers

- No current blocker to adding the layer-2 FFN up descriptor.
- The layer-2 FFN gate output buffer is intentionally module-private until a
  later SwiGLU handoff needs to read it.
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
- `work/oracle/token0_layer2_ffn_gate_oracle.py`
- `work/oracle/token0-layer2-ffn-gate.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-2 FFN gate matvec exact-slice verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- real target runtime smoke printed retained `layer2_ffn_gate_tensor_*` metadata,
  preserved the reviewed layer-2 FFN RMSNorm exact-hex words, printed
  `token0_layer2_ffn_gate_matvec: 1`, and printed gate output words
  `0x4204511d`, `0xbfebf5bb`, `0x414216d1`, and `0x3f72ec48`
- `work/oracle/token0_layer2_ffn_gate_oracle.py` matched the runtime layer-2 FFN
  RMSNorm and gate output slices exactly after normalization of oracle labels
- temporary 24-byte empty valid GGUF kept `layer2_ffn_norm_tensor_*`,
  `layer2_ffn_gate_tensor_*`, `token0_layer2_attn_output_matvec`,
  `token0_layer2_post_attn_residual`, `token0_layer2_ffn_norm`, and
  `token0_layer2_ffn_gate_matvec` at `0` and emitted no guarded gate output
  words
- `git diff --check`
- runtime source extension scan allowing `.s` and tracked `.inc` source files
- tracked include dependency scan
- static-link/no-dynamic-section/file check
- undefined-symbol check
- exported-symbol inspection for `run_token0_layer2_ffn_gate_matvec_status` and
  `token0_layer2_ffn_gate_matvec_status`
- tracked-artifact and tracked large-file scans

## Next Exact Step

Add descriptor-only coverage for `blk.2.ffn_up.weight` in the retained
entry-side lookup chain, mirroring the layer-2 FFN gate descriptor pattern
without reading FFN up payload bytes.
