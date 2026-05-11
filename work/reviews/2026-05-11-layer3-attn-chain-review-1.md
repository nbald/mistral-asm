# Layer-3 Attention Chain Review 1 - 2026-05-11

Scope: first review-gate pass over the completed token-0 layer-3 attention
chain through the guarded output-projection slice before any layer-3
post-attention residual or FFN work is added.

## Findings

- No blocking findings in this pass.
- Minor source-contract wording issue corrected during the pass:
  `run_token0_layer3_attn_q_matvec_status` now describes the guarded exact-hex
  slice it emits on success instead of saying it publishes a status line only
  (`src/infer/token0_layer3_attn.s:128`).

## Notes

- Runtime orchestration preserves the dependency order for the reviewed chain:
  layer-2 post-FFN residual, layer-3 attention RMSNorm, Q/K/V projections,
  single-token context expansion, and output projection all run before the GGUF
  mapping is released (`src/entry/start/main/smoke_orchestration.inc:415`,
  `src/entry/start/main/smoke_orchestration.inc:421`,
  `src/entry/start/main/smoke_orchestration.inc:423`).
- The layer-3 retained descriptor setup is descriptor-only until the guarded
  smoke functions consume the relevant payload. The bootstrap path looks up
  `blk.3.attn_norm.weight`, Q/K/V, and `blk.3.attn_output.weight` into focused
  retained slots and then summary printing reads only those static slots
  (`src/entry/start/main/bootstrap/layer3.inc:1`,
  `src/entry/start/main/bootstrap/layer3.inc:84`,
  `src/entry/start/main/summary_header.inc:171`).
- Payload-reading paths fail closed before calling math helpers. RMSNorm and
  every Q8_0 matvec require prerequisite status, found/type/shape checks,
  non-negative tensor-data and tensor-relative offsets, overflow-free absolute
  offset arithmetic, a complete payload span inside the mapping, and a non-null
  mmap base (`src/infer/token0_layer3_attn.s:285`,
  `src/infer/token0_layer3_attn.s:368`,
  `src/infer/token0_layer3_attn.s:460`,
  `src/infer/token0_layer3_attn.s:552`,
  `src/infer/token0_layer3_attn_output.s:118`).
- The context stage is intentionally a one-token grouped-query expansion rather
  than a general attention implementation. It gates on Q/K/V status and
  descriptor shapes, writes a 4096-f32 private context by repeating each
  128-f32 value-head block across four query heads, and uses the output
  descriptor only as a consumer shape guard
  (`src/infer/token0_layer3_attn_context.s:119`,
  `src/infer/token0_layer3_attn_context.s:172`).
- Public exact-hex slices are consistently status-gated. The layer-3 RMSNorm,
  Q/K/V, context, and output-projection print helpers emit fixed four-word
  slices only after their owning status is 1
  (`src/infer/token0_layer3_attn_slices.inc:83`,
  `src/infer/token0_layer3_attn_slices.inc:162`,
  `src/infer/token0_layer3_attn_slices.inc:241`,
  `src/infer/token0_layer3_attn_slices.inc:320`,
  `src/infer/token0_layer3_attn_context.s:222`,
  `src/infer/token0_layer3_attn_output.s:202`).
- Split discipline is acceptable for the next review pass. The layer-3 runtime
  files are below the project threshold and the single `.include` fragment is
  listed in the Makefile dependencies (`Makefile:19`, `Makefile:20`,
  `Makefile:21`, `Makefile:103`, `Makefile:182`).

## Verification

- `make clean all check` passed before the comment-only source correction, and
  `make all check` passed after it with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime/oracle comparison for layer-2 post-FFN residual, layer-3
  attention RMSNorm, layer-3 value, layer-3 context, and layer-3 output
  exact-hex labels was empty.
- Real target smoke reported all reviewed layer-3 descriptors and statuses at
  `1`; `blk.3.attn_output.weight` still reported dimensions `4096x3072`, type
  `8`, and relative offset `802258944`.
- A temporary 24-byte empty valid GGUF kept all reviewed layer-3 descriptor
  found flags and statuses at `0`, with no guarded layer-3 exact-hex labels.
- `git diff --check`
- runtime source extension scan allowing only tracked `.s` and `.inc` files
  under `src/`
- tracked include dependency scan
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, and
  `nm -u ./mistral-asm` confirmed a static executable with no dynamic section
  and no undefined symbols.
- exported-symbol inspection for the reviewed layer-3 runner entry points,
  statuses, and retained handoff buffers
- source line-count check
- tracked-artifact and tracked large-file scans

## Residual Risk

- This pass does not prove multi-token attention scoring, masking, or softmax;
  the current context stage remains valid only for the one-token smoke path.
- The second review-gate pass should independently recheck the layer-3 chain
  before feature work resumes.
