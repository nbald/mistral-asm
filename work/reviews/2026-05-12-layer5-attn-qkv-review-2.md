# Layer-5 Attention QKV Review 2 - 2026-05-12

Scope: second review-gate pass over the completed token-0 layer-5 attention
RMSNorm/query/key/value smoke chain before adding layer-5 context or output
projection scope.

## Findings

- No blocking runtime findings in this pass.
- No runtime source changes were required. The reviewed path still keeps layer-5
  descriptor lookup separate from payload consumption, publishes status before
  exact-hex slices, and fails closed on synthetic or malformed inputs.

## Notes

- This pass focused on symbol ownership and continuation boundaries. The public
  layer-5 boundary exports descriptor fields and the four status runners/status
  slots, while the RMSNorm/Q/K/V activation buffers remain local to
  `src/infer/token0_layer5_attn.s` (`src/infer/token0_layer5_attn.s:103`,
  `src/infer/token0_layer5_attn.s:112`,
  `src/infer/token0_layer5_attn.s:121`,
  `src/infer/token0_layer5_attn.s:130`,
  `src/infer/token0_layer5_attn.s:141`,
  `src/infer/token0_layer5_attn.s:188`,
  `src/infer/token0_layer5_attn.s:234`,
  `src/infer/token0_layer5_attn.s:279`). A later context module must therefore
  introduce an explicit handoff/export or move the needed storage deliberately
  before consuming the Q/K/V buffers from another object.
- The smoke orchestration order is still a valid lifetime proof for the reviewed
  chain: layer-5 RMSNorm consumes the layer-4 post-FFN residual, then Q, K, and
  V consume the layer-5 RMSNorm activation, all before the model mapping is
  released (`src/entry/start/main/smoke_orchestration.inc:441`,
  `src/entry/start/main/smoke_orchestration.inc:442`,
  `src/entry/start/main/smoke_orchestration.inc:443`,
  `src/entry/start/main/smoke_orchestration.inc:444`,
  `src/entry/start/main/smoke_orchestration.inc:445`,
  `src/entry/start/main/smoke_orchestration.inc:449`).
- The print side preserves the public oracle contract: status lines are always
  emitted, exact-hex labels are gated by the matching success status, and the
  labels match the focused layer-5 value oracle coverage
  (`src/infer/token0_layer5_attn.s:183`,
  `src/infer/token0_layer5_attn.s:229`,
  `src/infer/token0_layer5_attn.s:274`,
  `src/infer/token0_layer5_attn.s:320`,
  `work/oracle/token0_layer5_attn_v_oracle.py:189`,
  `work/oracle/token0_layer5_attn_v_oracle.py:192`,
  `work/oracle/token0_layer5_attn_v_oracle.py:195`,
  `work/oracle/token0_layer5_attn_v_oracle.py:198`).
- The Q/K/V matvec smokes recompute the Q8_0 row bytes from the guarded
  3072-wide input, check multiplication overflow before span checks, and pass a
  block count of 96 to the shared ordered matvec helper
  (`src/infer/token0_layer5_attn.s:767`,
  `src/infer/token0_layer5_attn.s:771`,
  `src/infer/token0_layer5_attn.s:775`,
  `src/infer/token0_layer5_attn.s:791`,
  `src/infer/token0_layer5_attn.s:859`,
  `src/infer/token0_layer5_attn.s:875`,
  `src/infer/token0_layer5_attn.s:951`,
  `src/infer/token0_layer5_attn.s:967`).
- The next feature step should avoid adding substantial code to
  `src/infer/token0_layer5_attn.s`, which is already 989 lines. The smallest
  clean continuation is descriptor-only layer-5 attention output setup for
  `blk.5.attn_output.weight`; context work will need a deliberate Q/K/V handoff
  once it starts.

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- Post-documentation `make all check` passed with the same harness results.
- `python3 -m py_compile work/oracle/*.py`
- `./mistral-asm --help` still mentions layer-5 attention RMSNorm, query, key,
  and value descriptor/matvec output-slice coverage.
- Real-target covered-label runtime/oracle comparison matched all 53 labels
  covered by `work/oracle/token0_layer5_attn_v_oracle.py`.
- A temporary 24-byte zero-count GGUF kept the 27 reviewed layer-5 descriptor
  and status labels at `0` and emitted zero layer-5 exact-hex labels.
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

- This completes the two-pass review gate for layer-5 attention RMSNorm/Q/K/V
  only. It does not prove layer-5 context, output projection, residual addition,
  or token generation.
- Layer-5 context cannot be implemented in a separate object until the Q/K/V
  output handoff is made explicit.
