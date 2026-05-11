# Layer-4 FFN Chain Review 2 - 2026-05-12

Scope: second review-gate pass over the completed token-0 layer-4
FFN/down/post-FFN residual chain before feature work advances to the next
layer.

## Findings

- No blocking findings in this pass.
- No runtime source changes were required. The reviewed path remains
  status-gated, bounded before mapped tensor payload reads, and split so the
  layer-4 down projection and post-FFN residual stay out of the near-threshold
  layer-4 FFN module.

## Notes

- Runtime ordering keeps all reviewed layer-4 FFN work inside the mmap
  lifetime. The smoke chain runs layer-4 post-attention residual, FFN RMSNorm,
  gate/up projections, SwiGLU, down projection, and post-FFN residual before
  `gguf_release_mapping` (`src/entry/start/main/smoke_orchestration.inc:435`,
  `src/entry/start/main/smoke_orchestration.inc:441`,
  `src/entry/start/main/smoke_orchestration.inc:443`).
- Descriptor lookup remains separated from payload consumption. Layer-4
  FFN norm/gate/up/down descriptors are retained during bootstrap, but each
  later smoke path rechecks the exact target type and shape before reading f32
  or Q8_0 payload bytes (`src/entry/start/main/bootstrap/layer4.inc:107`,
  `src/entry/start/main/bootstrap/layer4.inc:129`,
  `src/entry/start/main/bootstrap/layer4.inc:150`,
  `src/entry/start/main/bootstrap/layer4.inc:171`).
- Payload readers fail closed before helper calls. The FFN RMSNorm smoke checks
  prerequisite status, epsilon metadata, f32 `[3072]` shape, non-negative
  offsets, overflow-safe absolute offset, complete mapped span, and non-null
  mapping before calling `rmsnorm_f32` (`src/infer/token0_layer4_ffn.s:210`,
  `src/infer/token0_layer4_ffn.s:214`,
  `src/infer/token0_layer4_ffn.s:220`,
  `src/infer/token0_layer4_ffn.s:228`,
  `src/infer/token0_layer4_ffn.s:247`,
  `src/infer/token0_layer4_ffn.s:253`,
  `src/infer/token0_layer4_ffn.s:257`).
- The gate/up/down matvec smokes match the shared `q8_0_matvec_f32` ABI:
  matrix pointer in `rdi`, input activation in `rsi`, output pointer in `rdx`,
  output row count in `rcx`, and Q8_0 block count in `r8`. Gate/up derive
  96 blocks from 3072 input values; down derives 288 blocks from the 9216-wide
  SwiGLU activation (`src/infer/token0_layer4_ffn.s:527`,
  `src/infer/token0_layer4_ffn.s:549`,
  `src/infer/token0_layer4_ffn.s:551`,
  `src/infer/token0_layer4_ffn.s:742`,
  `src/infer/token0_layer4_ffn.s:764`,
  `src/infer/token0_layer4_ffn_down.s:434`,
  `src/infer/token0_layer4_ffn_down.s:455`,
  `src/infer/token0_layer4_ffn_down.s:457`).
- Pure retained-buffer stages have the intended dependency surface. SwiGLU
  waits for both gate/up matvec statuses and reads no mapped payload bytes; the
  post-FFN residual waits for post-attention residual plus down statuses, repeats
  the 3072-wide descriptor guard, and only then writes its private residual
  buffer (`src/infer/token0_layer4_ffn.s:923`,
  `src/infer/token0_layer4_ffn.s:927`,
  `src/infer/token0_layer4_ffn.s:932`,
  `src/infer/token0_layer4_ffn_down.s:344`,
  `src/infer/token0_layer4_ffn_down.s:348`,
  `src/infer/token0_layer4_ffn_down.s:354`,
  `src/infer/token0_layer4_ffn_down.s:359`).
- Public exact-hex slices are print-side status-gated for FFN RMSNorm, gate,
  up, SwiGLU, down, and post-FFN residual outputs
  (`src/infer/token0_layer4_ffn.s:284`,
  `src/infer/token0_layer4_ffn.s:409`,
  `src/infer/token0_layer4_ffn.s:624`,
  `src/infer/token0_layer4_ffn.s:841`,
  `src/infer/token0_layer4_ffn_down.s:264`,
  `src/infer/token0_layer4_ffn_down.s:185`).
- Oracle coverage still checks the arithmetic boundary exposed by the runtime.
  The layer-4 down oracle computes the full 9216-word gate/up/SwiGLU activation
  before dotting the public down rows; the post-FFN residual oracle then adds
  the matching post-attention residual words with scalar f32 rounding
  (`work/oracle/token0_layer4_ffn_down_oracle.py:126`,
  `work/oracle/token0_layer4_ffn_down_oracle.py:138`,
  `work/oracle/token0_layer4_ffn_down_oracle.py:141`,
  `work/oracle/token0_layer4_post_ffn_residual_oracle.py:67`,
  `work/oracle/token0_layer4_post_ffn_residual_oracle.py:69`).
- Split discipline remains acceptable for this gate. `token0_layer4_ffn.s` is
  still 945 lines, while down/residual work is contained in the 471-line focused
  module. The next layer should start in focused layer-5 wiring or
  Makefile-tracked fragments instead of expanding the layer-4 modules.
- The layer-4 post-FFN residual buffer remains private to
  `token0_layer4_ffn_down.s`. That is acceptable for the reviewed public
  status/slice boundary; layer-5 work must export the handoff deliberately when
  it first consumes that residual as an input.

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- Post-documentation `make all check` passed with the same harness results.
- `./mistral-asm --help` mentions the layer-4 FFN down matvec output slice and
  post-FFN residual output slice.
- `python3 -m py_compile work/oracle/*.py`
- Real target smoke reported `token0_layer4_post_attn_residual: 1`,
  `token0_layer4_ffn_norm: 1`, `token0_layer4_ffn_gate_matvec: 1`,
  `token0_layer4_ffn_up_matvec: 1`, `token0_layer4_ffn_swiglu: 1`,
  `token0_layer4_ffn_down_matvec: 1`, and
  `token0_layer4_post_ffn_residual: 1`.
- Real-target runtime/oracle comparison was empty for the 37 exact-hex labels
  covered by `work/oracle/token0_layer4_post_ffn_residual_oracle.py`, including
  epsilon and all public token-0 f32 slices through layer-4 post-FFN residual.
- A temporary 24-byte zero-count GGUF kept the reviewed layer-4 FFN descriptor
  found flags and dependent statuses at `0`, and emitted no guarded
  `token0_layer4_*_f32_hex` labels.
- `git diff --check`
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, and `nm -u ./mistral-asm`
  confirmed a static executable with no dynamic section and no undefined
  symbols.
- Runtime source extension scan allowed only `.s` and `.inc` files under
  `src/`.
- Tracked include dependency scan found every `.include` fragment listed in
  `Makefile` dependencies.
- Exported-symbol inspection covered the reviewed layer-4 FFN runner entry
  points, descriptor slots, statuses, and retained activation handoff buffers.
- Tracked artifact and tracked large-file scans found no model files, build
  outputs, binaries, long logs, traces, perf outputs, or tracked files over
  1 MiB.
- Source line-count check preserved the known pressure points:
  `src/infer/token0_layer4_ffn.s` at 945 lines,
  `src/infer/token0_layer4_ffn_down.s` at 471 lines,
  `src/infer/token0_layer4_attn.s` at 945 lines,
  `src/infer/token0_layer3_ffn.s` at 942 lines,
  `src/infer/token0_layer2_ffn.s` at 943 lines,
  `src/infer/token0_layer2_attn.s` at 997 lines, and
  `src/gguf/load_header/tensor_infos.inc` at 1172 lines.

## Residual Risk

- This pass proves the public token-0 layer-4 FFN/down/post-FFN residual smoke
  boundary, not token generation or a reusable whole-layer execution
  abstraction.
- The scalar smoke path remains correctness-first and expensive. Optimization
  remains deferred until a useful inference path exists.
- Feature work can resume by starting focused layer-5 attention descriptor
  coverage.
