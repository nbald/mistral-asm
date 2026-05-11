# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish the first guarded token-0 layer-3 FFN up exact-hex slice and add a
focused external oracle for `blk.3.ffn_up.weight`. Reuse the existing
status-only `token0_layer3_ffn_up_matvec: 1` gate, print only the first four
up output f32 words on success, and keep the 24-byte empty GGUF silent.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and
  linked with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups,
  and bounded tensor payload reads only inside guarded smoke paths.
- Token-0 smoke coverage now publishes guarded layer-3 slices through FFN gate.
  The current public layer-3 slices are:
  - attention output: `0x3ce80ee7`, `0x3da84154`, `0xbd1e4c02`,
    `0xbd11752d`
  - post-attention residual: `0x440c1f18`, `0xc20054b6`, `0xc2a825d4`,
    `0xc15e3502`
  - FFN RMSNorm: `0x422e5251`, `0xc01a339f`, `0xbffb06aa`, `0xbf19ba93`
  - FFN gate: `0xbfb2e5c3`, `0xbec7c2ba`, `0xbe4be710`, `0x3d08c33e`
- Layer-3 retained descriptors currently cover attention norm/query/key/value/
  output and FFN norm/gate/up. On the real target:
  - `blk.3.ffn_gate.weight` is Q8_0 `[3072 x 9216]`, relative offset
    `862420992`, complete payload span `30081024` bytes.
  - `blk.3.ffn_up.weight` is Q8_0 `[3072 x 9216]`, relative offset
    `892514304`, complete payload span `30081024` bytes.
- `src/infer/token0_layer3_ffn.s` requires `token0_layer3_ffn_norm: 1` before
  both gate and up projections, rechecks the retained descriptor shape/type,
  bounds the complete Q8_0 payload against the live mapping, and fills private
  9216-f32 output storage. Gate currently prints the first four exact-hex words;
  up currently publishes only `token0_layer3_ffn_up_matvec` status.

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
- `src/entry/start/main/bootstrap/layer3.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/entry/start/lookup_summary/layer3.inc`
- `src/infer/token0_layer3_ffn.s`
- `work/oracle/token0_layer3_ffn_gate_oracle.py`
- `work/oracle/token0-layer3-ffn-gate.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 FFN up status-only verification passed:

- `make clean all check`
- `./mistral-asm --help`
- real-target run reported `layer3_ffn_up_tensor_found: 1`, dimensions
  `3072 x 9216`, type `8`, offset `892514304`,
  `token0_layer3_ffn_norm: 1`, and `token0_layer3_ffn_up_matvec: 1`
- real-target output emitted no `token0_layer3_ffn_up_output*_f32_hex` labels
- focused runtime/oracle diff was empty for layer-3 attention output,
  post-attention residual, FFN RMSNorm, and FFN gate public labels
- 24-byte header-only GGUF kept layer-3 FFN gate/up descriptor fields and
  `token0_layer3_attn_output_matvec`, `token0_layer3_post_attn_residual`,
  `token0_layer3_ffn_norm`, `token0_layer3_ffn_gate_matvec`, and
  `token0_layer3_ffn_up_matvec` at `0`, and emitted no guarded layer-3 FFN
  gate/up output labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- layer-3 FFN up symbol inspection
- inference source line-count check
- tracked artifact and tracked large-file scans

## Next Exact Step

Publish the first guarded token-0 layer-3 FFN up exact-hex slice and add a
focused external oracle for `blk.3.ffn_up.weight`. Reuse the existing
status-only `token0_layer3_ffn_up_matvec: 1` gate, print only the first four
up output f32 words on success, and keep the 24-byte empty GGUF silent.
