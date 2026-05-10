# GGUF Directory Review - 2026-05-10

## Scope

- Reviewed `_start`, syscall wrappers, `src/gguf/load_header.s`, the build
  contract, current working docs, and prior review notes before starting Q8_0
  tensor payload work.
- No runtime source was changed in this review step.

## Findings

1. `src/gguf/load_header.s` alignment-checks tensor relative payload offsets, but
   does not prove that an offset lands inside the mapped file after the
   tensor-data base is aligned. The first descriptor stores the raw relative
   offset at `src/gguf/load_header.s:728`; later descriptors only reject
   high-bit-set or unaligned offsets at `src/gguf/load_header.s:792`; the
   tensor-data base check at `src/gguf/load_header.s:810` proves only that the
   aligned base itself is inside the file. A synthetic 64-byte GGUF with one
   tensor and `offset = 1024` returned status 0 and printed that offset. This
   should be rejected before Q8_0 matvec starts reading tensor payloads.

## Clean Checks

- Tracked runtime sources under `src/` are assembly `.s` files only.
- The Makefile still builds runtime objects with `as` and links with `ld`.
- Exported and non-trivial internal assembly functions in the reviewed scope
  have contract comments.
- No stale prompt-generation help text or old tensor-info future-work comment
  was found in the reviewed runtime files.

## Residual Risk

- The real target GGUF file was not present locally during this review. Existing
  parser evidence is synthetic fixture coverage, so a real-model smoke test
  remains needed once the model is available.
