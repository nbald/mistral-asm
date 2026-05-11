# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish a guarded token-0 layer-3 FFN SwiGLU activation slice with an external
oracle, while keeping the existing status gate and the 24-byte empty GGUF
silent.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and
  linked with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups,
  and bounded tensor payload reads only inside guarded smoke paths.
- Token-0 smoke coverage now publishes guarded layer-3 slices through FFN up
  and a status-only layer-3 FFN SwiGLU activation. The current public layer-3
  slices are:
  - attention output: `0x3ce80ee7`, `0x3da84154`, `0xbd1e4c02`,
    `0xbd11752d`
  - post-attention residual: `0x440c1f18`, `0xc20054b6`, `0xc2a825d4`,
    `0xc15e3502`
  - FFN RMSNorm: `0x422e5251`, `0xc01a339f`, `0xbffb06aa`, `0xbf19ba93`
  - FFN gate: `0xbfb2e5c3`, `0xbec7c2ba`, `0xbe4be710`, `0x3d08c33e`
  - FFN up: `0x3fd71f53`, `0xbd86d8f4`, `0xbef486a9`, `0xc026c494`
  - FFN SwiGLU: status `1` only; no output exact-hex labels are emitted yet.
- Layer-3 retained descriptors currently cover attention norm/query/key/value/
  output and FFN norm/gate/up. On the real target:
  - `blk.3.ffn_gate.weight` is Q8_0 `[3072 x 9216]`, relative offset
    `862420992`, complete payload span `30081024` bytes.
  - `blk.3.ffn_up.weight` is Q8_0 `[3072 x 9216]`, relative offset
    `892514304`, complete payload span `30081024` bytes.
- `src/infer/token0_layer3_ffn.s` requires `token0_layer3_ffn_norm: 1` before
  both gate and up projections, rechecks each retained descriptor shape/type,
  bounds the complete Q8_0 payload against the live mapping, fills private
  9216-f32 output storage, and prints the first four exact-hex words only when
  the corresponding matvec status is `1`.
- `src/infer/token0_layer3_ffn.s` now requires both
  `token0_layer3_ffn_gate_matvec: 1` and `token0_layer3_ffn_up_matvec: 1`
  before running the shared scalar `swiglu_f32` helper over the private
  9216-f32 gate/up buffers into private 9216-f32 activation storage. The
  runtime publishes `token0_layer3_ffn_swiglu: 1` only; no activation slice is
  printed yet.
- `work/oracle/token0_layer3_ffn_up_oracle.py` independently reuses the full
  layer-3 FFN RMSNorm oracle chain, dots the first four rows of
  `blk.3.ffn_up.weight`, and matches the new runtime up slice exactly.

## Known Blockers

- Layer-3 FFN down descriptor is not retained yet; add it only when a focused
  down-projection smoke needs it.
- Keep layer-3 FFN work in focused layer-3 files. Do not grow the near-limit
  layer-2 modules for layer-3 work.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new
  code to it before splitting or moving work into a focused module.
- `src/infer/token0_layer2_ffn.s` is 943 lines. Do not add substantial new code
  there before splitting or moving work into a focused module.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/constants.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer3_cli_requests.inc`
- `src/entry/start/rodata/layer3_summary_labels.inc`
- `src/entry/start/state/layer3_globals.inc`
- `src/entry/start/state/layer3_bss.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer3.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/entry/start/lookup_summary/layer3.inc`
- `src/infer/token0_layer3_ffn.s`
- `work/oracle/token0_layer3_ffn_gate_oracle.py`
- `work/oracle/token0-layer3-ffn-gate.md`
- `work/oracle/token0_layer3_ffn_up_oracle.py`
- `work/oracle/token0-layer3-ffn-up.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 FFN SwiGLU status-only smoke verification passed:

- `make clean all check`
- `./mistral-asm --help`
- real-target run reported `token0_layer3_ffn_norm: 1`,
  `token0_layer3_ffn_gate_matvec: 1`,
  `token0_layer3_ffn_up_matvec: 1`, and the new
  `token0_layer3_ffn_swiglu: 1` status
- real-target `^token0_layer3_ffn_swiglu` filter emitted only
  `token0_layer3_ffn_swiglu: 1`, with no activation output labels
- focused runtime/oracle diffs were empty for the layer-3 attention output,
  post-attention residual, FFN RMSNorm, FFN gate, and FFN up public labels
- 24-byte header-only GGUF kept layer-3 FFN gate/up descriptor fields and
  `token0_layer3_attn_output_matvec`, `token0_layer3_post_attn_residual`,
  `token0_layer3_ffn_norm`, `token0_layer3_ffn_gate_matvec`, and
  `token0_layer3_ffn_up_matvec` at `0`; it also kept
  `token0_layer3_ffn_swiglu` at `0` and emitted no guarded layer-3 FFN
  gate/up/SwiGLU output labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- layer-3 FFN SwiGLU symbol inspection
- inference source line-count check
- tracked artifact and tracked large-file scans

## Next Exact Step

Publish a guarded token-0 layer-3 FFN SwiGLU activation slice with an external
oracle, while keeping the existing status gate and the 24-byte empty GGUF
silent.
