# STATE

## Current Milestone

Milestone 5: Metadata dump.

## Current Exact Task

Capture and print tokenizer vocabulary size from the
`tokenizer.ggml.tokens` array length.

## Completed Work

- GGUF summary prints header `tensor_count`, `metadata_kv_count`,
  `general.architecture`, `mistral3.context_length`, and
  `mistral3.block_count`.
- `mistral3.context_length` and `mistral3.block_count` are captured from u32
  and u64 metadata scalar values into caller-owned storage and default to zero
  when absent or wrong-typed.

## Known Blockers

None.

## Relevant Files

- `Makefile`
- `src/entry/_start.s`
- `src/gguf/load_header.s`
- `work/STATE.md`
- `work/WORKLOG.md`

## Required Verification

- `make clean && make`
- `./mistral-asm --help`
- Synthetic GGUF fixtures still pass/fail the relevant loader paths.
- `git diff --check`

## Last Verification

- `make clean && make` passed.
- `./mistral-asm --help` returned status 0 and lists the metadata-summary
  milestone.
- Synthetic GGUF fixtures verified successful summary output for empty metadata,
  `general.architecture = mistral3`, `mistral3.context_length` as u32/u64,
  `mistral3.block_count` as u32/u64, a wrong-typed block count skip, and one
  tensor plus block-count metadata.
- Synthetic failure fixtures still reject bad high-bit counts and truncated
  metadata with status 3.
- Invoking the future prompt generation form returned the usage error with
  status 2.
- `readelf` reported no dynamic section and no interpreter or dynamic program
  headers.
- Target model file was not present locally.
- `git diff --check` passed.

## Next Exact Step

Extend metadata capture to recognize `tokenizer.ggml.tokens` arrays, store the
array element count in a caller-owned `vocab_size` u64 slot without retaining
token strings, and print it after `block_count`.
