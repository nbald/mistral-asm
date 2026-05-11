# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish the first guarded layer-2 FFN-down output slice from the focused down
module and add durable external oracle coverage for the exact four f32 words.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target GGUF parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads.
- Token-0 smoke coverage now reaches layer-2 post-attention residual, layer-2
  FFN RMSNorm activation, layer-2 FFN gate/up matvec output slices, the first
  guarded layer-2 FFN SwiGLU activation output slice, and status-only layer-2
  FFN-down matvec coverage.
- Descriptor-only retained lookup and summary coverage now includes
  `blk.2.ffn_down.weight`. The real target reports found `1`, dimensions `2`,
  dim0 `9216`, dim1 `3072`, type `8`, and relative offset `708648960`.
- `src/infer/token0_layer2_ffn.s` owns layer-2 FFN norm status/activation,
  gate/up matvec status/output storage, and module-owned SwiGLU output storage.
  The SwiGLU path requires both layer-2 FFN gate and up matvec statuses before
  calling the shared scalar `swiglu_f32` helper over 9216 f32 values.
- `src/infer/token0_layer2_ffn_down.s` owns the layer-2 FFN-down status smoke
  and private down output storage. It consumes the layer-2 SwiGLU status/buffer,
  rechecks the retained `blk.2.ffn_down.weight` Q8_0 `[9216 x 3072]`
  descriptor, proves the full mapped payload span, runs `q8_0_matvec_f32`, and
  publishes only `token0_layer2_ffn_down_matvec`.
- The layer-2 FFN SwiGLU status now prints four guarded exact-hex output words:
  `0x450e084e`, `0xbdf8abeb`, `0xc3132ce7`, and `0x3db01261`.
- The layer-2 FFN-down output buffer is filled on the real target when the
  status is `1`, but no layer-2 FFN-down exact-hex output labels or slice
  printer exist yet.
- Durable external oracle coverage exists through the layer-2 FFN RMSNorm,
  gate, up, and SwiGLU slices in `work/oracle/`.
- Repository-wide, layer-1 FFN branch, and layer-2 attention branch review gates
  are complete with no blocking findings.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or
  Makefile-tracked include fragments.

## Known Blockers

- No current blocker to publishing the focused layer-2 FFN-down output slice.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new code
  to it before splitting or moving work into a focused module.
- `src/infer/token0_layer2_ffn.s` is 943 lines after publishing the SwiGLU
  slice. Do not add the FFN-down matvec there; use a focused module or split
  before substantial new layer-2 FFN code.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `src/infer/token0_layer2_ffn.s`
- `src/infer/token0_layer2_ffn_down.s`
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

Layer-2 FFN-down status-only verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- real target runtime smoke printed `layer2_ffn_down_tensor_found: 1`,
  `layer2_ffn_down_tensor_n_dimensions: 2`, `layer2_ffn_down_tensor_dim0: 9216`,
  `layer2_ffn_down_tensor_dim1: 3072`, `layer2_ffn_down_tensor_ggml_type: 8`,
  `layer2_ffn_down_tensor_offset: 708648960`, and
  `token0_layer2_ffn_down_matvec: 1`, while preserving the reviewed layer-2 FFN
  norm/gate/up/SwiGLU status and exact-hex output slices
- temporary 24-byte empty valid GGUF kept `layer2_ffn_norm_tensor_*`,
  `layer2_ffn_gate_tensor_*`, `layer2_ffn_up_tensor_*`,
  `layer2_ffn_down_tensor_*`,
  `token0_layer2_ffn_norm`, `token0_layer2_ffn_gate_matvec`,
  `token0_layer2_ffn_up_matvec`, and `token0_layer2_ffn_swiglu` at `0`, and
  `token0_layer2_ffn_down_matvec` at `0`; emitted no guarded layer-2 FFN
  norm/gate/up/SwiGLU/down output words
- `git diff --check`
- runtime source extension scan allowing `.s` and tracked `.inc` source files
- tracked include dependency scan
- static-link/no-dynamic-section/file check
- undefined-symbol check
- exported-symbol inspection for `run_token0_layer2_ffn_down_matvec_status`,
  `token0_layer2_ffn_down_matvec_status`, and the layer-2 SwiGLU handoff buffer
- targeted scan confirmed no layer-2 FFN-down output slice labels or printer
  exist yet
- tracked-artifact and tracked large-file scans

## Next Exact Step

Publish the first guarded layer-2 FFN-down output slice from the focused down
module and add durable external oracle coverage for the exact four f32 words.
