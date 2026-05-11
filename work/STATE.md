# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Begin layer-4 attention scope with descriptor-only retained lookup/summary
coverage for `blk.4.attn_norm.weight` in focused Makefile-tracked layer-4 entry
fragments.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and
  linked with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups,
  and bounded tensor payload reads only inside guarded smoke paths.
- Token-0 layer-3 smoke coverage now publishes guarded slices through the
  complete post-FFN residual step. Current public layer-3 slices are:
  - post-attention residual: `0x440c1f18`, `0xc20054b6`, `0xc2a825d4`,
    `0xc15e3502`
  - FFN RMSNorm: `0x422e5251`, `0xc01a339f`, `0xbffb06aa`, `0xbf19ba93`
  - FFN gate: `0xbfb2e5c3`, `0xbec7c2ba`, `0xbe4be710`, `0x3d08c33e`
  - FFN up: `0x3fd71f53`, `0xbd86d8f4`, `0xbef486a9`, `0xc026c494`
  - FFN SwiGLU: `0xbeee5aef`, `0x3c29e800`, `0x3d2f6fb9`,
    `0xbd3528b3`
  - FFN down: `0x3def4ab2`, `0x3e0b094a`, `0xbf222273`, `0xbc2b9ed5`
  - post-FFN residual: `0x440c2692`, `0xc1ff9359`, `0xc2a96a19`,
    `0xc15e5fea`
- Layer-3 retained descriptors currently cover attention norm/query/key/value/
  output and FFN norm/gate/up/down. On the real target,
  `blk.3.ffn_down.weight` is Q8_0 `[9216 x 3072]`, relative offset
  `832339968`, complete payload span `30081024` bytes.
- `src/infer/token0_layer3_ffn.s` owns the layer-3 FFN norm/gate/up/SwiGLU
  chain and the shared 9216-f32 SwiGLU buffer.
- `src/infer/token0_layer3_ffn_down.s` owns the guarded layer-3 FFN down
  matvec output and post-FFN residual storage. It now prints the first four
  exact-hex down words only when `token0_layer3_ffn_down_matvec: 1` and the
  first four exact-hex post-FFN residual words only when
  `token0_layer3_post_ffn_residual: 1`.
- `work/oracle/token0_layer3_post_ffn_residual_oracle.py` independently checks
  the layer-3 post-FFN residual slice by reusing the full layer-3 FFN down
  oracle path and adding the layer-3 post-attention residual with scalar f32
  rounding.
- Review gate pass 1 of 2 for the token-0 layer-3 FFN/down/post-residual chain
  found no blocking issues and required no source changes.
- Review gate pass 2 of 2 for the token-0 layer-3 FFN/down/post-residual chain
  found no blocking issues and required no source changes. Feature work may
  resume in focused layer-4 files/fragments.

## Known Blockers

- No functional blocker to the layer-4 attention descriptor-only lookup step.
- `src/infer/token0_layer3_ffn.s` is 942 lines. Do not add substantial down or
  residual code there; keep layer-3 down/residual work in the focused module.
- `src/infer/token0_layer2_attn.s` is 997 lines and
  `src/infer/token0_layer2_ffn.s` is 943 lines. Do not add substantial new code
  to them before splitting or moving work into focused modules.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer3_cli_requests.inc`
- `src/entry/start/state/layer3_globals.inc`
- `src/entry/start/state/layer3_bss.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer3.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/infer/token0_layer3_post_attn_residual.s`
- `src/infer/token0_layer3_ffn.s`
- `src/infer/token0_layer3_ffn_down.s`
- `work/oracle/token0_layer3_ffn_down_oracle.py`
- `work/oracle/token0_layer3_post_ffn_residual_oracle.py`
- `work/oracle/token0-layer3-ffn-down.md`
- `work/oracle/token0-layer3-post-ffn-residual.md`
- `work/reviews/2026-05-11-layer3-ffn-chain-review-1.md`
- `work/reviews/2026-05-11-layer3-ffn-chain-review-2.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 FFN chain review pass 2 verification passed:

- `make clean all check`
- post-documentation `make all check`
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- real-target run reported all reviewed layer-3 FFN descriptors/statuses at
  `1`, including `layer3_ffn_down_tensor_dim1: 3072`
- focused runtime/oracle diff was empty for layer-3 post-attention residual,
  FFN RMSNorm, FFN gate, FFN up, FFN SwiGLU, FFN down, and post-FFN
  residual public exact-hex labels
- 24-byte header-only GGUF kept the layer-3 FFN down descriptor fields at `0`,
  kept `token0_layer3_ffn_norm`, `token0_layer3_ffn_gate_matvec`,
  `token0_layer3_ffn_up_matvec`, `token0_layer3_ffn_swiglu`,
  `token0_layer3_ffn_down_matvec`, and `token0_layer3_post_ffn_residual` at
  `0`, and emitted no guarded layer-3 FFN or post-FFN residual exact-hex labels
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- layer-3 FFN down/post-residual symbol inspection
- inference source line-count check
- tracked artifact and tracked large-file scans

## Next Exact Step

Begin layer-4 attention scope with descriptor-only retained lookup/summary
coverage for `blk.4.attn_norm.weight` in focused Makefile-tracked layer-4 entry
fragments.
