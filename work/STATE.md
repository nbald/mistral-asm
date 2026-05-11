# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish the first guarded token-0 layer-3 FFN down projection output slice from
the focused down module, add an external oracle/note for the first four rows,
and keep the 24-byte empty GGUF silent.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and
  linked with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups,
  and bounded tensor payload reads only inside guarded smoke paths.
- Token-0 smoke coverage now publishes guarded layer-3 slices through the FFN
  SwiGLU activation and adds a status-only layer-3 FFN down projection gate.
  The current public layer-3 FFN slices are:
  - FFN RMSNorm: `0x422e5251`, `0xc01a339f`, `0xbffb06aa`, `0xbf19ba93`
  - FFN gate: `0xbfb2e5c3`, `0xbec7c2ba`, `0xbe4be710`, `0x3d08c33e`
  - FFN up: `0x3fd71f53`, `0xbd86d8f4`, `0xbef486a9`, `0xc026c494`
  - FFN SwiGLU: `0xbeee5aef`, `0x3c29e800`, `0x3d2f6fb9`,
    `0xbd3528b3`
- Layer-3 retained descriptors currently cover attention norm/query/key/value/
  output and FFN norm/gate/up/down. On the real target:
  - `blk.3.ffn_gate.weight` is Q8_0 `[3072 x 9216]`, relative offset
    `862420992`, complete payload span `30081024` bytes.
  - `blk.3.ffn_up.weight` is Q8_0 `[3072 x 9216]`, relative offset
    `892514304`, complete payload span `30081024` bytes.
  - `blk.3.ffn_down.weight` is Q8_0 `[9216 x 3072]`, relative offset
    `832339968`, complete payload span `30081024` bytes.
- `src/infer/token0_layer3_ffn.s` requires the guarded layer-3 FFN RMSNorm
  before gate/up matvecs, bounds the complete Q8_0 payloads, fills private
  9216-f32 gate/up buffers, requires both projection statuses before SwiGLU,
  and prints the first four exact-hex SwiGLU activation words only when
  `token0_layer3_ffn_swiglu: 1`.
- `src/infer/token0_layer3_ffn_down.s` requires the guarded layer-3 FFN SwiGLU
  activation before the down matvec, bounds the complete Q8_0 down payload,
  fills a private 3072-f32 down output buffer, and currently prints only
  `token0_layer3_ffn_down_matvec`.
- `work/oracle/token0_layer3_ffn_swiglu_oracle.py` independently reuses the
  full layer-3 FFN RMSNorm oracle chain plus the focused gate/up loaders, then
  applies the shared scalar SwiGLU formula to verify the activation slice.

## Known Blockers

- Layer-3 FFN down output words are not published yet; the next step needs an
  external oracle before exposing the first exact-hex slice.
- `src/infer/token0_layer3_ffn.s` is 942 lines. Do not add substantial down
  projection code there; keep layer-3 down work in the focused module.
- `src/infer/token0_layer2_attn.s` is 997 lines and
  `src/infer/token0_layer2_ffn.s` is 943 lines. Do not add substantial new code
  to them before splitting or moving work into focused modules.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer3_cli_requests.inc`
- `src/entry/start/rodata/layer3_summary_labels.inc`
- `src/entry/start/state/layer3_globals.inc`
- `src/entry/start/state/layer3_bss.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer3.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/lookup_summary/layer3.inc`
- `src/infer/token0_layer3_ffn.s`
- `src/infer/token0_layer3_ffn_down.s`
- `work/oracle/token0_layer3_ffn_gate_oracle.py`
- `work/oracle/token0_layer3_ffn_up_oracle.py`
- `work/oracle/token0_layer3_ffn_swiglu_oracle.py`
- `work/oracle/token0-layer3-ffn-gate.md`
- `work/oracle/token0-layer3-ffn-up.md`
- `work/oracle/token0-layer3-ffn-swiglu.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 FFN down status-only verification passed:

- `make all check`
- `./mistral-asm --help`
- real-target run reported `layer3_ffn_down_tensor_found: 1`, dimensions
  `9216 x 3072`, type `8`, relative offset `832339968`, and
  `token0_layer3_ffn_down_matvec: 1`
- real-target layer-3 FFN norm/gate/up/SwiGLU public words remained unchanged,
  ending with SwiGLU words `0xbeee5aef`, `0x3c29e800`, `0x3d2f6fb9`, and
  `0xbd3528b3`
- focused runtime/oracle diff was empty for layer-3 attention output,
  post-attention residual, FFN RMSNorm, FFN gate, FFN up, and FFN SwiGLU
  public exact-hex labels
- 24-byte header-only GGUF kept the new layer-3 FFN down descriptor fields at
  `0`, kept `token0_layer3_ffn_norm`, `token0_layer3_ffn_gate_matvec`,
  `token0_layer3_ffn_up_matvec`, `token0_layer3_ffn_swiglu`, and
  `token0_layer3_ffn_down_matvec` at `0`, and emitted no guarded layer-3 FFN
  gate/up/SwiGLU/down output labels
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

Publish the first guarded token-0 layer-3 FFN down projection output slice from
the focused down module, add an external oracle/note for the first four rows,
and keep the 24-byte empty GGUF silent.
