# Layer-4 Attention Chain Review 2 - 2026-05-11

Scope: second review-gate pass over the token-0 layer-4 attention chain through
the guarded output-projection slice before layer-4 post-attention residual work
resumes.

## Findings

- No blocking findings in this pass.
- No runtime source changes were required. The chain remains guarded by retained
  descriptor metadata, live-mapping bounds checks, and prerequisite statuses.

## Notes

- The layer-4 attention smokes still run before `gguf_release_mapping`, so all
  payload readers borrow the mmap only while `_start` owns it
  (`src/entry/start/main/smoke_orchestration.inc:429`,
  `src/entry/start/main/smoke_orchestration.inc:434`,
  `src/entry/start/main/smoke_orchestration.inc:438`).
- Layer-4 bootstrap remains descriptor-only for attention norm, query, key,
  value, and output projection. It calls `gguf_lookup_tensor_info` into retained
  slots and does not inspect payload bytes
  (`src/entry/start/main/bootstrap/layer4.inc:1`,
  `src/entry/start/main/bootstrap/layer4.inc:22`,
  `src/entry/start/main/bootstrap/layer4.inc:44`,
  `src/entry/start/main/bootstrap/layer4.inc:65`,
  `src/entry/start/main/bootstrap/layer4.inc:86`).
- Payload-consuming stages fail closed before math helpers. RMSNorm, Q/K/V, and
  output projection all check prerequisite statuses, exact target type/shape,
  non-negative tensor-data and tensor-relative offsets, overflow on absolute
  offsets, complete span availability inside the mmap, and non-null mapping base
  before calling `rmsnorm_f32` or `q8_0_matvec_f32`
  (`src/infer/token0_layer4_attn.s:410`,
  `src/infer/token0_layer4_attn.s:493`,
  `src/infer/token0_layer4_attn.s:585`,
  `src/infer/token0_layer4_attn.s:677`,
  `src/infer/token0_layer4_attn.s:875`).
- The context stage is still explicitly single-token only. It requires Q/K/V
  success plus exact Q/K/V/output descriptor shapes, then repeats each 128-f32
  value head into the four associated query heads. It reads no model payload
  bytes and does not pretend to cover multi-token score/mask/softmax attention
  (`src/infer/token0_layer4_attn.s:764`,
  `src/infer/token0_layer4_attn.s:806`,
  `src/infer/token0_layer4_attn.s:817`).
- Public slice printing remains status-gated. The layer-4 RMSNorm, query, key,
  value, and output-projection helpers emit their four fixed exact-hex words
  only after the owning status is 1
  (`src/infer/token0_layer4_attn_slices.inc:99`,
  `src/infer/token0_layer4_attn_slices.inc:178`,
  `src/infer/token0_layer4_attn_slices.inc:257`,
  `src/infer/token0_layer4_attn_slices.inc:336`,
  `src/infer/token0_layer4_attn_slices.inc:415`).
- The output oracle covers the exposed arithmetic boundary: full layer-4
  RMSNorm activation, full value projection, single-token grouped-query context
  expansion, and the first four output-projection rows using the same ordered
  scalar f32 Q8_0 accumulation as the runtime (`work/oracle/token0_layer4_attn_output_oracle.py:90`,
  `work/oracle/token0_layer4_attn_output_oracle.py:139`,
  `work/oracle/token0_layer4_attn_output_oracle.py:145`,
  `work/oracle/token0_layer4_attn_output_oracle.py:147`).
- Source-size pressure is the only process risk. `src/infer/token0_layer4_attn.s`
  remains at 945 lines, so the next layer-4 post-attention residual work should
  live in a focused module instead of growing that file.

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime/oracle comparison was empty for layer-3 post-FFN
  residual, layer-4 attention RMSNorm, layer-4 value, and layer-4
  output-projection public exact-hex labels.
- Focused real target preservation comparisons were empty for layer-4 query and
  key public exact-hex labels against their dedicated oracles.
- Real target smoke reported all reviewed layer-4 descriptors and statuses at
  `1`; `blk.4.attn_output.weight` reported Q8_0 dimensions `4096x3072` and
  relative offset `925949952`.
- A 24-byte header-only GGUF kept all reviewed layer-4 descriptor fields and
  dependent statuses at `0`, and emitted no guarded layer-4 exact-hex labels.
- `git diff --check`
- Runtime source extension scan allowed only tracked `.s` and `.inc` files under
  `src/`.
- Include dependency scan covered all `.include` fragments listed under `src/`.
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, and `nm -u ./mistral-asm`
  confirmed a static executable with no dynamic section and no undefined
  symbols.
- Exported-symbol inspection covered the layer-4 attention public runners,
  statuses, and retained handoff buffers.
- Source line-count check preserved the known pressure points:
  `src/infer/token0_layer4_attn.s` at 945 lines,
  `src/infer/token0_layer3_ffn.s` at 942 lines,
  `src/infer/token0_layer2_ffn.s` at 943 lines,
  `src/infer/token0_layer2_attn.s` at 997 lines, and
  `src/gguf/load_header/tensor_infos.inc` at 1172 lines.
- Tracked artifact and tracked large-file scans passed.

## Residual Risk

- This review gate still does not prove multi-token attention scoring, masking,
  or softmax. The current context shortcut is valid only for the one-token smoke
  path.
- The near-threshold layer-4 attention source file should not receive the next
  residual implementation.
