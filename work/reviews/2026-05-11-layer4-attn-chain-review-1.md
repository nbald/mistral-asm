# Layer-4 Attention Chain Review 1 - 2026-05-11

Scope: first review-gate pass over the completed token-0 layer-4 attention
chain through the guarded output-projection slice before any layer-4
post-attention residual or FFN work is added.

## Findings

- No blocking findings in this pass.
- No source changes were required. The reviewed chain remains status-gated,
  mapping-lifetime-bound, and split so public slice printing lives outside the
  near-threshold layer-4 attention `.s` file.

## Notes

- Runtime orchestration preserves the reviewed dependency order inside the live
  mmap lifetime: layer-3 post-FFN residual, layer-4 attention RMSNorm, Q/K/V
  projections, single-token context, and output projection all run before
  `gguf_release_mapping` (`src/entry/start/main/smoke_orchestration.inc:428`,
  `src/entry/start/main/smoke_orchestration.inc:429`,
  `src/entry/start/main/smoke_orchestration.inc:434`,
  `src/entry/start/main/smoke_orchestration.inc:438`).
- Descriptor capture remains payload-free. The layer-4 bootstrap only retains
  tensor-directory metadata for attention norm, query, key, value, and output
  projection tensors; payload readers are the later guarded smoke functions
  (`src/entry/start/main/bootstrap/layer4.inc:1`,
  `src/entry/start/main/bootstrap/layer4.inc:22`,
  `src/entry/start/main/bootstrap/layer4.inc:44`,
  `src/entry/start/main/bootstrap/layer4.inc:65`,
  `src/entry/start/main/bootstrap/layer4.inc:86`).
- Payload-consuming smokes fail closed before calling math helpers. The RMSNorm
  and Q8_0 matvec paths require prerequisite statuses, found/type/shape checks,
  non-negative tensor-data and tensor-relative offsets, overflow-checked
  absolute offsets, complete payload spans inside the mapping, and non-null mmap
  bases (`src/infer/token0_layer4_attn.s:410`,
  `src/infer/token0_layer4_attn.s:428`,
  `src/infer/token0_layer4_attn.s:493`,
  `src/infer/token0_layer4_attn.s:511`,
  `src/infer/token0_layer4_attn.s:677`,
  `src/infer/token0_layer4_attn.s:695`,
  `src/infer/token0_layer4_attn.s:875`,
  `src/infer/token0_layer4_attn.s:894`).
- The context stage is intentionally a single-token grouped-query shortcut, not
  general attention. It gates on Q/K/V statuses plus exact Q/K/V/output
  descriptor shapes, then expands each 128-f32 value head into its four query
  heads; it does not read model payload bytes (`src/infer/token0_layer4_attn.s:764`,
  `src/infer/token0_layer4_attn.s:806`,
  `src/infer/token0_layer4_attn.s:817`).
- Public exact-hex labels remain print-side status-gated. The layer-4 RMSNorm,
  query, key, value, and output-projection slice helpers emit fixed four-word
  slices only when their owning status is 1
  (`src/infer/token0_layer4_attn_slices.inc:99`,
  `src/infer/token0_layer4_attn_slices.inc:178`,
  `src/infer/token0_layer4_attn_slices.inc:257`,
  `src/infer/token0_layer4_attn_slices.inc:336`,
  `src/infer/token0_layer4_attn_slices.inc:415`).
- Oracle coverage matches the exposed arithmetic boundary for the public output
  slice. The output oracle reuses the full layer-4 RMSNorm path, computes all
  1024 value rows, expands the single-token context, then dots the first four
  `blk.4.attn_output.weight` rows with ordered scalar f32 Q8_0 accumulation
  (`work/oracle/token0_layer4_attn_output_oracle.py:90`,
  `work/oracle/token0_layer4_attn_output_oracle.py:139`,
  `work/oracle/token0_layer4_attn_output_oracle.py:145`,
  `work/oracle/token0_layer4_attn_output_oracle.py:147`,
  `work/oracle/token0_layer2_attn_output_oracle.py:72`).
- Split discipline is acceptable for this first pass, but source-size pressure
  is real. `src/infer/token0_layer4_attn.s` is 945 lines and should not absorb
  the next residual/FFN implementation; the existing slice include is listed as
  a Makefile dependency (`Makefile:103`, `Makefile:182`).

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime/oracle comparison was empty for layer-3 post-FFN
  residual, layer-4 attention RMSNorm, layer-4 value, and layer-4
  output-projection public exact-hex labels.
- Focused real target preservation comparisons were empty for the existing
  layer-4 query and key public exact-hex labels against their dedicated oracles.
- Real target smoke reported all reviewed layer-4 descriptors and statuses at
  `1`; `blk.4.attn_output.weight` still reported dimensions `4096x3072`, type
  `8`, and relative offset `925949952`.
- A temporary 24-byte empty valid GGUF kept all reviewed layer-4 descriptor
  found flags and dependent statuses at `0`, and emitted no guarded layer-4
  exact-hex labels.
- `git diff --check`
- Runtime source extension scan allowed only tracked `.s` and `.inc` files
  under `src/`.
- Tracked include dependency scan covered `.include` fragments in `Makefile`.
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, and `nm -u ./mistral-asm`
  confirmed a static executable with no dynamic section and no undefined
  symbols.
- Exported-symbol inspection covered the reviewed layer-4 attention runner
  entry points, statuses, and retained handoff buffers.
- Source line-count check passed with the known near-threshold files and
  tensor-directory walker exception unchanged.
- Tracked artifact and tracked large-file scans passed.

## Residual Risk

- This pass does not prove multi-token attention scoring, masking, or softmax;
  the current context stage remains valid only for the one-token smoke path.
- The output oracle relies on the dedicated query/key oracle comparisons for
  Q/K payload preservation because the single-token context value is independent
  of Q/K scores.
- The second review-gate pass should independently recheck the same chain before
  feature work resumes.
