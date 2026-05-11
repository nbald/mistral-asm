# Layer-1 FFN Down Review 1 - 2026-05-11

## Scope

- First review pass over the completed token-0 layer-1 FFN gate/up/SwiGLU,
  down projection, and post-FFN residual slice path before layer-2 or broader
  feature work resumes.
- Reviewed descriptor handoff, call ordering, status gates, output slice
  guards, Q8_0 payload bounds checks, assembly contracts, build purity, and
  durable oracle coverage.
- No runtime source was changed in this review step.

## Findings

- Important: durable oracle coverage now lags the public runtime diagnostics.
  `work/oracle/` has tracked layer-1 oracle coverage through
  `token0-layer1-ffn-norm.md`, but no tracked script or note for the committed
  layer-1 FFN gate/up/SwiGLU/down projection or post-FFN residual slices. The
  runtime now publishes that branch in order at
  `src/entry/start/main/smoke_orchestration.inc:396` through
  `src/entry/start/main/smoke_orchestration.inc:402`, including the down
  matvec and post-FFN residual implemented in
  `src/infer/token0_layer1_ffn_down.s:399` through
  `src/infer/token0_layer1_ffn_down.s:455` and
  `src/infer/token0_layer1_ffn_down.s:345` through
  `src/infer/token0_layer1_ffn_down.s:371`. The last commit's narrow f32-add
  check proves the final residual add from adjacent published words, but it
  does not leave a repeatable oracle that recomputes the full layer-1 FFN
  branch before the project adds layer-2 dependencies.

## Recommendation

- Keep feature scope stopped. The next non-review step should add a durable
  external oracle script and note for the committed layer-1 FFN branch, at
  minimum recomputing and comparing the first four gate, up, SwiGLU, down, and
  post-FFN residual words for the local target GGUF. After that fix, rerun this
  review gate before adding layer-2 work.

## Clean Checks

- The layer-1 sequence remains ordered so FFN norm, gate, up, SwiGLU, down, and
  post-FFN residual execute before mapping release
  (`src/entry/start/main/smoke_orchestration.inc:396`,
  `src/entry/start/main/smoke_orchestration.inc:401`,
  `src/entry/start/main/smoke_orchestration.inc:402`).
- The down matvec smoke requires the upstream SwiGLU status, descriptor
  presence, two-dimensional Q8_0 type, exact `[9216 x 3072]` shape, non-negative
  tensor-data and payload offsets, overflow-free offset addition, and enough
  mapped bytes before calling `q8_0_matvec_f32`
  (`src/infer/token0_layer1_ffn_down.s:399`,
  `src/infer/token0_layer1_ffn_down.s:409`,
  `src/infer/token0_layer1_ffn_down.s:417`,
  `src/infer/token0_layer1_ffn_down.s:441`,
  `src/infer/token0_layer1_ffn_down.s:455`).
- The down and post-FFN residual slice printers are status-gated before reading
  private output storage (`src/infer/token0_layer1_ffn_down.s:185`,
  `src/infer/token0_layer1_ffn_down.s:264`).
- The post-FFN residual smoke requires both prerequisite statuses and writes
  exactly the fixed 3072-wide f32 add into module-owned storage
  (`src/infer/token0_layer1_ffn_down.s:345`,
  `src/infer/token0_layer1_ffn_down.s:358`,
  `src/infer/token0_layer1_ffn_down.s:371`).
- `src/infer/token0_layer1_ffn_down.s` is 468 lines, and the adjacent
  `src/infer/token0_layer1_ffn.s` is 929 lines, so the current focused modules
  do not trigger the near-1000-line split rule.
- The `Makefile` still assembles runtime `.s` sources with `as`, links the
  executable with `ld`, and includes the focused layer-1 FFN down module
  (`Makefile:10`, `Makefile:13`, `Makefile:130`, `Makefile:149`).

## Verification

- `make`
- `make check` passed with `q8_0_dot: ok`, `rmsnorm: ok`, `swiglu: ok`, and
  `gguf_lookup: ok`.
- `./mistral-asm --help`
- Real target smoke filtered to the reviewed labels reported
  `layer1_ffn_down_tensor_found: 1`, descriptor dimensions `9216x3072`, type
  `8`, offset `584957952`, `token0_layer1_ffn_down_matvec: 1`, down output
  words `0x3babc025`, `0x3db2eb07`, `0xbeba3568`, and `0x3df45039`, then
  `token0_layer1_post_ffn_residual: 1` with residual words `0xbd2addbf`,
  `0xbef2bcaa`, `0x4003aae1`, and `0xbddfb01f`.
- A temporary 24-byte empty valid GGUF kept `layer1_ffn_down_tensor_found`,
  `token0_layer1_ffn_down_matvec`, and `token0_layer1_post_ffn_residual` at
  `0` and emitted no layer-1 down or post-FFN residual output word labels.
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- Runtime source extension scan allowing `.s` drivers and tracked `.inc`
  fragments produced no unexpected files.
- `file ./mistral-asm` reported a statically linked x86-64 ELF, and
  `readelf -d ./mistral-asm` reported no dynamic section.
- `git ls-files | rg '(^models/|\.gguf$|\.(bin|log|trace|perf|out)$)'`
  produced no tracked-artifact matches.
- `git ls-files | xargs -r du -h | awk '$1 ~ /[0-9]+M/ { print }'` produced no
  large tracked-file matches.
