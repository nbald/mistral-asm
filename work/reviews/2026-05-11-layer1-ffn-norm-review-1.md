# Layer-1 FFN Norm Review 1 - 2026-05-11

## Scope

- First review pass for the operator-requested two-pass review gate before
  feature work resumes.
- Reviewed the committed layer-1 path from reusable descriptor lookup through
  the status-only `token0_layer1_ffn_norm_smoke`, including the preceding
  layer-1 post-attention residual gate, assembly contracts, bounds checks, and
  artifact purity.
- The worktree already contained an unstaged `src/entry/_start.s` change that
  publishes the layer-1 FFN norm exact-hex slice. This review did not stage or
  modify that runtime change. Source line references below refer to the
  committed `HEAD` version.

## Findings

- No blocking correctness findings in the reviewed committed layer-1 FFN norm
  status path.

## Clean Checks

- `_start` keeps the layer-1 sequence ordered: post-attention residual smoke,
  status publication, status-gated residual slice publication, FFN RMSNorm
  smoke, FFN RMSNorm status publication, and then mapping release
  (`src/entry/_start.s:3928`, `src/entry/_start.s:3945`,
  `src/entry/_start.s:3947`, `src/entry/_start.s:3964`).
- `token0_layer1_post_attn_residual_smoke` requires both prerequisite statuses
  and the exact 3072-row hidden width before writing the full private residual
  buffer (`src/entry/_start.s:7962`, `src/entry/_start.s:7972`,
  `src/entry/_start.s:7983`).
- `token0_layer1_ffn_norm_smoke` requires the previous residual status,
  captured RMSNorm epsilon, descriptor presence, exact f32 one-dimensional
  `[3072]` shape, non-negative tensor-data and payload offsets, overflow-free
  offset addition, and sufficient remaining mapped bytes before calling
  `rmsnorm_f32` (`src/entry/_start.s:8019`,
  `src/entry/_start.s:8021`, `src/entry/_start.s:8025`,
  `src/entry/_start.s:8037`, `src/entry/_start.s:8066`).
- `print_layer1_ffn_norm_lookup_summary` prints only retained descriptor
  fields and does not dereference mapped tensor payload bytes
  (`src/entry/_start.s:4675`, `src/entry/_start.s:4687`).
- The runtime contract remains pure assembly: `Makefile` builds only `.s`
  runtime files with `as` and links with `ld`; no tracked model, GGUF, dump,
  trace, or perf artifact was found.

## Verification

- `make`
- `make check` passed with `q8_0_dot: ok`, `rmsnorm: ok`, `swiglu: ok`, and
  `gguf_lookup: ok`.
- `./mistral-asm --help`
- `git diff --check`
- `find src -type f ! -name '*.s' -print` produced no output.
- `readelf -d ./mistral-asm` reported no dynamic section, and `file
  ./mistral-asm` reported a statically linked x86-64 ELF.
- `git ls-files | rg '(^models/|\.gguf$|\.(bin|log|trace|perf|out)$)'`
  produced no tracked-artifact matches.

## Residual Risk

- This pass intentionally did not perform the queued feature publish or the
  real-target/empty-GGUF slice verification. The existing unstaged runtime diff
  should remain out of commits until the second review pass is complete.
- The next feature step will still need an external oracle note for the layer-1
  FFN norm words after the runtime slice is published and verified.
