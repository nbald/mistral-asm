# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add status-only layer-2 FFN up matvec coverage in the focused FFN module,
publishing only `token0_layer2_ffn_up_matvec`.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target GGUF parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads.
- Token-0 smoke coverage now reaches layer-2 post-attention residual, layer-2
  FFN RMSNorm activation, and layer-2 FFN gate matvec output.
- The retained entry-side lookup chain now captures and prints
  `blk.2.ffn_up.weight` descriptor fields (`found`, dimension count, dim0,
  dim1, type, and relative offset) after the layer-2 FFN gate descriptor. This
  descriptor-only step does not read FFN up payload bytes.
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

- No current blocker to adding status-only layer-2 FFN up matvec coverage.
- The layer-2 FFN gate output buffer is intentionally module-private until a
  later SwiGLU handoff needs to read it.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new code
  to it before splitting or moving work into a focused module.
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
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-2 FFN up descriptor-only verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- real target runtime smoke printed `layer2_ffn_up_tensor_found: 1`, dimensions
  `2`, dim0 `3072`, dim1 `9216`, type `8`, and relative offset `768823296`,
  while preserving the reviewed layer-2 FFN RMSNorm exact-hex words and gate
  output words `0x4204511d`, `0xbfebf5bb`, `0x414216d1`, and `0x3f72ec48`
- temporary 24-byte empty valid GGUF kept `layer2_ffn_norm_tensor_*`,
  `layer2_ffn_gate_tensor_*`, `layer2_ffn_up_tensor_*`,
  `token0_layer2_attn_output_matvec`, `token0_layer2_post_attn_residual`,
  `token0_layer2_ffn_norm`, and `token0_layer2_ffn_gate_matvec` at `0`
- `git diff --check`
- runtime source extension scan allowing `.s` and tracked `.inc` source files
- tracked include dependency scan
- static-link/no-dynamic-section/file check
- undefined-symbol check
- exported-symbol inspection for the retained layer-2 FFN norm/gate/up
  descriptor symbols and current layer-2 FFN gate status symbols
- tracked-artifact and tracked large-file scans

## Next Exact Step

Add status-only layer-2 FFN up matvec coverage in `src/infer/token0_layer2_ffn.s`,
mirroring the gate matvec guards with `layer2_ffn_up_tensor_*`, writing a private
9216-f32 output buffer, and publishing only `token0_layer2_ffn_up_matvec`.
