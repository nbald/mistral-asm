# STATE

## Current Milestone

Milestone 6: Tensor directory.

## Current Exact Task

Extend first tensor descriptor retention to store and print up to four dimension
sizes, zero-filling unused slots when `n_dimensions` is smaller.

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
- The tensor directory walker captures only the first tensor descriptor's
  bounded name, dimension count, ggml type, and relative payload offset in
  caller-owned summary storage, while still applying bounds and alignment checks
  to remaining tensor descriptors.

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
- `./mistral-asm --help` returned status 0 and lists the tensor-directory
  summary milestone.
- Synthetic GGUF fixtures verified successful summary output for empty metadata,
  full architecture/context/block/token metadata, wrong-typed token metadata
  skip, first tensor descriptor capture, a two-tensor directory where the second
  descriptor is still walked, and long first tensor name truncation to 95 bytes.
- Synthetic failure fixtures still reject bad high-bit counts, truncated
  metadata, malformed token arrays, a misaligned second tensor offset, and a
  truncated tensor descriptor with status 3.
- Invoking the future prompt generation form returned the usage error with
  status 2.
- `readelf` reported no dynamic section and no interpreter or dynamic program
  headers.
- Target model file was not present locally.
- `git diff --check` passed.

## Next Exact Step

Extend the first tensor descriptor summary to retain and print up to four u64
dimension sizes, copying only the validated dimension entries for the first
tensor and leaving unused slots as zero.
