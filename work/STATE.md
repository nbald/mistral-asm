# STATE

## Current Milestone

Milestone 8: Q8_0 matvec.

## Current Exact Task

Begin the scalar Q8_0 math slice by adding a small, audited assembly routine for
one Q8_0 block dot product and a verification path that can compare it against a
simple external calculation.

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
- The Milestone 7 parser gap is fixed: the tensor-info walker tracks the largest
  relative payload offset across all descriptors and rejects directories whose
  aligned tensor-data base plus that offset does not land inside the mapped file.

## Known Blockers

None.

## Relevant Files

- `src/gguf/load_header.s`
- `src/entry/_start.s`
- `src/math/` (next milestone destination; not yet present)
- `work/reviews/`
- `work/STATE.md`
- `work/WORKLOG.md`

## Required Verification

- Define focused scalar Q8_0 dot-product fixtures with known expected results.
- Rebuild with `as`/`ld`.
- Verify the new assembly math routine against the expected scalar results.
- Keep existing GGUF loader smoke checks passing.

## Last Verification

- `make clean && make` passed.
- `./mistral-asm --help` returned status 0 and lists the tensor-directory
  summary milestone.
- Synthetic GGUF fixture `/tmp/mistral_asm_tensor_valid.gguf` with one tensor,
  aligned offset 0, and one payload byte returned status 0 and printed the first
  tensor summary.
- Synthetic GGUF fixture `/tmp/mistral_asm_tensor_offset_beyond_file.gguf` with
  one tensor and aligned relative offset 1024 returned status 3 with the
  malformed tensor-directory diagnostic.
- Invoking the future prompt generation form returned the usage error with status
  2.
- `readelf` reported no dynamic section and no interpreter or dynamic program
  headers.
- Target model file was not present locally.
- `git diff --check` passed.

## Next Exact Step

Add `src/math/q8_0_dot.s` with a scalar one-block Q8_0 dot-product routine and
wire a minimal assembly verification target or harness so known fixtures can
exercise it without libc.
