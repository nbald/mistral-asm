# Token-0 Forward Review - 2026-05-10

## Scope

- Reviewed the token-0 layer-0 assembly path from embedding dequantization
  through post-FFN residual, including shape guards, mmap bounds checks, math
  helper contracts, public exact-hex slice printers, oracle scripts, and current
  working docs.
- No runtime source was changed in this review step.

## Findings

1. The attention Q/K/V projection smokes can report success and print four-word
   exact-hex slices after writing fewer than four rows. The projection guards
   accept any positive row count up to their static caps at
   `src/entry/_start.s:4496`, `src/entry/_start.s:4600`, and
   `src/entry/_start.s:4704`, while the slice printers at
   `src/entry/_start.s:3335`, `src/entry/_start.s:3414`, and
   `src/entry/_start.s:3493` unconditionally read the first four words whenever
   the status is 1. This is not an out-of-bounds read because the outputs are
   static storage, but a bounds-valid synthetic descriptor with one output row
   would make the public slice include unwritten zero-initialized words and
   weaken the meaning of the oracle comparison labels.
2. The exported `_start` contract is stale for the final step of the current
   smoke chain. Its ownership/lifetime description reaches the FFN down
   projection at `src/entry/_start.s:1177`, but does not mention the guarded
   post-FFN residual add that now runs before `gguf_release_mapping`.

## Clean Checks

- The reviewed runtime remains pure GNU `as` Intel assembly under `src/`.
- `Makefile` still builds runtime objects with `as` and links with `ld`; no C,
  Rust, Python, or generated runtime source was introduced.
- FFN norm, gate, up, SwiGLU, down, and post-FFN residual guards use exact target
  dimensions before writing full static output rows.
- The post-FFN residual oracle recomputes the full FFN down input path, including
  the full 9216-word SwiGLU vector, then checks the public residual words with
  f32-rounded addition matching the assembly `vaddss` path.
- No tracked model files, GGUFs, large logs, traces, or dumps were found.

## Residual Risk

- The current oracle evidence is intentionally slice-based. It proves the public
  first-four words through the first block smoke chain, but layer iteration will
  need a stronger comparison strategy than manually adding more four-word
  prints.
