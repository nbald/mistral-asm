# Layer-4 FFN Chain Review 1 - 2026-05-12

Scope: first review-gate pass over the completed token-0 layer-4
FFN/down/post-FFN residual chain before expanding feature scope.

## Findings

- No blocking findings in this pass.
- No runtime source changes were required. The reviewed chain remains
  status-gated, shape-checked, mmap-bounds-checked before payload reads, and
  split between the near-threshold FFN module and the focused down/residual
  module.

## Notes

- Runtime orchestration preserves the reviewed dependency order while the model
  mapping is still live: layer-4 post-attention residual, FFN RMSNorm, gate/up
  matvecs, SwiGLU, down matvec, then post-FFN residual
  (`src/entry/start/main/smoke_orchestration.inc:435`,
  `src/entry/start/main/smoke_orchestration.inc:436`,
  `src/entry/start/main/smoke_orchestration.inc:437`,
  `src/entry/start/main/smoke_orchestration.inc:438`,
  `src/entry/start/main/smoke_orchestration.inc:439`,
  `src/entry/start/main/smoke_orchestration.inc:440`,
  `src/entry/start/main/smoke_orchestration.inc:441`).
- Layer-4 FFN descriptor bootstrap is descriptor-only. The norm/gate/up/down
  slots are filled by `gguf_lookup_tensor_info`, and payload bytes remain
  unread until the later focused smoke paths recheck type, shape, and bounds
  (`src/entry/start/main/bootstrap/layer4.inc:107`,
  `src/entry/start/main/bootstrap/layer4.inc:129`,
  `src/entry/start/main/bootstrap/layer4.inc:150`,
  `src/entry/start/main/bootstrap/layer4.inc:171`).
- The FFN RMSNorm smoke fails closed: it starts with `rax = 0`, requires the
  post-attention residual and epsilon metadata, requires f32 `[3072]` weights,
  proves the mapped weight span, and only then calls `rmsnorm_f32`
  (`src/infer/token0_layer4_ffn.s:210`,
  `src/infer/token0_layer4_ffn.s:212`,
  `src/infer/token0_layer4_ffn.s:214`,
  `src/infer/token0_layer4_ffn.s:216`,
  `src/infer/token0_layer4_ffn.s:220`,
  `src/infer/token0_layer4_ffn.s:222`,
  `src/infer/token0_layer4_ffn.s:228`,
  `src/infer/token0_layer4_ffn.s:247`,
  `src/infer/token0_layer4_ffn.s:253`,
  `src/infer/token0_layer4_ffn.s:257`).
- Gate and up matvec smokes use the same guarded pattern: prerequisite norm
  status, Q8_0 `[3072 x 9216]` descriptor checks, complete payload-span proof,
  and then `q8_0_matvec_f32` into private 9216-f32 buffers
  (`src/infer/token0_layer4_ffn.s:495`,
  `src/infer/token0_layer4_ffn.s:497`,
  `src/infer/token0_layer4_ffn.s:503`,
  `src/infer/token0_layer4_ffn.s:505`,
  `src/infer/token0_layer4_ffn.s:507`,
  `src/infer/token0_layer4_ffn.s:514`,
  `src/infer/token0_layer4_ffn.s:538`,
  `src/infer/token0_layer4_ffn.s:549`,
  `src/infer/token0_layer4_ffn.s:552`,
  `src/infer/token0_layer4_ffn.s:711`,
  `src/infer/token0_layer4_ffn.s:713`,
  `src/infer/token0_layer4_ffn.s:719`,
  `src/infer/token0_layer4_ffn.s:721`,
  `src/infer/token0_layer4_ffn.s:723`,
  `src/infer/token0_layer4_ffn.s:729`,
  `src/infer/token0_layer4_ffn.s:753`,
  `src/infer/token0_layer4_ffn.s:764`,
  `src/infer/token0_layer4_ffn.s:767`).
- The SwiGLU smoke does not read mapped tensor payload bytes. It requires both
  projection statuses and combines only module-owned gate/up buffers into the
  retained activation handoff
  (`src/infer/token0_layer4_ffn.s:923`,
  `src/infer/token0_layer4_ffn.s:925`,
  `src/infer/token0_layer4_ffn.s:927`,
  `src/infer/token0_layer4_ffn.s:932`,
  `src/infer/token0_layer4_ffn.s:936`).
- The focused down/residual module keeps substantial down-matvec and residual
  work out of the 945-line layer-4 FFN module. The down smoke requires the
  retained SwiGLU status, verifies Q8_0 `[9216 x 3072]`, proves the complete
  payload span, and writes a private 3072-f32 down output before publishing
  status and guarded slice output
  (`src/infer/token0_layer4_ffn_down.s:401`,
  `src/infer/token0_layer4_ffn_down.s:403`,
  `src/infer/token0_layer4_ffn_down.s:409`,
  `src/infer/token0_layer4_ffn_down.s:411`,
  `src/infer/token0_layer4_ffn_down.s:413`,
  `src/infer/token0_layer4_ffn_down.s:420`,
  `src/infer/token0_layer4_ffn_down.s:444`,
  `src/infer/token0_layer4_ffn_down.s:455`,
  `src/infer/token0_layer4_ffn_down.s:458`).
- The post-FFN residual smoke requires both prerequisite statuses, repeats the
  3072-wide down descriptor guard, and only then performs the private 3072-wide
  scalar f32 residual add. Its exact-hex slice printer is independently
  status-gated
  (`src/infer/token0_layer4_ffn_down.s:344`,
  `src/infer/token0_layer4_ffn_down.s:346`,
  `src/infer/token0_layer4_ffn_down.s:348`,
  `src/infer/token0_layer4_ffn_down.s:354`,
  `src/infer/token0_layer4_ffn_down.s:357`,
  `src/infer/token0_layer4_ffn_down.s:362`,
  `src/infer/token0_layer4_ffn_down.s:373`,
  `src/infer/token0_layer4_ffn_down.s:184`,
  `src/infer/token0_layer4_ffn_down.s:185`,
  `src/infer/token0_layer4_ffn_down.s:186`).
- Oracle coverage is acceptable for the reviewed boundary. The down oracle
  computes full 9216-word gate/up/SwiGLU activations before dotting requested
  down rows, and the post-FFN residual oracle adds post-attention residual words
  to down outputs with explicit scalar f32 rounding
  (`work/oracle/token0_layer4_ffn_down_oracle.py:80`,
  `work/oracle/token0_layer4_ffn_down_oracle.py:126`,
  `work/oracle/token0_layer4_ffn_down_oracle.py:129`,
  `work/oracle/token0_layer4_ffn_down_oracle.py:138`,
  `work/oracle/token0_layer4_ffn_down_oracle.py:141`,
  `work/oracle/token0_layer4_post_ffn_residual_oracle.py:62`,
  `work/oracle/token0_layer4_post_ffn_residual_oracle.py:67`,
  `work/oracle/token0_layer4_post_ffn_residual_oracle.py:69`).
- The next feature step will need an explicit layer-5 handoff decision. The
  layer-4 post-FFN residual buffer is currently private to the focused
  down/residual module; that is fine for the reviewed public status/slice
  boundary, but layer-5 attention work should export it deliberately when it
  becomes an input surface.

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- `./mistral-asm --help` mentions the layer-4 FFN down matvec output slice and
  post-FFN residual output slice.
- `python3 -m py_compile work/oracle/*.py`
- Real target reported `token0_layer4_post_attn_residual: 1`,
  `token0_layer4_ffn_norm: 1`, `token0_layer4_ffn_gate_matvec: 1`,
  `token0_layer4_ffn_up_matvec: 1`, `token0_layer4_ffn_swiglu: 1`,
  `token0_layer4_ffn_down_matvec: 1`, and
  `token0_layer4_post_ffn_residual: 1`.
- Real-target runtime/oracle comparison was empty for the 37 exact-hex labels
  covered by `work/oracle/token0_layer4_post_ffn_residual_oracle.py`, including
  epsilon and all public token-0 f32 slices through layer-4 post-FFN residual.
- A 24-byte zero-count GGUF kept the reviewed layer-4 FFN descriptor found
  flags and dependent statuses at `0`, and emitted no guarded
  `token0_layer4_*_f32_hex` labels.
- `git diff --check`
- Static-link/no-dynamic-section/file check and undefined-symbol check.
- Runtime source extension scan found only `.s` and `.inc` files under `src/`.
- Include dependency scan found every `.include` fragment listed in `Makefile`
  dependencies.
- Tracked artifact and tracked large-file scans found no model files, build
  outputs, binaries, long logs, traces, perf outputs, or tracked files over
  1 MiB.
- Line-count check preserved the known pressure points:
  `src/infer/token0_layer4_ffn.s` at 945 lines,
  `src/infer/token0_layer4_ffn_down.s` at 471 lines,
  `src/infer/token0_layer4_attn.s` at 945 lines,
  `src/infer/token0_layer3_ffn.s` at 942 lines,
  `src/infer/token0_layer2_ffn.s` at 943 lines,
  `src/infer/token0_layer2_attn.s` at 997 lines, and
  `src/gguf/load_header/tensor_infos.inc` at 1172 lines.

## Residual Risk

- This is only the first of two required review passes before feature work
  resumes.
- The review proves the public token-0 layer-4 FFN/down/post-FFN residual smoke
  boundary, not a general reusable layer execution abstraction.
