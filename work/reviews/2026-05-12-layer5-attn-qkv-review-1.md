# Layer-5 Attention QKV Review 1 - 2026-05-12

Scope: first review-gate pass over the completed token-0 layer-5 attention
RMSNorm/query/key/value smoke chain before adding context or output projection
scope.

## Findings

- No blocking findings in this pass.
- No runtime source changes were required. The reviewed layer-5 path remains
  status-gated, verifies descriptor shape/type, proves complete mapped payload
  spans before math helpers see tensor pointers, and prints public exact-hex
  slices only after the corresponding status is 1.

## Notes

- Runtime ordering keeps the layer-5 smokes after the layer-4 post-FFN residual
  handoff and before `gguf_release_mapping`, so the retained descriptors and
  mapped tensor payloads are still live while layer-5 norm/Q/K/V work runs
  (`src/entry/start/main/smoke_orchestration.inc:441`,
  `src/entry/start/main/smoke_orchestration.inc:442`,
  `src/entry/start/main/smoke_orchestration.inc:445`,
  `src/entry/start/main/smoke_orchestration.inc:450`).
- Descriptor lookup remains separated from payload consumption. Bootstrap
  retains `blk.5.attn_norm.weight`, `blk.5.attn_q.weight`,
  `blk.5.attn_k.weight`, and `blk.5.attn_v.weight` metadata without reading
  tensor payload bytes (`src/entry/start/main/bootstrap/layer5.inc:1`,
  `src/entry/start/main/bootstrap/layer5.inc:22`,
  `src/entry/start/main/bootstrap/layer5.inc:44`,
  `src/entry/start/main/bootstrap/layer5.inc:66`).
- The RMSNorm smoke fails closed unless the layer-4 post-FFN residual status,
  RMSNorm epsilon metadata, f32 `[3072]` descriptor, non-negative offsets,
  overflow-safe absolute offset, complete mapped span, and non-null mapping are
  all proven before `rmsnorm_f32` is called
  (`src/infer/token0_layer5_attn.s:653`,
  `src/infer/token0_layer5_attn.s:655`,
  `src/infer/token0_layer5_attn.s:657`,
  `src/infer/token0_layer5_attn.s:663`,
  `src/infer/token0_layer5_attn.s:671`,
  `src/infer/token0_layer5_attn.s:680`,
  `src/infer/token0_layer5_attn.s:690`,
  `src/infer/token0_layer5_attn.s:700`).
- Query, key, and value matvec smokes all depend on
  `token0_layer5_attn_norm_status`, recheck exact Q8_0 shapes, compute the
  Q8_0 payload length from 96 blocks per 3072-wide row, prove the full mapped
  matrix span, and pass the expected `q8_0_matvec_f32` ABI: matrix in `rdi`,
  activation in `rsi`, output in `rdx`, row count in `rcx`, and block count in
  `r8` (`src/infer/token0_layer5_attn.s:736`,
  `src/infer/token0_layer5_attn.s:738`,
  `src/infer/token0_layer5_attn.s:746`,
  `src/infer/token0_layer5_attn.s:767`,
  `src/infer/token0_layer5_attn.s:783`,
  `src/infer/token0_layer5_attn.s:792`,
  `src/infer/token0_layer5_attn.s:828`,
  `src/infer/token0_layer5_attn.s:920`,
  `src/math/q8_0_dot.s:116`,
  `src/math/q8_0_dot.s:133`).
- Public exact-hex slices are print-side status-gated for layer-5 RMSNorm,
  query, key, and value outputs (`src/infer/token0_layer5_attn.s:339`,
  `src/infer/token0_layer5_attn.s:418`,
  `src/infer/token0_layer5_attn.s:497`,
  `src/infer/token0_layer5_attn.s:576`).
- Oracle coverage matches the exposed boundary. The layer-5 RMSNorm oracle
  computes from the full 3072-word layer-4 post-FFN residual, and the value
  oracle reuses the norm/query/key path before dotting the first four value
  rows (`work/oracle/token0_layer5_attn_norm_oracle.py:80`,
  `work/oracle/token0_layer5_attn_norm_oracle.py:97`,
  `work/oracle/token0_layer5_attn_norm_oracle.py:102`,
  `work/oracle/token0_layer5_attn_v_oracle.py:77`,
  `work/oracle/token0_layer5_attn_v_oracle.py:95`,
  `work/oracle/token0_layer5_attn_v_oracle.py:101`,
  `work/oracle/token0_layer5_attn_v_oracle.py:115`).
- The main residual risk is file size pressure. `src/infer/token0_layer5_attn.s`
  is 989 lines, so context/output-projection feature work should split into
  focused modules or Makefile-tracked include fragments instead of expanding
  that file.

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- Post-documentation `make all check` passed with the same harness results.
- `python3 -m py_compile work/oracle/*.py`
- `./mistral-asm --help` mentions layer-5 attention RMSNorm, query, key, and
  value descriptor/matvec output-slice coverage.
- Real-target covered-label runtime/oracle comparison was empty for the 53
  labels covered by `work/oracle/token0_layer5_attn_v_oracle.py`, including
  epsilon and the public exact-hex slices through layer-5 attention value.
- A temporary 24-byte zero-count GGUF kept all layer-5 norm/query/key/value
  descriptor fields and `token0_layer5_attn_norm`,
  `token0_layer5_attn_q_matvec`, `token0_layer5_attn_k_matvec`, and
  `token0_layer5_attn_v_matvec` at `0`, and emitted no guarded
  `token0_layer5_attn_*_f32_hex` labels.
- `git diff --check`
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, and `nm -u ./mistral-asm`
  confirmed a static executable with no dynamic section and no undefined
  symbols.
- Runtime source extension scan allowed only `.s` and `.inc` files under
  `src/`.
- Tracked include dependency scan found every `.include` fragment listed in
  `Makefile` dependencies.
- Exported-symbol inspection covered the reviewed layer-5 runner entry points,
  descriptor slots, and status symbols.
- Tracked artifact and tracked large-file scans found no model files, build
  outputs, binaries, long logs, traces, perf outputs, or tracked files over
  1 MiB.
- Source line-count check preserved the known pressure points:
  `src/infer/token0_layer5_attn.s` at 989 lines,
  `src/infer/token0_layer4_ffn.s` at 945 lines,
  `src/infer/token0_layer4_ffn_down.s` at 472 lines,
  `src/infer/token0_layer4_attn.s` at 945 lines,
  `src/infer/token0_layer3_ffn.s` at 942 lines,
  `src/infer/token0_layer2_ffn.s` at 943 lines,
  `src/infer/token0_layer2_attn.s` at 997 lines, and
  `src/gguf/load_header/tensor_infos.inc` at 1172 lines.

## Residual Risk

- This pass proves the public token-0 layer-5 norm/Q/K/V smoke boundary, not
  full attention context, output projection, or token generation.
- The scalar smoke path remains correctness-first and expensive. Optimization
  remains deferred until a useful inference path exists.
- A second review-gate pass is still required before feature work resumes.
