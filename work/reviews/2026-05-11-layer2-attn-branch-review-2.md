# Layer-2 Attention Branch Review 2 - 2026-05-11

Scope: second consecutive review-gate pass over the completed token-0 layer-2
attention through post-attention residual path before resuming layer-2 FFN work.

## Findings

- No blocking findings. Feature work may resume with the layer-2 FFN descriptor
  setup, provided new code stays out of the near-limit layer-2 attention module.

## Notes

- Branch ordering is coherent for the current one-token smoke path. `_start`
  computes the layer-1 post-FFN residual, then runs layer-2 attention RMSNorm,
  Q/K/V projection smokes, one-token context expansion, output projection, and
  post-attention residual before releasing the GGUF mapping
  (`src/entry/start/main/smoke_orchestration.inc:396`,
  `src/entry/start/main/smoke_orchestration.inc:409`,
  `src/entry/start/main/smoke_orchestration.inc:413`).
- The handoff into future layer-2 FFN work is the module-owned
  `token0_layer2_post_attn_residual` buffer, not the Q/K sidecar smokes.
  Context expansion intentionally depends on the value projection and output
  descriptor shape only because a single-token attention row has softmax weight
  1. That is sufficient for this smoke branch, but it is not evidence for
  multi-token Q/K score masking or softmax behavior
  (`src/infer/token0_layer2_attn_context.s:114`,
  `src/infer/token0_layer2_post_attn_residual.s:108`).
- Mapped-payload readers still fail closed before touching tensor bytes: each
  layer-2 RMSNorm/matvec smoke requires prerequisite status, found/type/shape
  checks, non-negative tensor-data and tensor-relative offsets, overflow-free
  absolute offset arithmetic, a complete payload span inside the mapping, and a
  non-null mmap base
  (`src/infer/token0_layer2_attn.s:345`,
  `src/infer/token0_layer2_attn.s:428`,
  `src/infer/token0_layer2_attn.s:520`,
  `src/infer/token0_layer2_attn.s:612`,
  `src/infer/token0_layer2_attn_output.s:118`).
- Pure retained-buffer steps have narrow ownership. The context module only
  reads the layer-2 value output and writes its own 4096-f32 context, while the
  residual module only reads retained layer-1 post-FFN and layer-2 attention
  output buffers before writing its own 3072-f32 residual. Both print exact-hex
  slices only through their status gates
  (`src/infer/token0_layer2_attn_context.s:142`,
  `src/infer/token0_layer2_attn_context.s:189`,
  `src/infer/token0_layer2_post_attn_residual.s:121`,
  `src/infer/token0_layer2_post_attn_residual.s:158`).
- Oracle coverage is adequate for the next FFN handoff. The focused residual
  oracle recomputes the optimized layer-2 attention output path and compares the
  first four output and post-attention residual words. The remaining gap is
  intentional: standalone Q/K projection slices are smoke-observable, but
  multi-token attention-score use of Q/K is not implemented or verified yet
  (`work/oracle/token0_layer2_attn_output_oracle.py:151`,
  `work/oracle/token0_layer2_attn_output_oracle.py:153`,
  `work/oracle/token0_layer2_post_attn_residual_oracle.py:43`).
- Readiness to resume feature work is conditional on continuing the split
  discipline. `src/infer/token0_layer2_attn.s` is still 997 lines; the first
  layer-2 FFN step should add descriptor plumbing and later FFN runtime work in
  focused modules or tracked include fragments rather than extending that file.

## Verification

- `make`
- `make check` passed with `q8_0_dot: ok`, `rmsnorm: ok`, `swiglu: ok`, and
  `gguf_lookup: ok`.
- `./mistral-asm --help`
- `python3 -m py_compile work/oracle/*.py`
- Real target runtime smoke reported all reviewed layer-2 descriptor found flags
  and statuses at `1`, with output-projection words `0x3eade180`,
  `0x3ee0fb2f`, `0xbff22222`, `0x3e24eb6b` and post-attention residual words
  `0x3e9885c8`, `0xbd0e0bd8`, `0x3e299d00`, `0x3d544d6e`.
- `python3 work/oracle/token0_layer2_post_attn_residual_oracle.py <local target>`
  reproduced the reviewed layer-2 output and post-attention residual words; the
  normalized runtime/oracle diff was empty.
- A temporary 24-byte empty valid GGUF kept all reviewed layer-2 descriptor found
  flags and statuses at `0`, with no guarded layer-2 exact-hex labels.
- `git diff --check`
- runtime source extension scan allowing only tracked `.s` and `.inc` files under
  `src/`
- tracked include dependency scan
- `file ./mistral-asm`, `readelf -d ./mistral-asm`, and `nm -u ./mistral-asm`
  confirmed a static executable with no dynamic section and no undefined symbols.
- exported-symbol inspection for the reviewed layer-2 runners, statuses, and
  buffers
- tracked-artifact and tracked large-file scans

## Residual Risk

- The next layer-2 FFN descriptor step should add only `blk.2.ffn_norm.weight`
  lookup/summary plumbing. Payload reads and exact-hex FFN norm publication need
  their own later feature/oracle step.
- Multi-token attention remains outside this branch. When sequence length grows
  beyond one token, the project will need Q/K score, mask, and softmax oracle
  coverage before relying on the attention context path.
