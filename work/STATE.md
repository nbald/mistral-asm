# STATE

## Current Milestone

Milestone 7: Review pass.

## Current Exact Task

Fix the Milestone 7 review finding: reject tensor descriptors whose relative
payload offsets point beyond the mapped file once the aligned tensor-data base is
known.

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
  bounded name, dimension count, up to four dimension sizes, ggml type, and
  relative payload offset in caller-owned summary storage, while still applying
  bounds and alignment checks to remaining tensor descriptors.
- Unused first-tensor dimension summary slots remain zero-filled when
  `n_dimensions` is smaller than four or when the tensor directory is empty.
- Milestone 7 review pass is complete. It found one parser correctness gap:
  aligned tensor relative offsets can point beyond EOF because the walker checks
  descriptor bounds and offset alignment but not `tensor_data_base + offset`
  against the mapped file length.

## Known Blockers

None.

## Relevant Files

- `src/entry/_start.s`
- `src/gguf/load_header.s`
- `work/reviews/`
- `work/STATE.md`
- `work/WORKLOG.md`

## Required Verification

- Add a synthetic GGUF fixture whose tensor descriptor uses an aligned relative
  offset beyond EOF, and verify it is rejected with status 3 and the malformed
  tensor-directory diagnostic.
- Re-run the successful tensor-directory summary fixture to prove valid aligned
  offsets still pass.
- Run rebuild, help, future prompt-form rejection, static-link, and whitespace
  checks.

## Last Verification

- `make clean && make` passed.
- `./mistral-asm --help` returned status 0 and lists the tensor-directory
  summary milestone.
- Synthetic GGUF fixtures verified empty tensor summary zero-fill, first tensor
  dimension capture for two-dimension and four-dimension descriptors, zero-fill
  of unused dimension slots, metadata summary preservation, and continued
  walking of a second tensor descriptor.
- Synthetic failure fixtures still reject a misaligned second tensor offset and
  a truncated first tensor dimension array with status 3 diagnostics.
- Invoking the future prompt generation form returned the usage error with
  status 2.
- `readelf` reported no dynamic section and no interpreter or dynamic program
  headers.
- Target model file was not present locally.
- `git diff --check` passed.
- Review fixture `/tmp/mistral_asm_tensor_offset_beyond_file.gguf` proved the
  offset gap: a 64-byte one-tensor GGUF with `first_tensor_offset: 1024` returned
  status 0.

## Next Exact Step

Fix tensor relative payload offset validation in `src/gguf/load_header.s`, then
verify the beyond-EOF offset fixture is rejected and valid tensor-directory
fixtures still pass.
