# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Add a focused token-0 layer-3 post-attention residual smoke that requires
`token0_layer3_attn_output_matvec: 1`, adds the layer-3 attention output to the
layer-2 post-FFN residual, publishes a status, and emits the first four guarded
exact-hex residual words.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads only inside guarded smoke paths.
- Token-0 smoke coverage reaches the complete layer-2 FFN branch through the
  post-FFN residual. The layer-2 post-FFN residual words remain `0x440c1d48`,
  `0xc200a8d7`, `0xc2a8120a`, and `0xc15da38d`.
- Layer-3 attention coverage now includes retained descriptor lookup, RMSNorm,
  Q/K/V matvecs, single-token grouped-query context expansion, and guarded
  output-projection matvec words for `blk.3.attn_output.weight`.
- On the real target, the layer-3 output projection descriptor is found with
  dimensions `4096x3072`, type `8`, and relative offset `802258944`.
- The layer-3 context words are `0x3a75acca`, `0x3baaa296`, `0xbbde3580`, and
  `0x3bcdaf05`; for the first query head of a single-token sequence they match
  the first four layer-3 value output words.
- Added `src/infer/token0_layer3_attn_output.s`. It requires
  `token0_layer3_attn_context: 1`, rechecks the retained
  `blk.3.attn_output.weight` shape/type, bounds the complete Q8_0 matrix
  payload against the live mapping, and fills private 3072-f32 output storage.
- Published the first guarded layer-3 attention output-projection words:
  `0x3ce80ee7`, `0x3da84154`, `0xbd1e4c02`, and `0xbd11752d`.
- Added the focused external oracle script and note for the layer-3 attention
  output projection; the runtime/oracle diff is empty for the layer-2 post-FFN
  residual, layer-3 RMSNorm, layer-3 value, layer-3 context, and new layer-3
  output public labels.
- Review gate pass 1 for the completed layer-3 attention chain found no
  blocking issues. It corrected one stale layer-3 query runner contract phrase
  and recorded the current residual risk that context expansion is only a
  one-token grouped-query smoke, not proof of multi-token attention
  score/mask/softmax behavior.
- Review gate pass 2 for the completed layer-3 attention chain found no
  blocking issues and made no source changes. The two-pass review gate is now
  complete; feature work may resume with layer-3 post-attention residual.

## Known Blockers

- No functional blocker to the layer-3 post-attention residual step.
- Keep layer-3 output-projection work in
  `src/infer/token0_layer3_attn_output.s`.
- Existing layer-3 attention RMSNorm/query/key/value slice labels and printer
  code live in `src/infer/token0_layer3_attn_slices.inc`; it is tracked in
  `Makefile` so edits rebuild `build/infer/token0_layer3_attn.o`.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new code
  to it before splitting or moving work into a focused module.
- `src/infer/token0_layer2_ffn.s` is 943 lines. Do not add substantial new code
  there before splitting or moving work into a focused module.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/infer/token0_layer3_attn.s`
- `src/infer/token0_layer3_attn_context.s`
- `src/infer/token0_layer3_attn_output.s`
- `src/infer/token0_layer3_attn_slices.inc`
- `work/oracle/token0_layer3_attn_context_oracle.py`
- `work/oracle/token0-layer3-attn-context.md`
- `work/oracle/token0_layer3_attn_output_oracle.py`
- `work/oracle/token0-layer3-attn-output.md`
- `work/reviews/2026-05-11-layer3-attn-chain-review-1.md`
- `work/reviews/2026-05-11-layer3-attn-chain-review-2.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 attention review-gate pass 2 verification passed:

- `make clean all check`
- post-documentation `make all check`
- `./mistral-asm --help`
- real-target run reported all reviewed layer-3 descriptor found flags and
  statuses at `1`, including `token0_layer3_attn_output_matvec: 1`
- focused runtime/oracle diff was empty for the layer-2 post-FFN residual,
  layer-3 attention RMSNorm, layer-3 value, layer-3 context, and layer-3
  output public labels
- temporary 24-byte empty valid GGUF reported all reviewed layer-3 descriptor
  found flags and statuses at `0` and emitted no guarded layer-3 exact-hex
  labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- include dependency scan covering `.include` fragments in `Makefile`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- layer-3 output-projection symbol inspection
- source line-count check
- tracked artifact and tracked large-file scans

## Next Exact Step

Add a focused token-0 layer-3 post-attention residual smoke that requires
`token0_layer3_attn_output_matvec: 1`, adds the layer-3 attention output to the
layer-2 post-FFN residual, publishes a status, and emits the first four guarded
exact-hex residual words.
