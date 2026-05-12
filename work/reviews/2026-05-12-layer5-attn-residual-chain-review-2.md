# Layer-5 Attention Residual Chain Review 2 - 2026-05-12

Scope: second review-gate pass over the completed token-0 layer-5 attention
Q/K/V handoff, single-token context, output-projection matvec/slice, and
post-attention residual handoff chain before adding layer-5 FFN work.

## Findings

- No blocking runtime findings in this pass.
- No runtime source changes were required. The chain remains fail-closed on
  missing descriptors or statuses, the only layer-5 output-projection payload
  read is bounded in the focused output module, and the public handoff for later
  FFN work is the post-attention residual buffer/status.

## Notes

- Runtime orchestration still calls the layer-5 attention projection statuses,
  explicit Q/K/V handoff, context, output matvec, and post-attention residual in
  dependency order before releasing the GGUF mapping
  (`src/entry/start/main/smoke_orchestration.inc:442`,
  `src/entry/start/main/smoke_orchestration.inc:446`,
  `src/entry/start/main/smoke_orchestration.inc:447`,
  `src/entry/start/main/smoke_orchestration.inc:448`,
  `src/entry/start/main/smoke_orchestration.inc:449`,
  `src/entry/start/main/smoke_orchestration.inc:453`).
- The Q/K/V handoff publishes only `token0_layer5_attn_qkv_handoff_status`,
  requires the three projection statuses and exact retained Q/K/V descriptor
  shapes, and does not read projection buffers or mapped payload bytes
  (`src/infer/token0_layer5_attn_qkv_handoff.s:40`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:46`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:91`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:98`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:120`,
  `src/infer/token0_layer5_attn_qkv_handoff.s:131`).
- The context smoke consumes the handoff status, rechecks Q/K/V and
  output-projection descriptor shapes, and copies from the exported value
  projection buffer into the exported 4096-f32 context buffer without reading
  `blk.5.attn_output.weight` payload bytes
  (`src/infer/token0_layer5_attn_context.s:51`,
  `src/infer/token0_layer5_attn_context.s:102`,
  `src/infer/token0_layer5_attn_context.s:127`,
  `src/infer/token0_layer5_attn_context.s:138`,
  `src/infer/token0_layer5_attn_context.s:149`,
  `src/infer/token0_layer5_attn_context.s:178`).
- The output-projection smoke requires context status, validates
  `blk.5.attn_output.weight` as Q8_0 `[4096 x 3072]`, proves the complete
  mapped Q8_0 payload span, then calls `q8_0_matvec_f32`
  (`src/infer/token0_layer5_attn_output.s:198`,
  `src/infer/token0_layer5_attn_output.s:200`,
  `src/infer/token0_layer5_attn_output.s:206`,
  `src/infer/token0_layer5_attn_output.s:215`,
  `src/infer/token0_layer5_attn_output.s:239`,
  `src/infer/token0_layer5_attn_output.s:250`,
  `src/infer/token0_layer5_attn_output.s:253`).
- `token0_layer5_attn_output` remains local private storage, while
  `token0_layer5_post_attn_residual_status` and
  `token0_layer5_post_attn_residual` are the exported boundary for later FFN
  work (`src/infer/token0_layer5_attn_output.s:64`,
  `src/infer/token0_layer5_attn_output.s:68`,
  `src/infer/token0_layer5_attn_output.s:73`).
- The residual smoke requires both the layer-4 post-FFN residual status and the
  layer-5 output-matvec status, repeats the 3072-wide hidden-size guard, writes
  only the exported layer-5 residual buffer, and prints residual exact-hex words
  only after the residual status is 1
  (`src/infer/token0_layer5_attn_output.s:284`,
  `src/infer/token0_layer5_attn_output.s:286`,
  `src/infer/token0_layer5_attn_output.s:292`,
  `src/infer/token0_layer5_attn_output.s:295`,
  `src/infer/token0_layer5_attn_output.s:300`,
  `src/infer/token0_layer5_attn_output.s:311`,
  `src/infer/token0_layer5_attn_output.s:412`).
- The focused oracle mirrors the public boundary: it reuses the layer-5 value
  oracle chain, recomputes value projection, expands grouped-query context,
  computes the first four output-projection rows, and adds the layer-4
  post-FFN residual with scalar f32 rounding
  (`work/oracle/token0_layer5_attn_output_oracle.py:88`,
  `work/oracle/token0_layer5_attn_output_oracle.py:99`,
  `work/oracle/token0_layer5_attn_output_oracle.py:121`,
  `work/oracle/token0_layer5_attn_output_oracle.py:131`,
  `work/oracle/token0_layer5_attn_output_oracle.py:133`,
  `work/oracle/token0_layer5_attn_output_oracle.py:161`,
  `work/oracle/token0_layer5_attn_output_oracle.py:246`,
  `work/oracle/token0_layer5_attn_output_oracle.py:249`).
- The Makefile tracks the focused layer-5 modules as ordinary assembly sources,
  and the include dependency scan still covers every `.include` fragment
  (`Makefile:29`, `Makefile:30`, `Makefile:31`, `Makefile:32`,
  `Makefile:204`, `Makefile:206`, `Makefile:208`, `Makefile:210`).

## Verification

- `make clean all check` passed with `q8_0_dot: ok`, `rmsnorm: ok`,
  `swiglu: ok`, and `gguf_lookup: ok`.
- `python3 -m py_compile work/oracle/*.py`
- `./mistral-asm --help` mentions the layer-5 post-attention residual slice.
- Real-target runtime/oracle comparison matched 61 oracle-covered labels:
  epsilon plus the 60 exact-hex labels covered by
  `work/oracle/token0_layer5_attn_output_oracle.py`.
- Real-target status output reported `token0_layer5_attn_qkv_handoff: 1`,
  `token0_layer5_attn_context: 1`,
  `token0_layer5_attn_output_matvec: 1`, and
  `token0_layer5_post_attn_residual: 1`.
- The published layer-5 post-attention residual words were `0x440c34df`,
  `0xc1fcec34`, `0xc2a9b98b`, and `0xc1618569`.
- A packed 24-byte v3 zero-count GGUF kept
  `layer5_attn_output_tensor_found`, `token0_layer5_attn_qkv_handoff`,
  `token0_layer5_attn_context`, `token0_layer5_attn_output_matvec`, and
  `token0_layer5_post_attn_residual` at `0`, and emitted no guarded layer-5
  output/residual exact-hex labels.
- `file ./mistral-asm`, `readelf -d ./mistral-asm`,
  `readelf -l ./mistral-asm`, and `nm -u ./mistral-asm` confirmed a static
  executable with no dynamic section, no interpreter, and no undefined symbols.
- Runtime source extension scan allowed only `.s` and `.inc` files under `src/`.
- Tracked include dependency scan found every `.include` fragment listed in
  `Makefile` dependencies.
- Symbol inspection confirmed the layer-5 Q/K/V buffers, Q/K/V handoff status,
  context status/buffer, output-matvec status, and post-attention residual
  status/buffer are global, while `token0_layer5_attn_output` remains local
  private storage.
- Tracked artifact and tracked large-file scans found no model files, build
  outputs, binaries, long logs, traces, perf outputs, or tracked files over
  1 MiB.
- Source line-count check preserved the known pressure points:
  `src/infer/token0_layer5_attn.s` at 996 lines,
  `src/infer/token0_layer5_attn_qkv_handoff.s` at 138 lines,
  `src/infer/token0_layer5_attn_context.s` at 185 lines,
  `src/infer/token0_layer5_attn_output.s` at 476 lines,
  `src/infer/token0_layer4_ffn.s` at 945 lines,
  `src/infer/token0_layer4_attn.s` at 945 lines,
  `src/infer/token0_layer3_ffn.s` at 942 lines,
  `src/infer/token0_layer2_ffn.s` at 943 lines,
  `src/infer/token0_layer2_attn.s` at 997 lines, and
  `src/gguf/load_header/tensor_infos.inc` at 1172 lines.

## Residual Risk

- This pass reviews only the token-0 layer-5 attention
  handoff/context/output-projection/post-attention residual chain. It does not
  prove layer-5 FFN work, full generation, or multi-token attention.
- Layer-5 FFN feature work can resume with descriptor-only
  `blk.5.ffn_norm.weight` setup.
