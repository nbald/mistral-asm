# STATE

## Current Milestone

Milestone 6: Tensor directory.

## Current Exact Task

Start retaining tensor directory data by capturing and printing the first tensor
descriptor's name, dimension count, ggml type, and payload offset.

## Completed Work

- GGUF summary prints header `tensor_count`, `metadata_kv_count`,
  `general.architecture`, `mistral3.context_length`, and
  `mistral3.block_count`.
- `mistral3.context_length` and `mistral3.block_count` are captured from u32
  and u64 metadata scalar values into caller-owned storage and default to zero
  when absent or wrong-typed.
- `tokenizer.ggml.tokens` string-array metadata is walked without retaining
  strings; its element count is captured as `vocab_size` in caller-owned storage
  and defaults to zero when absent or wrong-typed.
- Milestone 5 metadata dump fields are complete for the narrow target shape:
  tensor count, architecture, context length, vocabulary size, and layer/block
  count.

## Known Blockers

None.

## Relevant Files

- `src/entry/_start.s`
- `src/gguf/load_header.s`
- `work/STATE.md`
- `work/WORKLOG.md`

## Required Verification

- `make clean && make`
- `./mistral-asm --help`
- Synthetic GGUF fixtures still pass/fail the relevant loader paths.
- Static executable check with `readelf`.
- `git diff --check`

## Last Verification

- `make clean && make` passed.
- `./mistral-asm --help` returned status 0 and lists the metadata-summary
  milestone.
- Synthetic GGUF fixtures verified successful summary output for empty metadata,
  `general.architecture = mistral3`, `mistral3.context_length` as u32/u64,
  `mistral3.block_count` as u32/u64, `tokenizer.ggml.tokens` string-array
  vocabulary size, a wrong-typed token metadata skip, and one tensor after token
  metadata.
- Synthetic failure fixtures still reject bad high-bit counts and truncated
  metadata, including malformed token arrays, with status 3.
- Invoking the future prompt generation form returned the usage error with
  status 2.
- `readelf` reported no dynamic section and no interpreter or dynamic program
  headers.
- Target model file was not present locally.
- `git diff --check` passed.

## Next Exact Step

Extend the tensor-info walker and summary output to retain only the first tensor
descriptor: bounded name copy, `n_dimensions`, `ggml_type`, and relative tensor
payload offset, while continuing to bounds-check and skip the remaining tensor
directory entries.
