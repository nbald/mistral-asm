# Layer-1 FFN Branch Review 2 - 2026-05-11

Scope: second consecutive review-gate pass over the completed token-0 layer-1
FFN branch before allowing layer-2 feature work.

## Findings

- No blocking findings in this pass.

## Notes

- The reviewed branch still runs entirely before `gguf_release_mapping`, so the
  RMSNorm and Q8_0 matvec smoke paths borrow live mmap payload pointers only
  while the mapping is owned by `_start`
  (`src/entry/start/main/smoke_orchestration.inc:396`,
  `src/entry/start/main/smoke_orchestration.inc:402`,
  `src/entry/start/main/smoke_orchestration.inc:406`).
- The gate, up, and down matvec smokes independently require the prerequisite
  status, exact Q8_0 type, exact two-dimensional shape, non-negative tensor-data
  and tensor-relative offsets, overflow-free offset addition, and a complete
  matrix payload span inside the mapping before calling `q8_0_matvec_f32`
  (`src/infer/token0_layer1_ffn.s:484`,
  `src/infer/token0_layer1_ffn.s:697`,
  `src/infer/token0_layer1_ffn_down.s:399`).
- The pure retained-buffer steps have the right dependency surface: SwiGLU waits
  for both gate and up statuses before reading module-owned buffers, and
  post-FFN residual waits for the layer-1 post-attention residual plus down
  matvec statuses before publishing the next residual
  (`src/infer/token0_layer1_ffn.s:907`,
  `src/infer/token0_layer1_ffn_down.s:345`).
- Public output ordering matches the oracle note: post-attention residual, FFN
  norm, gate, up, SwiGLU, down, then post-FFN residual. The exact oracle note
  documents the same chain and scalar f32 rounding for the residual add
  (`work/oracle/token0-layer1-post-ffn-residual.md:22`,
  `work/oracle/token0-layer1-post-ffn-residual.md:30`).
- The reviewed feature modules remain below the project split threshold:
  `src/infer/token0_layer1_ffn.s` is 929 lines and
  `src/infer/token0_layer1_ffn_down.s` is 468 lines. New layer-2 work should
  avoid pushing `token0_layer1_ffn.s` past 1000 lines and should start in focused
  modules or smaller entry fragments when practical.

## Verification

- `make`
- `make check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime smoke showed the layer-1 FFN gate/up/down descriptors
  present with expected shapes and Q8_0 type, and the public layer-1
  post-attention residual, FFN norm, gate/up/SwiGLU/down, and post-FFN residual
  words matched the documented oracle values.
- `python3 work/oracle/token0_layer1_post_ffn_residual_oracle.py <local target>`
  reproduced all reviewed public layer-1 branch words exactly.
- A temporary 24-byte empty valid GGUF kept layer-1 FFN gate/up/down descriptor
  found flags and all reviewed layer-1 FFN branch statuses at `0`, with no
  guarded layer-1 FFN output word labels.
