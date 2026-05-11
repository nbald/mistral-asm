# Layer-1 FFN Branch Review 1 - 2026-05-11

Scope: first review-gate pass over the completed token-0 layer-1 FFN branch,
including the new durable oracle script and note added after the previous
review blocker.

## Findings

- No blocking findings in this pass.

## Notes

- The runtime branch is ordered so that the layer-1 post-attention residual is
  published before FFN RMSNorm, then gate/up projection, SwiGLU, down
  projection, and post-FFN residual run before the mapping is released
  (`src/entry/start/main/smoke_orchestration.inc:377`,
  `src/entry/start/main/smoke_orchestration.inc:396`,
  `src/entry/start/main/smoke_orchestration.inc:402`,
  `src/entry/start/main/smoke_orchestration.inc:406`).
- The RMSNorm and Q8_0 matvec smoke gates require prerequisite statuses,
  exact target dimensions/types, non-negative offsets, overflow-free
  tensor-data-base addition, and a complete payload span inside the live mmap
  before handing pointers to math helpers
  (`src/infer/token0_layer1_ffn.s:201`,
  `src/infer/token0_layer1_ffn.s:484`,
  `src/infer/token0_layer1_ffn.s:697`,
  `src/infer/token0_layer1_ffn_down.s:399`).
- The SwiGLU and post-FFN residual steps consume only retained in-process f32
  buffers after their prerequisites have succeeded, and the post-FFN residual
  uses scalar `vaddss` over the fixed 3072-word hidden width
  (`src/infer/token0_layer1_ffn.s:907`,
  `src/infer/token0_layer1_ffn_down.s:345`).
- The down and post-FFN residual slice printers are status-gated before reading
  private output storage (`src/infer/token0_layer1_ffn_down.s:185`,
  `src/infer/token0_layer1_ffn_down.s:264`). The earlier norm/gate/up/SwiGLU
  slice printers follow the same status-gated pattern in
  `src/infer/token0_layer1_ffn.s`.
- The durable oracle now covers the whole public branch slice chain: it reuses
  the layer-1 FFN RMSNorm oracle arrays, computes all gate/up/SwiGLU rows, dots
  the requested down rows, and adds the layer-1 post-attention residual with f32
  rounding (`work/oracle/token0_layer1_post_ffn_residual_oracle.py:53`,
  `work/oracle/token0_layer1_post_ffn_residual_oracle.py:104`,
  `work/oracle/token0_layer1_post_ffn_residual_oracle.py:115`,
  `work/oracle/token0_layer1_post_ffn_residual_oracle.py:136`).
- Module size remains within the current split policy for the reviewed branch:
  `src/infer/token0_layer1_ffn.s` is 929 lines and
  `src/infer/token0_layer1_ffn_down.s` is 468 lines. The known
  `src/gguf/load_header/tensor_infos.inc` maintainability risk is unrelated to
  this branch and remains documented in state.

## Verification

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime smoke showed layer-1 FFN gate/up/SwiGLU/down statuses at
  `1`, post-FFN residual status at `1`, and the public branch words:
  gate `0xbe34ea97 0xbfcc8119 0xbf150238 0xbf882cef`, up
  `0x3f1797a4 0x3f80ec8f 0xbe651441 0x3f2943b9`, SwiGLU
  `0xbd436233 0xbe8aab8b 0x3d3f2f78 0xbe38ceee`, down
  `0x3babc025 0x3db2eb07 0xbeba3568 0x3df45039`, and post-FFN residual
  `0xbd2addbf 0xbef2bcaa 0x4003aae1 0xbddfb01f`.
- `python3 work/oracle/token0_layer1_post_ffn_residual_oracle.py <local target>`
  reproduced the runtime layer-1 post-attention residual, FFN norm,
  gate/up/SwiGLU/down, and post-FFN residual public words exactly.
- A temporary 24-byte empty valid GGUF kept `layer1_ffn_gate_tensor_found`,
  `layer1_ffn_up_tensor_found`, `layer1_ffn_down_tensor_found`,
  `token0_layer1_ffn_norm`, `token0_layer1_ffn_gate_matvec`,
  `token0_layer1_ffn_up_matvec`, `token0_layer1_ffn_swiglu`,
  `token0_layer1_ffn_down_matvec`, and `token0_layer1_post_ffn_residual` at
  `0`, with no guarded layer-1 FFN output word labels.
- `git diff --check`, runtime source extension scan, static-link/no-dynamic
  section check, undefined-symbol check, exported-symbol inspection,
  tracked-artifact scan, and tracked large-file scan.
