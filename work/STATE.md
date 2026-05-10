# STATE

## Current Milestone

Milestone 5: Metadata dump.

## Current Exact Task

Capture and print `mistral3.block_count`.

## Completed Work

- GGUF summary prints header `tensor_count`, `metadata_kv_count`,
  `general.architecture`, and `mistral3.context_length`.
- `mistral3.context_length` is captured from u32 and u64 metadata scalar values
  into caller-owned storage and defaults to zero when absent or wrong-typed.

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
  `general.architecture = mistral3`, `mistral3.context_length` as u32 and u64,
  one tensor plus metadata entries, wrong-typed architecture/context skip, and
  long architecture truncation.
- Synthetic failure fixtures still reject bad high-bit counts and truncated
  metadata with status 3.
- Invoking the future prompt generation form returned the usage error with
  status 2.
- `readelf` reported no dynamic section and no interpreter or dynamic program
  headers.
- Target model file was not present locally.
- `git diff --check` passed.

## Next Exact Step

Extend the caller-owned GGUF summary with a `block_count` u64 slot, capture
`mistral3.block_count` when its metadata value is a u32/u64 scalar, and print it
after `context_length`.
