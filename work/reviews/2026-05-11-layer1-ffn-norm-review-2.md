# Layer-1 FFN Norm Review 2 - 2026-05-11

## Scope

- Second consecutive review pass for the operator-requested gate before feature
  work resumes.
- Focused on oracle coverage, the queued layer-1 FFN norm slice-publish diff,
  and whether continuation state gives the next agent a coherent handoff.
- The worktree still contains an unstaged `src/entry/_start.s` feature diff
  that publishes the first four layer-1 FFN norm activation words. This review
  inspected that diff but did not stage or modify runtime source.

## Findings

- No blocking findings. Feature work may resume with the queued layer-1 FFN norm
  slice publish, provided that step performs the real-target and negative-gate
  verification before committing it.

## Clean Checks

- Oracle coverage is complete through the committed layer-1 post-attention
  residual slice. The repository intentionally has no
  `token0_layer1_ffn_norm` oracle note or script yet because the corresponding
  public runtime words are not committed; the oracle should be the follow-up
  step after the slice-publish commit records the runtime words.
- The queued runtime diff adds only four new label strings, a call to
  `print_token0_layer1_ffn_norm_slice` after the layer-1 FFN norm status line
  and before mapping release, plus a status-gated print helper. The helper
  reads from private static `token0_layer1_ffn_norm_activation` storage only
  when `token0_layer1_ffn_norm_status` is 1.
- The queued helper follows the same exact-hex publication pattern as the
  already committed layer-1 attention and residual slices: write a label,
  pass the raw f32 word bits to `write_u32_hex`, then write a newline for each
  of four words.
- The continuation state was coherent at review start: review pass 1 was
  committed, pass 2 was the current task, and the existing runtime diff was
  intentionally unstaged. This review commit updates the state so the next
  exact step is the layer-1 FFN norm slice publish.

## Verification

- `make clean`
- `make`
- `make check` passed with `q8_0_dot: ok`, `rmsnorm: ok`, `swiglu: ok`, and
  `gguf_lookup: ok`.
- `./mistral-asm --help`
- `git diff --check`
- `find src -type f ! -name '*.s' -print` produced no output.
- `readelf -d ./mistral-asm` reported no dynamic section, and `file
  ./mistral-asm` reported a statically linked x86-64 ELF.
- `python3 -m py_compile work/oracle/*.py`
- `git ls-files | rg '(^models/|\.gguf$|\.(bin|log|trace|perf|out)$)'`
  produced no tracked-artifact matches.

## Residual Risk

- The queued runtime diff still needs feature-step verification on both the
  real local target GGUF and a non-target/empty valid GGUF before it can be
  committed as the slice publish.
- The layer-1 FFN norm oracle remains intentionally absent until the runtime
  publishes the words that the external oracle will compare.
