# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add descriptor-only retained lookup and summary coverage for
`blk.2.ffn_down.weight`, without reading FFN-down payload bytes yet.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target GGUF parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads.
- Token-0 smoke coverage now reaches layer-2 post-attention residual, layer-2
  FFN RMSNorm activation, layer-2 FFN gate/up matvec output slices, and the
  first guarded layer-2 FFN SwiGLU activation output slice.
- `src/infer/token0_layer2_ffn.s` owns layer-2 FFN norm status/activation,
  gate/up matvec status/output storage, and private SwiGLU output storage. The
  SwiGLU path requires both layer-2 FFN gate and up matvec statuses before
  calling the shared scalar `swiglu_f32` helper over 9216 f32 values.
- The layer-2 FFN SwiGLU status now prints four guarded exact-hex output words:
  `0x450e084e`, `0xbdf8abeb`, `0xc3132ce7`, and `0x3db01261`.
- Durable external oracle coverage exists through the layer-2 FFN RMSNorm,
  gate, up, and SwiGLU slices in `work/oracle/`.
- Repository-wide, layer-1 FFN branch, and layer-2 attention branch review gates
  are complete with no blocking findings.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or
  Makefile-tracked include fragments.

## Known Blockers

- No current blocker to adding descriptor-only layer-2 FFN-down coverage.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new code
  to it before splitting or moving work into a focused module.
- `src/infer/token0_layer2_ffn.s` is 942 lines after publishing the SwiGLU
  slice. Do not add the FFN-down matvec there; use a focused module or split
  before substantial new layer-2 FFN code.
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
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-2 FFN SwiGLU output-slice verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- `python3 work/oracle/token0_layer2_ffn_swiglu_oracle.py <target-gguf>`
- real target runtime smoke printed `token0_layer2_ffn_swiglu: 1` and
  `token0_layer2_ffn_swiglu_output{0..3}_f32_hex` as `0x450e084e`,
  `0xbdf8abeb`, `0xc3132ce7`, and `0x3db01261`, matching the oracle exactly
- temporary 24-byte empty valid GGUF kept `layer2_ffn_norm_tensor_*`,
  `layer2_ffn_gate_tensor_*`, `layer2_ffn_up_tensor_*`,
  `token0_layer2_ffn_norm`, `token0_layer2_ffn_gate_matvec`,
  `token0_layer2_ffn_up_matvec`, and `token0_layer2_ffn_swiglu` at `0`, and
  emitted no guarded layer-2 FFN norm/gate/up/SwiGLU output words
- `git diff --check`
- runtime source extension scan allowing `.s` and tracked `.inc` source files
- tracked include dependency scan
- static-link/no-dynamic-section/file check
- undefined-symbol check
- exported-symbol inspection for `run_token0_layer2_ffn_swiglu_status` and
  `token0_layer2_ffn_swiglu_status`, with
  `token0_layer2_ffn_swiglu_output` remaining private
- tracked-artifact and tracked large-file scans

## Next Exact Step

Add descriptor-only retained lookup and summary coverage for
`blk.2.ffn_down.weight`, without reading FFN-down payload bytes yet.
