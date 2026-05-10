# GGUF Loader Review - 2026-05-10

## Scope

- Reviewed `_start`, syscall wrappers, `src/gguf/load_header.s`, the build
  contract, and current working docs before expanding parser scope.
- No runtime source was changed in this review step.

## Findings

1. `src/entry/_start.s` help text advertises the prompt generation form even
   though `_start` currently accepts only `argc == 2`. A user following
   `mistral-asm <model.gguf> <prompt> --max-tokens <n>` gets the usage error
   path with exit status 2. Until prompt generation exists, help should list
   only supported current invocations or clearly mark the prompt form as not yet
   implemented.
2. `src/gguf/load_header.s` has a stale metadata-walker comment saying tensor
   info walking is the next milestone slice. The current loader already calls
   `gguf_walk_tensor_infos` immediately after metadata walking, so the comment
   misleads audit readers following parser ownership.

## Clean Checks

- Tracked runtime sources under `src/` are assembly `.s` files only.
- The Makefile still builds runtime objects with `as` and links with `ld`.
- Exported and non-trivial internal assembly functions in the reviewed scope
  have contract comments.

## Residual Risk

- The real target GGUF file was not present locally during this review. Existing
  parser evidence is synthetic fixture coverage, so a real-model smoke test
  remains needed once the model is available.
