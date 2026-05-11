# Layer-4 Post-Attention Residual Review 1 - 2026-05-11

Scope: first review-gate pass over the completed token-0 layer-4
post-attention residual handoff before starting focused layer-4 FFN work.

## Findings

- No blocking findings in this pass.
- No runtime source changes were required. The handoff remains status-gated,
  descriptor-width-guarded, and isolated in a focused residual module.

## Notes

- Runtime orchestration preserves the reviewed dependency order while the
  process still owns the live mapping: layer-3 post-FFN residual, layer-4
  attention output projection, and then layer-4 post-attention residual before
  `gguf_release_mapping` (`src/entry/start/main/smoke_orchestration.inc:428`,
  `src/entry/start/main/smoke_orchestration.inc:434`,
  `src/entry/start/main/smoke_orchestration.inc:435`).
- The exported residual runner has a complete contract and publishes exactly one
  status line before delegating guarded slice output. It owns only the layer-4
  post-attention residual status/buffer and explicitly does not read mapped
  tensor payload bytes (`src/infer/token0_layer4_post_attn_residual.s:49`,
  `src/infer/token0_layer4_post_attn_residual.s:65`,
  `src/infer/token0_layer4_post_attn_residual.s:69`,
  `src/infer/token0_layer4_post_attn_residual.s:87`).
- The residual smoke fails closed. It zeros `rax`, requires the retained
  layer-3 post-FFN residual status, requires the retained layer-4 attention
  output matvec status, repeats the 3072-wide output descriptor guard, and only
  then performs 3072 scalar f32 additions into module-owned storage
  (`src/infer/token0_layer4_post_attn_residual.s:108`,
  `src/infer/token0_layer4_post_attn_residual.s:110`,
  `src/infer/token0_layer4_post_attn_residual.s:112`,
  `src/infer/token0_layer4_post_attn_residual.s:118`,
  `src/infer/token0_layer4_post_attn_residual.s:126`).
- Public exact-hex residual labels are print-side status-gated and cannot appear
  when the residual smoke reports `0`
  (`src/infer/token0_layer4_post_attn_residual.s:158`,
  `src/infer/token0_layer4_post_attn_residual.s:159`).
- Oracle coverage matches the exposed arithmetic boundary. The residual oracle
  reuses the layer-4 attention output oracle, then adds the first four layer-3
  post-FFN residual words to the first four layer-4 attention output words with
  explicit scalar f32 rounding (`work/oracle/token0_layer4_post_attn_residual_oracle.py:58`,
  `work/oracle/token0_layer4_post_attn_residual_oracle.py:61`,
  `work/oracle/token0_layer4_post_attn_residual_oracle.py:63`).
- Help text accurately advertises layer-4 context as status-only and the
  layer-4 post-attention residual as an output slice
  (`src/entry/start/rodata/cli_requests.inc:38`,
  `src/entry/start/rodata/cli_requests.inc:40`,
  `src/entry/start/rodata/cli_requests.inc:41`).
- Readiness for layer-4 FFN work is acceptable after the second review pass:
  the retained `token0_layer4_post_attn_residual` buffer is a focused handoff
  surface, and the module is 223 lines, leaving the near-threshold
  `src/infer/token0_layer4_attn.s` untouched.

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

- This is only the first of two required review passes before layer-4 FFN work
  resumes.
- The handoff proves the post-attention residual addition and retained buffer,
  not any layer-4 FFN descriptor lookup, RMSNorm, gate/up projection, SwiGLU, or
  down projection behavior.
