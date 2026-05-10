# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Prepare resolved tensor descriptors for payload access by retaining the aligned
GGUF tensor-data base offset in caller-owned summary storage.

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
- The GGUF tensor-info walker accepts one caller-specified tensor name and fills
  a caller-owned lookup descriptor slot when that name is found, while still
  walking and validating every descriptor in the directory.
- The runtime currently requests `token_embd.weight`; the real target GGUF
  resolves it as a two-dimensional Q8_0 tensor with dimensions 3072 and 131072
  and relative payload offset 12288.

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

- Add a synthetic GGUF fixture proving the retained tensor-data base offset is
  the descriptor cursor rounded up to 32 bytes.
- Rebuild with `as`/`ld`.
- Keep `make check`, existing GGUF loader lookup smoke checks, future CLI usage
  rejection, static-link checks, and whitespace checks passing.
- Smoke-test the real target GGUF when the ignored local model remains present.

## Last Verification

- `make clean && make && make check` passed, printing `q8_0_dot: ok`.
- `./mistral-asm --help` returned status 0 and lists the tensor-directory
  summary with one lookup.
- Synthetic lookup fixture `/tmp/mistral_asm_lookup_found.gguf` returned status
  0, kept `first_tensor_name: other.weight`, and filled the lookup slot for
  `token_embd.weight` with dimensions 4 and 5, ggml type 8, and relative offset
  32.
- Synthetic lookup fixture `/tmp/mistral_asm_lookup_absent.gguf` returned status
  0 and left the lookup slot at the zero/default state.
- Synthetic lookup fixture `/tmp/mistral_asm_lookup_malformed_later.gguf`
  returned status 3 with the misaligned tensor-data diagnostic even though the
  requested tensor appeared before the malformed later descriptor.
- Invoking the future prompt generation form returned the usage error with
  status 2.
- The target model is present under
  `models/unsloth-Ministral-3-3B-Instruct-2512-GGUF/Ministral-3-3B-Instruct-2512-Q8_0.gguf`;
  loading it returned status 0 and printed `lookup_tensor_found: 1`,
  `lookup_tensor_name: token_embd.weight`, `lookup_tensor_dim0: 3072`,
  `lookup_tensor_dim1: 131072`, `lookup_tensor_ggml_type: 8`, and
  `lookup_tensor_offset: 12288`.
- `readelf` reported no dynamic section and no interpreter or dynamic program
  headers.
- `git diff --check` passed.

## Next Exact Step

Extend the GGUF summary with the aligned tensor-data base offset and print it,
so the retained relative tensor offsets can be audited as file-relative payload
starts before persistent model mappings are introduced.
