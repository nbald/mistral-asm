# Layer-3 Attention Chain Review 2 - 2026-05-11

Scope: second review-gate pass over the completed token-0 layer-3 attention
chain through the guarded output-projection slice before layer-3
post-attention residual or FFN work resumes.

## Findings

- No blocking findings in this pass.
- No source changes were required. The layer-3 chain remains narrow,
  status-gated, and one-token-specific.

## Notes

- The runtime still preserves the reviewed execution order: layer-2 post-FFN
  residual, layer-3 attention RMSNorm, Q/K/V projections, single-token context
  expansion, and layer-3 attention output projection all execute before the
  GGUF mapping is released (`src/entry/start/main/smoke_orchestration.inc:415`,
  `src/entry/start/main/smoke_orchestration.inc:421`,
  `src/entry/start/main/smoke_orchestration.inc:423`).
- Descriptor ownership is explicit. Layer-3 attention norm, Q, K, V, and
  output projection descriptors are retained in focused static slots, and the
  summary printers read those retained fields without dereferencing mapped
  payload bytes (`src/entry/start/main/bootstrap/layer3.inc:1`,
  `src/entry/start/state/layer3_bss.inc:1`,
  `src/entry/start/lookup_summary/layer3.inc:1`).
- Every layer-3 payload consumer fails closed before calling math helpers:
  prerequisite status checks, found/type/shape checks, non-negative offsets,
  overflow-checked absolute offsets, complete mapping-span checks, and non-null
  mmap bases are in place for RMSNorm and the Q/K/V/output Q8_0 matvecs
  (`src/infer/token0_layer3_attn.s:285`,
  `src/infer/token0_layer3_attn.s:368`,
  `src/infer/token0_layer3_attn.s:460`,
  `src/infer/token0_layer3_attn.s:552`,
  `src/infer/token0_layer3_attn_output.s:118`).
- The context stage remains deliberately limited to token 0. It requires Q/K/V
  matvec statuses and retained descriptor shapes, then repeats each 128-f32
  value-head block into its four query heads; it does not implement or claim
  multi-token score, mask, or softmax behavior
  (`src/infer/token0_layer3_attn_context.s:119`,
  `src/infer/token0_layer3_attn_context.s:172`).
- Public exact-hex labels for the reviewed chain are status-gated. Synthetic
  empty GGUF input leaves descriptor found flags and dependent statuses at 0
  and emits no guarded layer-3 exact-hex labels.
- Split discipline remains acceptable for the next feature step. The current
  layer-3 attention files are below the project threshold, and the only
  layer-3 `.include` fragment is listed in the Makefile dependency graph
  (`Makefile:19`, `Makefile:20`, `Makefile:21`, `Makefile:104`,
  `Makefile:182`).

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- Post-documentation `make all check` passed with the same harness results.
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime/oracle comparison for layer-2 post-FFN residual, layer-3
  attention RMSNorm, layer-3 value, layer-3 context, and layer-3 output
  exact-hex labels was empty.
- Real target smoke reported all reviewed layer-3 descriptors and statuses at
  `1`; `blk.3.attn_output.weight` reported dimensions `4096x3072`, type `8`,
  and relative offset `802258944`.
- A temporary 24-byte empty valid GGUF kept all reviewed layer-3 descriptor
  found flags and dependent statuses at `0`, and emitted no guarded layer-3
  exact-hex labels.
- Runtime source extension scan allowed only tracked `.s` and `.inc` files
  under `src/`.
- Tracked include dependency scan covered `.include` fragments in `Makefile`.
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, and `nm -u ./mistral-asm`
  confirmed a static executable with no dynamic section and no undefined
  symbols.
- Exported-symbol inspection covered the reviewed layer-3 runner entry points,
  statuses, and retained handoff buffers.
- Source line-count check passed, with the known tensor-directory walker
  exception unchanged.
- Tracked artifact and tracked large-file scans passed.

## Residual Risk

- This pass does not prove multi-token attention scoring, masking, or softmax.
  The current context stage is valid only for the one-token smoke path.
- The next implementation step should add the layer-3 post-attention residual
  as a focused smoke step before any layer-3 FFN work.
