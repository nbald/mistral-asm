# Layer-4 Post-Attention Residual Review 2 - 2026-05-11

Scope: second review-gate pass over the completed token-0 layer-4
post-attention residual handoff before starting focused layer-4 FFN work.

## Findings

- No blocking findings in this pass.
- No runtime source changes were required. The two-pass review gate is complete,
  and feature work can resume in focused layer-4 FFN entry modules.

## Notes

- Runtime orchestration still preserves the handoff order: layer-3 post-FFN
  residual, layer-4 attention output projection, and then layer-4
  post-attention residual before `gguf_release_mapping`
  (`src/entry/start/main/smoke_orchestration.inc:428`,
  `src/entry/start/main/smoke_orchestration.inc:434`,
  `src/entry/start/main/smoke_orchestration.inc:435`,
  `src/entry/start/main/smoke_orchestration.inc:437`).
- The exported runner stores the smoke result before printing the status and
  then delegates to a slice printer that rechecks the stored status. A failed
  handoff therefore emits only the status line, not stale exact-hex words
  (`src/infer/token0_layer4_post_attn_residual.s:69`,
  `src/infer/token0_layer4_post_attn_residual.s:71`,
  `src/infer/token0_layer4_post_attn_residual.s:87`,
  `src/infer/token0_layer4_post_attn_residual.s:158`,
  `src/infer/token0_layer4_post_attn_residual.s:159`).
- The smoke body uses only process-owned static buffers, requires both
  prerequisite statuses, repeats the 3072-wide layer-4 output descriptor guard,
  and writes exactly 3072 scalar f32 sums through the `rcx`-bounded loop
  (`src/infer/token0_layer4_post_attn_residual.s:108`,
  `src/infer/token0_layer4_post_attn_residual.s:110`,
  `src/infer/token0_layer4_post_attn_residual.s:112`,
  `src/infer/token0_layer4_post_attn_residual.s:118`,
  `src/infer/token0_layer4_post_attn_residual.s:124`,
  `src/infer/token0_layer4_post_attn_residual.s:126`,
  `src/infer/token0_layer4_post_attn_residual.s:137`).
- The external oracle boundary matches the runtime boundary for this handoff:
  it reuses the layer-4 attention output oracle, adds the public layer-3
  post-FFN residual words with scalar f32 rounding, and prints the same four
  public residual labels for comparison
  (`work/oracle/token0_layer4_post_attn_residual_oracle.py:58`,
  `work/oracle/token0_layer4_post_attn_residual_oracle.py:61`,
  `work/oracle/token0_layer4_post_attn_residual_oracle.py:63`,
  `work/oracle/token0_layer4_post_attn_residual_oracle.py:97`,
  `work/oracle/token0_layer4_post_attn_residual_oracle.py:104`).
- The residual module remains a focused `.s` source listed directly in the
  Makefile and has no `.include` fragments to track separately
  (`Makefile:26`, `src/infer/token0_layer4_post_attn_residual.s:223`).

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime/oracle comparison was empty for layer-3 post-FFN
  residual, layer-4 attention output, and layer-4 post-attention residual
  public exact-hex labels; the reviewed layer-4 output and residual statuses
  were both `1`.
- A 24-byte header-only GGUF kept `layer4_attn_output_tensor_found`,
  `layer4_attn_output_tensor_dim1`,
  `token0_layer4_attn_output_matvec`, and
  `token0_layer4_post_attn_residual` at `0`, and emitted no guarded
  `token0_layer4_*_f32_hex` labels.
- `git diff --check`
- Runtime source extension scan allowed only `.s` and `.inc` files under `src/`.
- Include dependency scan covered all `.include` fragments listed under `src/`.
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, and `nm -u ./mistral-asm`
  confirmed a static executable with no dynamic section and no undefined
  symbols.
- Exported-symbol inspection covered
  `run_token0_layer4_post_attn_residual_status`,
  `token0_layer4_post_attn_residual_status`, and
  `token0_layer4_post_attn_residual`.
- Inference source line-count check preserved the known pressure points:
  `src/infer/token0_layer4_attn.s` at 945 lines,
  `src/infer/token0_layer3_ffn.s` at 942 lines,
  `src/infer/token0_layer2_ffn.s` at 943 lines,
  `src/infer/token0_layer2_attn.s` at 997 lines, and the focused layer-4
  post-attention residual module at 223 lines.
- Tracked artifact and tracked large-file scans passed.

## Residual Risk

- This review proves the post-attention residual handoff and retained buffer
  contract only. It does not prove layer-4 FFN descriptor lookup, RMSNorm,
  gate/up projection, SwiGLU, down projection, or post-FFN residual behavior.
