# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Begin forward-pass setup by extending the GGUF tensor-directory path from a
first-tensor summary toward a small bounded tensor descriptor lookup that can
resolve named tensor payloads needed by the one-token path.

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
- `src/math/q8_0_dot.s` exports `q8_0_dot_f32_block`, a scalar one-block GGML
  Q8_0 dot primitive for one 34-byte Q8_0 weight block and 32 f32 activations.
- `src/math/q8_0_dot.s` also exports `q8_0_dot_f32_row`, a scalar multi-block
  row/span dot primitive that accumulates over `32 * block_count` f32
  activations and returns +0.0 for a zero block count.
- `src/math/q8_0_dot.s` exports `q8_0_matvec_f32`, a scalar row-major GGML Q8_0
  matrix times f32 activation-vector routine that writes f32 row outputs and
  writes nothing for a zero row count.
- `make check-q8_0-dot` builds a separate no-libc assembly verifier that checks
  exact f32 result bits for one-block fixtures, two-block row fixtures, row
  pointer advancement, zero-block behavior, a two-row/two-block matvec fixture,
  and zero-row matvec no-write behavior.

## Known Blockers

None.

## Relevant Files

- `src/gguf/load_header.s`
- `src/entry/_start.s`
- `src/math/q8_0_dot.s`
- `tests/q8_0_dot_harness.s`
- `Makefile`
- `work/reviews/`
- `work/STATE.md`
- `work/WORKLOG.md`

## Required Verification

- Define focused synthetic GGUF tensor-directory fixtures for the lookup shape,
  including a found descriptor, absent descriptor/default state, and malformed
  later descriptor rejection.
- Rebuild with `as`/`ld`.
- Keep `make check`, existing GGUF loader smoke checks, and static-link checks
  passing.
- Smoke-test the real target GGUF when the ignored local model remains present.

## Last Verification

- `make clean && make && make check` passed.
- `make check` passed and printed `q8_0_dot: ok`, covering exact f32 bits for
  one-block dots, two-block row dots, row pointer advancement, zero-block row
  return, a two-row/two-block matvec output pair of 512.0 and 28.0, and
  zero-row matvec no-write behavior.
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
- The target model is present under
  `models/unsloth-Ministral-3-3B-Instruct-2512-GGUF/Ministral-3-3B-Instruct-2512-Q8_0.gguf`;
  loading it returned status 0 and printed `tensor_count: 236`,
  `architecture: mistral3`, `context_length: 262144`, `block_count: 26`, and
  `vocab_size: 131072`.
- `git diff --check` passed.

## Next Exact Step

Extend the GGUF tensor-directory walker with a caller-owned, bounded descriptor
lookup slot for one requested tensor name: retain matched name/type/dimensions
and relative payload offset while still validating every descriptor in the
directory.
