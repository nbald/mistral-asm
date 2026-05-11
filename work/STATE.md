# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish the first token-0 layer-3 post-FFN residual exact-hex slice from the
focused down module. Add external oracle coverage for
`token0_layer3_post_ffn_residual*_f32_hex`, then print the first four words
only when `token0_layer3_post_ffn_residual: 1`.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and
  linked with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups,
  and bounded tensor payload reads only inside guarded smoke paths.
- Token-0 layer-3 smoke coverage now publishes guarded slices through the FFN
  down projection and derives a status-only post-FFN residual. Current public
  layer-3 FFN slices are:
  - FFN RMSNorm: `0x422e5251`, `0xc01a339f`, `0xbffb06aa`, `0xbf19ba93`
  - FFN gate: `0xbfb2e5c3`, `0xbec7c2ba`, `0xbe4be710`, `0x3d08c33e`
  - FFN up: `0x3fd71f53`, `0xbd86d8f4`, `0xbef486a9`, `0xc026c494`
  - FFN SwiGLU: `0xbeee5aef`, `0x3c29e800`, `0x3d2f6fb9`,
    `0xbd3528b3`
  - FFN down: `0x3def4ab2`, `0x3e0b094a`, `0xbf222273`, `0xbc2b9ed5`
- Layer-3 retained descriptors currently cover attention norm/query/key/value/
  output and FFN norm/gate/up/down. On the real target,
  `blk.3.ffn_down.weight` is Q8_0 `[9216 x 3072]`, relative offset
  `832339968`, complete payload span `30081024` bytes.
- `src/infer/token0_layer3_ffn.s` owns the layer-3 FFN norm/gate/up/SwiGLU
  chain and the shared 9216-f32 SwiGLU buffer.
- `src/infer/token0_layer3_ffn_down.s` requires the guarded layer-3 FFN SwiGLU
  activation before the down matvec, bounds the complete Q8_0 down payload,
  fills private 3072-f32 down output storage, and prints the first four
  exact-hex down words only when `token0_layer3_ffn_down_matvec: 1`. It also
  requires `token0_layer3_post_attn_residual_status` and the down matvec
  status, rechecks `layer3_ffn_down_tensor_dim1 == 3072`, fills retained
  3072-f32 `token0_layer3_post_ffn_residual` storage, and prints only
  `token0_layer3_post_ffn_residual` for that status-only residual step.
- `work/oracle/token0_layer3_ffn_down_oracle.py` independently recomputes the
  full layer-3 FFN RMSNorm, gate/up projections, full 9216-word SwiGLU
  activation, and first four rows of `blk.3.ffn_down.weight`.

## Known Blockers

- Layer-3 post-FFN residual output is derived but not published as exact-hex
  words yet; add an oracle-backed slice before moving to the next layer.
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
- `work/oracle/token0_layer3_ffn_swiglu_oracle.py`
- `work/oracle/token0_layer3_ffn_down_oracle.py`
- `work/oracle/token0-layer3-ffn-swiglu.md`
- `work/oracle/token0-layer3-ffn-down.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 post-FFN residual status verification passed:

- `make all check`
- `./mistral-asm --help`
- real-target run reported `layer3_ffn_down_tensor_found: 1`,
  `layer3_ffn_down_tensor_dim1: 3072`,
  `token0_layer3_post_attn_residual: 1`,
  `token0_layer3_ffn_down_matvec: 1`, and
  `token0_layer3_post_ffn_residual: 1`
- real-target layer-3 FFN down public words remained `0x3def4ab2`,
  `0x3e0b094a`, `0xbf222273`, and `0xbc2b9ed5`; no
  `token0_layer3_post_ffn_residual*_f32_hex` labels are emitted yet
- focused runtime/oracle diff was empty for layer-3 FFN RMSNorm, FFN gate, FFN
  up, FFN SwiGLU, and FFN down public exact-hex labels
- 24-byte header-only GGUF kept the layer-3 FFN down descriptor fields at `0`,
  kept `token0_layer3_ffn_norm`, `token0_layer3_ffn_gate_matvec`,
  `token0_layer3_ffn_up_matvec`, `token0_layer3_ffn_swiglu`, and
  `token0_layer3_ffn_down_matvec` at `0`, reported
  `token0_layer3_post_ffn_residual: 0`, and emitted no guarded layer-3 FFN
  output or post-FFN residual exact-hex labels
- `make clean all check`
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- layer-3 FFN down symbol inspection
- inference source line-count check
- tracked artifact and tracked large-file scans

## Next Exact Step

Publish the first token-0 layer-3 post-FFN residual exact-hex slice from the
focused down module. Add external oracle coverage for
`token0_layer3_post_ffn_residual*_f32_hex`, then print the first four words
only when `token0_layer3_post_ffn_residual: 1`.
