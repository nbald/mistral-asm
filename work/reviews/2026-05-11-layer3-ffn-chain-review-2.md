# Layer-3 FFN Chain Review 2 - 2026-05-11

Scope: second review-gate pass over the completed token-0 layer-3 FFN branch
through the guarded FFN down projection and post-FFN residual slice before
feature work advances to the next layer.

## Findings

- No blocking findings in this pass.
- No source changes were required. The reviewed path remains status-gated,
  bounded to the live mapping, and split between focused layer-3 FFN modules.

## Notes

- Runtime ordering keeps the reviewed chain inside the mmap lifetime. Layer-3
  post-attention residual, FFN RMSNorm, gate/up projections, SwiGLU, FFN down,
  and post-FFN residual execute before `gguf_release_mapping`
  (`src/entry/start/main/smoke_orchestration.inc:422`,
  `src/entry/start/main/smoke_orchestration.inc:428`,
  `src/entry/start/main/smoke_orchestration.inc:430`).
- Descriptor capture remains payload-free. The layer-3 bootstrap only retains
  tensor-directory metadata for FFN norm, gate, up, and down tensors; payload
  bytes are consumed later by guarded smoke functions
  (`src/entry/start/main/bootstrap/layer3.inc:106`,
  `src/entry/start/main/bootstrap/layer3.inc:127`,
  `src/entry/start/main/bootstrap/layer3.inc:148`,
  `src/entry/start/main/bootstrap/layer3.inc:169`).
- Payload consumers fail closed before math helper calls. The RMSNorm and Q8_0
  matvec gates require prerequisite statuses, found/type/shape checks,
  non-negative tensor-data and tensor-relative offsets, overflow-checked
  absolute offsets, complete payload spans inside the mapping, and non-null
  mmap bases (`src/infer/token0_layer3_ffn.s:212`,
  `src/infer/token0_layer3_ffn.s:228`,
  `src/infer/token0_layer3_ffn.s:247`,
  `src/infer/token0_layer3_ffn.s:497`,
  `src/infer/token0_layer3_ffn.s:542`,
  `src/infer/token0_layer3_ffn.s:712`,
  `src/infer/token0_layer3_ffn.s:757`,
  `src/infer/token0_layer3_ffn_down.s:405`,
  `src/infer/token0_layer3_ffn_down.s:451`).
- The reviewed Q8_0 calls match the shared matvec ABI: matrix pointer in `rdi`,
  activation pointer in `rsi`, output pointer in `rdx`, output row count in
  `rcx`, and Q8_0 block count in `r8`. The down path derives 288 blocks from
  the 9216-wide SwiGLU input and 3072 output rows before calling the helper
  (`src/math/q8_0_dot.s:116`, `src/math/q8_0_dot.s:133`,
  `src/infer/token0_layer3_ffn_down.s:435`,
  `src/infer/token0_layer3_ffn_down.s:459`).
- Pure retained-buffer stages have the intended dependency surface. SwiGLU waits
  for gate and up statuses before combining private 9216-f32 buffers; the
  post-FFN residual waits for post-attention residual and down statuses before
  adding 3072 f32 words into retained output storage
  (`src/infer/token0_layer3_ffn.s:922`,
  `src/infer/token0_layer3_ffn.s:929`,
  `src/infer/token0_layer3_ffn_down.s:348`,
  `src/infer/token0_layer3_ffn_down.s:359`).
- Public exact-hex labels remain print-side status-gated for FFN RMSNorm, gate,
  up, SwiGLU, down, and post-FFN residual slices
  (`src/infer/token0_layer3_ffn.s:285`,
  `src/infer/token0_layer3_ffn.s:410`,
  `src/infer/token0_layer3_ffn.s:625`,
  `src/infer/token0_layer3_ffn.s:838`,
  `src/infer/token0_layer3_ffn_down.s:266`,
  `src/infer/token0_layer3_ffn_down.s:187`).
- Oracle coverage still checks the arithmetic boundary that the runtime exposes.
  The down oracle recomputes all 9216 layer-3 gate/up rows and the complete
  SwiGLU activation before the first four down rows; the residual oracle adds
  the matching post-attention residual and down words with scalar f32 rounding
  (`work/oracle/token0_layer3_ffn_down_oracle.py:117`,
  `work/oracle/token0_layer3_ffn_down_oracle.py:129`,
  `work/oracle/token0_layer3_post_ffn_residual_oracle.py:53`,
  `work/oracle/token0_layer3_post_ffn_residual_oracle.py:58`).
- Split discipline remains acceptable for this gate. `token0_layer3_ffn.s` is
  still near the project threshold at 942 lines, while the down/residual work is
  contained in the 473-line focused module. The next layer should start in
  focused layer-4 files or Makefile-tracked fragments.

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- Post-documentation `make all check` passed with the same harness results.
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime/oracle comparison was empty for layer-3 post-attention
  residual, FFN RMSNorm, gate, up, SwiGLU, down, and post-FFN residual public
  exact-hex labels.
- Real target smoke reported all reviewed layer-3 FFN descriptors and statuses
  at `1`; `blk.3.ffn_down.weight` still reported dimensions `9216x3072`,
  type `8`, and relative offset `832339968`.
- A temporary 24-byte empty valid GGUF kept the reviewed layer-3 FFN descriptor
  fields and dependent statuses at `0`, and emitted no guarded layer-3 FFN or
  post-FFN residual exact-hex labels.
- `git diff --check`
- Runtime source extension scan allowed only tracked `.s` and `.inc` files
  under `src/`.
- Tracked include dependency scan covered `.include` fragments in `Makefile`.
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, and `nm -u ./mistral-asm`
  confirmed a static executable with no dynamic section and no undefined
  symbols.
- Exported-symbol inspection covered the reviewed layer-3 FFN runner entry
  points, statuses, and retained handoff buffers.
- Source line-count check passed with the known near-threshold files and
  tensor-directory walker exception unchanged.
- Tracked artifact and tracked large-file scans passed.

## Residual Risk

- This pass does not prove a layer-4 handoff or token generation; it covers the
  completed token-0 layer-3 FFN branch only.
- The scalar smoke path remains intentionally correctness-first and expensive.
  Optimization is deferred until after the first useful inference path exists.
- Feature work can resume by starting focused layer-4 attention descriptor
  coverage.
