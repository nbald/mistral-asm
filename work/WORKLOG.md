# WORKLOG

Durable project context. This is not a second git log. Do not record routine
commit messages, changed-file lists, or next steps that already live in git or
`work/STATE.md`.

This file is normally append-only, but explicit review commits may compact
redundant entries. Do not treat it as the primary continuation source; use
`work/STATE.md` for current state and read only the recent tail when resuming.

## 2026-05-10T11:36:12Z

- Initialized autonomous project method and durable continuation files.
- Verification evidence: shell syntax passed for the autonomous loop script.

## 2026-05-10T11:40:00Z

- Added periodic review policy and final "are you happy?" loop.
- Decision: review notes live under `work/reviews/` when they contain actionable
  findings or an explicit clean result.

## 2026-05-10T11:42:00Z

- Added operator control channel, external status scripts, and gpt-5.5/xhigh
  defaults for autonomous runs.
- Verification evidence: shell syntax passed for loop/control/status/watch
  scripts; `git diff --check` passed.

## 2026-05-10T11:43:23Z

- Review finding: `WORKLOG.md` was duplicating git by recording commit messages
  and routine next steps; `STATE.md` held a stale commit pointer.
- Decision: git is authoritative for commits and changed files; `STATE.md` is
  authoritative for next action; `WORKLOG.md` keeps only durable context.

## 2026-05-10T11:49:02Z

- Review follow-up: moved live operator instructions out of tracked files and
  into ignored `work/control/INBOX.md`.
- Decision: `work/control/README.md` is committed documentation; operator inbox
  entries are transient and must be cleared after their durable effect is
  recorded.
- Verification evidence: shell syntax passed for all scripts; `INBOX.md` is
  ignored; instruction append/clear leaves no tracked change; invalid watch
  interval fails with usage.

## 2026-05-10T11:55:32Z

- Review decision: multi-run locking is out of scope; operate one autonomous
  loop per worktree by convention.
- Follow-up: run output filenames now include nanoseconds and iteration number.
- Follow-up: after `interrupt-instruction`, a multi-iteration loop can continue
  to the next iteration only when the transient inbox is non-empty.
- Follow-up: process interruption now checks PID start metadata before signaling.
- Follow-up: non-zero Codex exits are captured with Bash `if` guards instead of
  toggling `errexit`.
- Verification evidence: shell syntax passed for all scripts; `git diff --check`
  passed; fake stale PID metadata was refused; run metadata files are ignored;
  fake `codex` tests confirmed fail-fast without inbox and continue-with-inbox
  behavior.

## 2026-05-10T12:00:46Z

- Added root README and autonomous workflow README to make project operation
  discoverable without reading every `work/` file.

## 2026-05-10T12:07:40Z

- Run fix: first autonomous iteration exposed that `setsid` lost prompt stdin.
- Follow-up: autonomous loop now passes the continuation prompt as an explicit
  CLI argument instead of relying on stdin redirection.
- Verification evidence: `bash -n scripts/autonomous-loop.sh` passed.

## 2026-05-10T12:09:55Z

- Milestone 2 verification evidence: the runtime builds from `.s` sources with
  `as`/`ld`; `readelf` reports no dynamic section and no program interpreter;
  `strace` for `--help` shows one stdout `write` followed by `exit(0)`.
- Decision: keep syscall entry points in `src/sys/` even while they are tiny, so
  the GGUF loader can add file and memory syscalls without bloating `_start`.

## 2026-05-10T12:27:40Z

- Operator decision: before adding more loader logic, the next autonomous step
  should document the ASM already produced.
- Policy: exported ASM functions need contract comments; non-obvious
  instructions and cleanup paths need intent comments; avoid comments that only
  restate the mnemonic.

## 2026-05-10T12:18:46Z

- First GGUF loader smoke path maps the input file read-only and validates only
  the fixed 24-byte header fields before unmapping.
- Decision: the early count-field guard rejects counts with the high bit set so
  later parser arithmetic can stay in a conservative signed range.
- Verification evidence: a synthetic `/tmp` GGUF v3 header fixture passed and a
  high-count fixture failed with the intended loader error; loader `strace`
  showed direct file, map, unmap, close, write, and exit syscalls.

## 2026-05-10T12:31:27Z

- Audit comment pass completed for current assembly runtime. The contracts now
  state syscall ABI ownership, register clobbers, GGUF header assumptions, and
  cleanup-path intent before parser scope grows.
- Verification evidence: rebuild passed; help output and both synthetic GGUF
  fixtures behaved as before; `readelf` still showed a static no-interpreter
  executable; syscall traces stayed within the expected direct Linux calls.

## 2026-05-10T12:40:30Z

- Metadata walking now treats GGUF metadata fields as sequential records without
  padding; tensor-data alignment is deferred until tensor infos have been walked.
- Verification evidence: synthetic fixtures covered empty metadata, mixed
  scalar/string-array metadata, truncated metadata, and unsupported metadata
  type tags. The target GGUF model file was not present locally, so no real-model
  smoke test ran in this iteration.

## 2026-05-10T12:46:14Z

- Tensor-info walking now consumes descriptor names, dimension counts, dimension
  arrays, type tags, and payload offsets with mapped-file bounds checks before
  any descriptor read.
- Decision: this step validates the GGUF default 32-byte tensor-data alignment;
  parsing a custom `general.alignment` metadata value is deferred until metadata
  capture exists.
- Operator inbox result: no GGUF model download or project `.venv` was needed
  for this parser slice; verification used small `/tmp` fixtures.

## 2026-05-10T12:50:05Z

- Milestone 4 review found no runtime purity issue: tracked runtime sources are
  assembly files and the build still uses `as`/`ld`.
- Review findings: help currently advertises prompt generation that `_start`
  rejects, and one GGUF metadata-walker comment still describes tensor-info
  walking as future work even though it is now implemented.
- Verification evidence: rebuild passed; help returned status 0; the advertised
  prompt form returned the usage error with status 2; `git diff --check` passed.

## 2026-05-10T12:52:52Z

- Review follow-up resolved the audit-facing drift: help now lists only the
  currently accepted invocations, and the metadata walker comment now describes
  the handoff to the tensor-info walker instead of calling it future work.
- Verification evidence: rebuild passed; help returned status 0; the future
  prompt form remained a usage error with status 2; runtime source search found
  no stale future-slice wording.

## 2026-05-10T12:59:19Z

- Metadata-summary output now begins with the two validated GGUF header counts:
  `tensor_count` and `metadata_kv_count`.
- Decision: the summary is caller-owned static storage in `_start`, so no
  mapped-file pointer or loader-owned lifetime escapes after `munmap`.
- Verification evidence: synthetic fixtures covered zero counts, non-zero
  decimal count output with metadata and one tensor descriptor, high-bit count
  rejection, and truncated metadata rejection. The target model file was not
  present locally.

## 2026-05-10T13:05:05Z

- Metadata capture now recognizes `general.architecture` only when the value tag
  is a GGUF string, copies it into fixed caller-owned storage, and leaves the
  field empty when the key is absent or has another type.
- Decision: long architecture values are truncated with a terminator instead of
  rejected; this keeps the narrow parser permissive for otherwise valid files
  while preserving summary-buffer bounds.
- Verification evidence: synthetic fixtures covered empty metadata, captured
  `mistral3`, one tensor plus two metadata entries, non-string skip, long-string
  truncation, high-bit count rejection, and truncated metadata rejection. The
  target GGUF model file was not present locally.

## 2026-05-10T13:10:29Z

- Metadata capture now recognizes `mistral3.context_length` when the value tag is
  a u32 or u64 scalar, widens u32 into the caller-owned u64 summary slot, and
  leaves the field at zero when the key is absent or wrong-typed.
- Verification evidence: synthetic fixtures covered empty metadata, context
  length encoded as u32 and u64, wrong-typed architecture/context skip, long
  architecture truncation, bad high-bit counts, and truncated metadata. The
  target GGUF model file was not present locally.

## 2026-05-10T13:16:00Z

- Metadata capture now recognizes `mistral3.block_count` with the same u32/u64
  scalar rules as `mistral3.context_length`, and leaves the summary value at zero
  when the key is absent or has a non-scalar type.
- Verification evidence: synthetic fixtures covered empty metadata,
  architecture plus context/block shape metadata, block count encoded as u32 and
  u64, wrong-typed block count skip, one tensor descriptor after metadata, bad
  high-bit counts, truncated metadata, and the still-rejected future prompt
  generation form. The target GGUF model file was not present locally.

## 2026-05-10T13:21:50Z

- Metadata capture now recognizes `tokenizer.ggml.tokens` when the metadata
  value is a string array, walks the array payload for bounds validation, and
  keeps only the element count as `vocab_size`.
- Decision: `vocab_size` is derived from the array header rather than token
  string contents, so no tokenizer string pointer or copied token text survives
  `munmap`.
- Verification evidence: synthetic fixtures covered empty metadata, full
  architecture/context/block/token summary output, wrong-typed token metadata
  skip, token metadata before a tensor descriptor, malformed token arrays, bad
  high-bit counts, truncated metadata, the still-rejected future prompt form,
  and static-link checks. The target GGUF model file was not present locally.

## 2026-05-10T13:30:43Z

- Tensor-info walking now snapshots only the first descriptor into caller-owned
  storage: bounded name, dimension count, ggml type, and relative payload
  offset. Remaining descriptors are still walked so later malformed entries
  cannot be hidden by a valid first descriptor.
- Decision: long first tensor names are truncated to a 95-byte payload plus NUL
  terminator, matching the fixed 96-byte summary slot instead of rejecting an
  otherwise valid descriptor.
- Verification evidence: synthetic fixtures covered empty tensor directories,
  a full two-tensor metadata summary, wrong-typed token metadata with first
  tensor capture, long-name truncation, a misaligned second tensor offset,
  truncated tensor descriptors, bad high-bit counts, malformed token arrays,
  future prompt-form rejection, and static-link checks. The target model file
  was not present locally.

## 2026-05-10T13:37:31Z

- First tensor descriptor retention now includes the raw u64 dimension values
  for up to four dimensions. The summary keeps fixed `first_tensor_dim0..3`
  fields so empty tensor directories and tensors with fewer than four dimensions
  naturally show zero-filled unused slots from the existing summary clear.
- Decision: dimension values are copied only after the full first-tensor
  dimension span is bounds-checked, preserving the previous malformed-directory
  behavior while making the retained shape auditable.
- Verification evidence: rebuild and help passed; synthetic fixtures covered
  empty tensor zero-fill, two-dimension and four-dimension first tensor output,
  metadata summary preservation, continued second-descriptor walking,
  misaligned second-offset rejection, and truncated dimension-array rejection.
  The future prompt form remained a usage error, and static-link plus whitespace
  checks passed.

## 2026-05-10T13:40:22Z

- Milestone 7 review found one correctness issue to fix before tensor payload
  reads: tensor relative offsets are checked for sign and alignment, but not for
  landing inside the mapped file after the aligned tensor-data base is known.
- Verification evidence for the finding: a 64-byte synthetic one-tensor GGUF in
  `/tmp` with aligned `first_tensor_offset: 1024` was accepted with status 0.
  The next implementation step should turn that fixture into a rejection case.

## 2026-05-10T13:47:11Z

- Tensor-directory validation now records the maximum aligned relative payload
  offset while walking descriptors, then checks it after aligning the tensor-data
  base. The check is strict: a tensor payload start must land inside the mapped
  file, not at the one-past-EOF address.
- Verification evidence: the prior beyond-file synthetic fixture now exits with
  status 3 and the malformed tensor-directory diagnostic; a valid one-tensor
  fixture with one payload byte still prints the retained tensor summary.
- The usual rebuild, help, future prompt-form rejection, static-link, and
  whitespace checks passed. The target model file was still absent locally.

## 2026-05-10T13:54:12Z

- Scalar Q8_0 math now has a one-block primitive that reads the GGML half scale,
  signed quant bytes, and 32 f32 inputs, applying the scale per element to match
  the literal dequantization rule before accumulation.
- Decision: the first verifier is a separate assembly executable, not a runtime
  CLI mode, so math fixtures can stay focused while the user-facing runtime
  remains on the GGUF summary milestone.
- Verification evidence: the no-libc verifier checked exact f32 bits for 528.0,
  -16.0, and -20.0 fixtures; the main runtime rebuilt; help, future prompt-form
  rejection, valid/malformed synthetic GGUF fixtures, static-link checks, and
  whitespace checks passed. The target model file was still absent locally.

## 2026-05-10T14:00:15Z

- Scalar Q8_0 math now includes a row/span primitive over multiple 32-value
  blocks, returning +0.0 for a zero block count and otherwise accumulating in the
  same dequantize-then-add order as the one-block routine.
- Decision: the row routine inlines the scalar block loop instead of calling the
  one-block primitive, keeping register ownership and accumulation order obvious
  before introducing a matvec loop.
- Verification evidence: the no-libc verifier now covers exact f32 bits for
  512.0 across two blocks, -20.0 with required Q8_0/f32 pointer advancement, and
  zero-block +0.0; the main runtime and GGUF smoke checks still pass. The target
  model file was still absent locally.

## 2026-05-10T14:04:44Z

- External input update: the target Unsloth Ministral 3 3B Instruct Q8_0 GGUF
  is now present locally under `models/`, which is ignored by git.
- Verification evidence: local SHA256 is
  `920163471715241a9d99367d507e2ad94d1ebc34d0d169d25e5d97a49ec72556`, matching
  the upstream Hugging Face file record used for the download.

## 2026-05-10T14:05:02Z

- Scalar Q8_0 math now includes a row-major matvec routine over multiple output
  rows sharing one f32 activation span. It delegates each row to the existing
  row dot primitive, stores f32 outputs immediately, and documents that output
  storage must not overlap unread input spans.
- Verification evidence: the no-libc verifier now checks a two-row/two-block
  matvec with exact f32 outputs 512.0 and 28.0, plus a zero-row no-write case.
  The main runtime rebuild, GGUF valid/beyond-EOF smoke fixtures, future prompt
  usage rejection, static-link checks, whitespace check, and real target-model
  GGUF summary smoke passed.

## 2026-05-10T14:16:21Z

- Tensor-info walking now fills a second, caller-owned descriptor slot when a
  requested tensor name is found. The runtime requests `token_embd.weight` as
  the first payload needed for token-ID forward setup; the slot stores a bounded
  name copy, found flag, dimension count, up to four dimensions, ggml type, and
  relative payload offset.
- Decision: the lookup match does not short-circuit the directory walk. A
  synthetic file with a valid requested tensor followed by a malformed later
  descriptor still fails validation, preserving the prior whole-directory
  malformed-file behavior.
- Verification evidence: synthetic fixtures covered lookup found on a later
  descriptor, absent lookup/default zero state, and malformed-later rejection.
  The local target GGUF resolves `token_embd.weight` as Q8_0 with dimensions
  3072 and 131072 and relative payload offset 12288.

## 2026-05-10T14:22:31Z

- The GGUF summary now retains the aligned tensor-data base offset alongside
  relative tensor offsets, so payload starts can be audited as file offsets
  without exposing mmap pointers.
- Decision: empty tensor directories keep the zero-filled data-base summary
  value because they have no tensor payload section to align.
- Verification evidence: the focused synthetic fixture ended its descriptor at
  byte 57 and printed `tensor_data_offset: 64`; lookup found/absent and
  malformed-later fixtures preserved their prior behavior. The local target
  GGUF printed data base `7882016` and `token_embd.weight` relative offset
  `12288`.

## 2026-05-10T14:28:47Z

- Scalar Q8_0 math now includes a row dequantizer that streams GGML Q8_0 blocks
  into f32 activation storage without retaining pointers. This is the primitive
  needed for turning a token embedding row into the first activation vector.
- Decision: verifier coverage compares complete expected output spans for the
  one-block and two-block dequant fixtures, not just selected elements, so
  signed byte handling and pointer advancement are both exercised exactly.
- Verification evidence: the no-libc verifier still prints `q8_0_dot: ok` and
  now covers one-block signed range-edge dequantization, two-block dequant
  pointer advancement, and zero-block no-write behavior. Clean rebuild, GGUF
  synthetic lookup/base-offset fixtures, future prompt usage rejection,
  static-link checks, whitespace check, and real target-model GGUF summary
  smoke passed.

## 2026-05-10T14:33:30Z

- Checked token embedding dequantization now treats setup mistakes as stable
  return codes: 1 for token ids outside the tensor row count, 2 for invalid row
  shape or overflow while deriving the selected row.
- Decision: the wrapper validates row shape and offset arithmetic before calling
  the row dequantizer, so rejection paths do not depend on the lower-level
  zero-block no-write behavior.
- Verification evidence: the no-libc verifier covers first-token output,
  last-token row-stride selection, out-of-range token rejection without writes,
  and invalid shape rejection without writes. Clean rebuild, GGUF synthetic
  lookup/base-offset fixtures, future prompt usage rejection, static-link
  checks, whitespace check, and real target-model GGUF summary smoke passed.

## 2026-05-10T14:39:06Z

- The loader success path now transfers mmap ownership to `_start` through a
  two-word descriptor instead of releasing the mapping before returning. Error
  paths still unmap internally, so only validated models can escape as live
  mappings.
- Decision: release is a dedicated `gguf_release_mapping` helper, not an inline
  syscall at the call site, so future payload-reading paths can share the same
  descriptor cleanup contract.
- Verification evidence: the usual rebuild/check and GGUF smoke fixtures passed.
  `strace` on a synthetic valid model showed the expected success ordering:
  `mmap`, `close`, then an explicit `munmap` from `_start`.

## 2026-05-10T14:45:37Z

- `_start` now consumes the live mapping before release for a guarded token ID 0
  embedding dequant smoke. The guard checks the retained descriptor type/shape,
  static activation-buffer capacity, offset arithmetic, and one-row mmap bounds
  before calling the checked Q8_0 token embedding helper.
- Decision: parser-focused synthetic fixtures that are not target-shaped skip
  the payload smoke and report `token0_embedding_dequant: 0`; the real target
  path reports `1`. This keeps existing loader smoke checks useful while making
  the first payload read visible in normal output.
- Verification evidence: clean rebuild and `make check` passed; lookup/base
  synthetic fixtures kept their expected statuses; the real local target printed
  the retained `token_embd.weight` dimensions 3072 by 131072 and
  `token0_embedding_dequant: 1`; `strace` showed the success path still closes
  the fd before summary output completes and releases the mmap afterward.

## 2026-05-10T14:51:04Z

- Scalar f32 RMSNorm now exists as a separate math primitive. It performs an
  auditable two-pass calculation with scalar f32 sum-of-squares accumulation,
  scalar sqrt/div for the reciprocal RMS scale, and a streamed weighted output
  pass.
- Decision: RMSNorm is linked as runtime math but is not called from `_start`
  yet. Focused fixtures cover exact-scale cases, epsilon contribution, a
  one-element row, and zero-count no-write behavior before any model-path wiring.
- Verification evidence: clean rebuild and `make check` passed with both
  `q8_0_dot: ok` and `rmsnorm: ok`; existing synthetic GGUF fixtures preserved
  their expected statuses; the real target still printed
  `token0_embedding_dequant: 1`; `strace` showed the mmap release after the real
  target smoke.

## 2026-05-10T14:57:42Z

- The tensor directory walker now retains `blk.0.attn_norm.weight` in a second
  descriptor slot while preserving the existing requested-name
  `token_embd.weight` lookup and whole-directory validation.
- Decision: this step only records and prints the RMSNorm weight descriptor.
  `_start` still does not call `rmsnorm_f32`; the next step can add payload
  bounds checks and the first guarded norm smoke as a separate reviewable change.
- Verification evidence: the real target reports the RMSNorm weight as a
  one-dimensional f32 tensor with width 3072 and relative offset 431173632; the
  token-0 embedding dequant smoke still reports success, and `strace` still
  shows the mmap released after summary output.

## 2026-05-10T15:06:39Z

- The runtime now performs a second guarded payload smoke: after token 0 is
  dequantized, `_start` validates the retained `blk.0.attn_norm.weight` as a
  one-dimensional f32 span with matching width and in-mapping bounds, then calls
  `rmsnorm_f32` into separate static output storage.
- Decision: the RMSNorm smoke depends on the embedding smoke status and width
  match, so parser-focused synthetic fixtures continue to report zero payload
  statuses instead of normalizing partial or uninitialized activation storage.
  The epsilon is temporarily fixed at 1e-5; the target GGUF contains
  `mistral3.attention.layer_norm_rms_epsilon`, which should replace the constant
  before numerical oracle comparison.
- Verification evidence: clean rebuild and `make check` passed; synthetic
  lookup/base fixtures printed `token0_attn_norm: 0`; the real local target
  printed `token0_embedding_dequant: 1` and `token0_attn_norm: 1`; `strace`
  still showed close-before-output and final `munmap`.

## 2026-05-10T15:13:52Z

- The RMSNorm smoke now uses `mistral3.attention.layer_norm_rms_epsilon` from
  GGUF metadata instead of a temporary process-local constant. The summary keeps
  a found flag and the exact f32 bit pattern.
- Decision: print the f32 value as exact hexadecimal bits for now. That avoids
  adding a float-to-decimal formatter before numerical oracle comparison, while
  still making the value auditable and directly reusable by `vmovss`.
- Verification evidence: synthetic fixtures without the key print the found
  flag as zero and keep payload smoke statuses at zero; the real local target
  prints the epsilon as `0x3727c5ac` and still completes both token-0 payload
  smokes. `strace` continues to show the live mapping released after summary
  and smoke output.

## 2026-05-10T15:20:32Z

- The tensor directory summary now retains the fixed
  `blk.0.attn_q.weight` descriptor alongside the existing embedding and
  RMSNorm descriptors. This is descriptor plumbing only; no query payload bytes
  are read yet.
- Decision: keep `attn_q` as a separate fixed descriptor slot instead of
  reusing the caller-supplied lookup slot. The embedding lookup remains the
  guarded source for token dequantization, and the first attention projection can
  be audited independently before matvec wiring.
- Verification evidence: the real local target reports `blk.0.attn_q.weight` as
  Q8_0 with dimensions 3072 by 4096 and relative offset 444555264, while the
  existing token embedding and RMSNorm smoke statuses remain 1. Synthetic parser
  fixtures keep the new descriptor absent and skip payload smokes; `strace`
  still shows the read-only mapping released after summary output.

## 2026-05-10T15:25:24Z

- The runtime now performs a third guarded payload smoke: after token 0 is
  dequantized and attention-normalized, `_start` validates
  `blk.0.attn_q.weight` as a two-dimensional Q8_0 matrix whose input width
  matches the normalized activation and whose output row count fits static
  storage, then calls the scalar Q8_0 matvec into `token0_attn_q_output`.
- Decision: the query projection status is still only a smoke gate. It proves
  the mapped matrix span is bounded and the existing scalar matvec can consume
  the real target descriptor; selected output values should be exposed before
  attaching an external numerical oracle.
- Verification evidence: clean rebuild and `make check` passed; synthetic
  parser fixtures printed `token0_attn_q_matvec: 0`; the real local target
  printed `token0_attn_q_matvec: 1`; `strace` still showed the read-only
  mapping released after summary and smoke output.

## 2026-05-10T15:30:19Z

- The query projection smoke now exposes a fixed four-word f32 bit slice from
  `token0_attn_q_output`, guarded by `token0_attn_q_matvec_status == 1`. Skipped
  synthetic payload paths still stop at the zero smoke status and do not print
  partial output storage.
- Decision: print raw f32 bits with the existing u32 hex writer instead of
  decimal floats. The next oracle step can compare exact words without adding a
  float formatter to the runtime.
- Verification evidence: the real local target printed the four guarded words
  `0xbf9945a5`, `0xbf0612bc`, `0xbe09ed5f`, and `0xbf155e8e`; `strace` showed
  those lines before the final `munmap`.

## 2026-05-10T15:37:07Z

- Added verification-only oracle tooling for the token-0 first attention query
  projection. It parses the ignored target GGUF directly, applies the same
  scalar f32 rounding order as the assembly smoke path, and computes only the
  first four query rows needed for the current milestone check.
- Decision: keep the oracle under `work/oracle/` and outside the build. It uses
  Python and numpy as external comparison tooling only; runtime source and build
  inputs remain pure `.s`, `as`, and `ld`.
- Verification evidence: the oracle printed `0xbf9945a5`, `0xbf0612bc`,
  `0xbe09ed5f`, and `0xbf155e8e`, exactly matching the runtime slice. Rebuild,
  no-libc harnesses, static-link inspection, synthetic GGUF checks, real-model
  smoke, cleanup tracing, and whitespace checks also passed.

## 2026-05-10T15:43:51Z

- The tensor directory summary now retains the fixed
  `blk.0.attn_k.weight` descriptor alongside the existing embedding, attention
  RMSNorm, and query projection descriptors. This step is descriptor plumbing
  only; no key payload bytes are read yet.
- Decision: keep the key descriptor in its own summary slot immediately after
  the query descriptor and before the RMSNorm epsilon fields, matching the
  fixed-slot pattern already used for the query descriptor.
- Verification evidence: the real local target reports `blk.0.attn_k.weight` as
  Q8_0 with dimensions 3072 by 1024 and relative offset 427831296, while the
  existing embedding, RMSNorm, and query smoke statuses remain 1 and the query
  oracle words still match. Synthetic parser fixtures keep the key descriptor
  absent and skip payload smokes; cleanup tracing still shows the read-only mmap
  released after summary output.

## 2026-05-10T15:48:38Z

- The runtime now performs a fourth guarded payload smoke: after token 0 is
  dequantized and attention-normalized, `_start` validates
  `blk.0.attn_k.weight` as a two-dimensional Q8_0 matrix whose input width
  matches the normalized activation and whose 1024 output rows fit static
  storage, then calls the scalar Q8_0 matvec.
- Decision: this step prints only `token0_attn_k_matvec`. Key output words and
  oracle comparison should follow as separate reviewable changes, mirroring the
  query projection sequence.
- Verification evidence: clean rebuild and no-libc harnesses passed; synthetic
  parser fixtures printed `token0_attn_k_matvec: 0`; the real local target
  printed `token0_attn_k_matvec: 1`; the query projection oracle still matched
  the runtime query slice; cleanup tracing still showed the read-only mmap
  released after smoke output.

## 2026-05-10T15:52:06Z

- The key projection smoke now exposes a fixed four-word f32 bit slice from
  `token0_attn_k_output`, guarded by `token0_attn_k_matvec_status == 1`.
  Synthetic payload skips still print only the zero smoke status and no key
  output words.
- Verification evidence: the real local target printed key output words
  `0xc028a3e3`, `0x3daaeb62`, `0xbe8a8c69`, and `0xc01d0994`; cleanup tracing
  showed those lines before the final `munmap`.

## 2026-05-10T15:56:04Z

- Added verification-only oracle tooling for the token-0 first attention key
  projection. It reuses the direct GGUF parser and scalar f32 helper path from
  the query oracle, then targets `blk.0.attn_k.weight`.
- Decision: keep this as a separate key script and note, while sharing helper
  functions from the existing query oracle. The runtime and build remain pure
  assembly; Python and numpy are external verification tools only.
- Verification evidence: the key oracle printed `0xc028a3e3`, `0x3daaeb62`,
  `0xbe8a8c69`, and `0xc01d0994`, exactly matching the runtime key slice.
  Rebuild, no-libc harnesses, CLI/static checks, synthetic GGUF checks,
  real-model smoke, cleanup tracing, query/key oracles, and whitespace checks
  passed.

## 2026-05-10T16:01:52Z

- The tensor directory summary now retains and prints the fixed
  `blk.0.attn_v.weight` descriptor alongside the existing attention query and
  key descriptors. This is descriptor plumbing only; value-projection payload
  bytes are still untouched.
- Decision: keep the value descriptor in its own fixed 160-byte summary slot
  after the key descriptor, shifting the RMSNorm epsilon summary fields after
  the complete Q/K/V descriptor group.
- Verification evidence: synthetic fixtures keep `attn_v_tensor_found: 0` and
  skip all payload smokes; the real local target reports `blk.0.attn_v.weight`
  as Q8_0 with dimensions 3072 by 1024 and relative offset 457924608. Existing
  query/key smoke words stayed unchanged, and cleanup tracing still shows the
  live read-only mmap released after summary and smoke output.

## 2026-05-10T16:06:48Z

- The runtime now performs the guarded value-projection payload smoke: after
  token 0 is dequantized and attention-normalized, `_start` validates
  `blk.0.attn_v.weight` as a two-dimensional Q8_0 matrix with matching input
  width and bounded 1024-row output storage, then calls the scalar Q8_0 matvec
  into `token0_attn_v_output`.
- Decision: this step prints only `token0_attn_v_matvec`. Value output words and
  oracle comparison should follow as separate reviewable changes, matching the
  earlier query/key sequence.
- Verification evidence: clean rebuild and no-libc harnesses passed; synthetic
  parser fixtures printed `token0_attn_v_matvec: 0`; the real local target
  printed `token0_attn_v_matvec: 1`; existing query/key oracle words still
  matched the runtime slices; cleanup tracing still showed the read-only mmap
  released after smoke output.

## 2026-05-10T16:11:16Z

- The value projection smoke now exposes a fixed four-word f32 bit slice from
  `token0_attn_v_output`, guarded by `token0_attn_v_matvec_status == 1`.
  Synthetic payload skips still print only the zero value smoke status and no
  value output words.
- Verification evidence: the real local target printed value output words
  `0x3ca3b3bc`, `0x3c9bf3e4`, `0x3c29a3e4`, and `0xbb17585e`; cleanup tracing
  showed those lines before the final `munmap`. Existing query/key oracle words
  still matched their runtime slices exactly.

## 2026-05-10T16:15:20Z

- Added verification-only oracle tooling for the token-0 first attention value
  projection. It reuses the direct GGUF parser and scalar f32 helper path from
  the query oracle, then targets `blk.0.attn_v.weight`.
- Decision: keep the value oracle as a separate script and note to mirror the
  query/key checks. The runtime and build remain pure assembly; Python and numpy
  are external verification tools only.
- Verification evidence: the value oracle printed `0x3ca3b3bc`,
  `0x3c9bf3e4`, `0x3c29a3e4`, and `0xbb17585e`, exactly matching the runtime
  value slice. Rebuild, no-libc harnesses, CLI/static checks, synthetic GGUF
  checks, real-model smoke, cleanup tracing, query/key/value oracles, and
  whitespace checks passed.

## 2026-05-10T16:22:35Z

- The tensor directory summary now retains and prints the fixed
  `blk.0.attn_output.weight` descriptor after the Q/K/V descriptor group. This
  is descriptor plumbing only; no output-projection payload bytes are read.
- Decision: keep the output descriptor in the same 160-byte fixed-slot format as
  the existing first-layer attention descriptors, and shift the RMSNorm epsilon
  fields after it so the summary remains a simple linear ABI between the loader
  and `_start`.
- Verification evidence: synthetic fixtures report `attn_output_tensor_found: 0`
  and still skip payload smokes; the real local target reports Q8_0 dimensions
  4096 by 3072 at relative offset 431185920. Existing Q/K/V output words stayed
  unchanged, and cleanup tracing still shows the read-only mapping released
  after summary and smoke output.

## 2026-05-10T16:26:55Z

- The runtime now derives a guarded token-0 single-token attention context from
  the value projection without reading `blk.0.attn_output.weight` payload bytes.
  The context helper treats the one-token softmax as 1, repeats each 128-f32 KV
  value-head block across its four query heads, and writes the resulting
  4096-f32 context into static storage.
- Decision: guard the status with the retained output projection descriptor's
  shape, but keep that descriptor read-only metadata for this step. This proves
  the context width is suitable for the next output-projection smoke while
  preserving the no-payload-read boundary.
- Verification evidence: synthetic fixtures kept `token0_attn_context: 0`; the
  real local target printed `token0_attn_context: 1` and unchanged Q/K/V oracle
  words; cleanup tracing still showed `close(3)` before final `munmap`.

## 2026-05-10T16:30:54Z

- The runtime now prints a guarded four-word exact-hex slice from
  `token0_attn_context` after the context smoke succeeds. Synthetic fixtures
  with no retained output descriptor still print only `token0_attn_context: 0`
  and no context word slice.
- Decision: this is still a descriptor-only step for
  `blk.0.attn_output.weight`; the new output reads only static context storage
  already produced by the value-projection expansion.
- Verification evidence: the real local target printed context words
  `0x3ca3b3bc`, `0x3c9bf3e4`, `0x3c29a3e4`, and `0xbb17585e`, exactly matching
  the first four `token0_attn_v_output` words. Cleanup tracing showed those
  lines before the final `munmap`, and the external Q/K/V oracle words still
  matched their runtime slices.

## 2026-05-10T16:37:22Z

- The runtime now performs the guarded output-projection payload smoke:
  `token0_attn_context_status` must be set, `blk.0.attn_output.weight` must be
  the exact 4096x3072 Q8_0 matrix, and the resolved matrix bytes must fit inside
  the live mapping before the scalar Q8_0 matvec writes `token0_attn_output`.
- Decision: print only `token0_attn_output_matvec` in this step. Output words
  and an external oracle comparison remain separate changes so the first payload
  read through this tensor is reviewable on its own.
- Verification evidence: narrow synthetic fixtures still skip with status 0,
  the real target printed `token0_attn_output_matvec: 1`, cleanup tracing showed
  the line before final `munmap`, and the existing Q/K/V oracle word checks
  still matched the runtime slices.

## 2026-05-10T16:40:35Z

- The output-projection smoke now exposes a guarded four-word f32 bit slice from
  `token0_attn_output`, printed only when `token0_attn_output_matvec_status` is
  1. Synthetic parser fixtures still skip the slice when the output projection
  is unavailable.
- Verification evidence: the real local target printed output words
  `0xbd553ed5`, `0xbe2c4b4d`, `0x3f7c2d02`, and `0x3d799d1a`; cleanup tracing
  showed those words before the final `munmap`. The next durable comparison
  should be an external oracle note for these words.

## 2026-05-10T16:46:23Z

- Added verification-only oracle tooling for the token-0 attention output
  projection. It recomputes token 0 through attention RMSNorm, all value rows,
  the grouped-query context expansion, and the first four output projection
  rows outside the runtime.
- Decision: keep this as external Python/numpy tooling under `work/oracle/`.
  The runtime and build remain pure assembly, and no runtime files changed.
- Verification evidence: the new oracle matched the runtime context words
  `0x3ca3b3bc`, `0x3c9bf3e4`, `0x3c29a3e4`, and `0xbb17585e`, plus output
  words `0xbd553ed5`, `0xbe2c4b4d`, `0x3f7c2d02`, and `0x3d799d1a`.
  Rebuild, no-libc harnesses, CLI/static checks, synthetic GGUF checks,
  real-model smoke, cleanup tracing, and whitespace checks passed.

## 2026-05-10T16:52:38Z

- The runtime now derives the first post-attention residual for token 0 by
  adding the retained token embedding activation and the retained attention
  output projection into a new 3072-f32 static buffer. The helper is static-only:
  it adds no tensor descriptor or mmap payload reads.
- Decision: guard the residual add on both predecessor smoke statuses and the
  exact 3072-f32 embedding width, because earlier embedding smokes intentionally
  tolerate narrow synthetic fixtures.
- Verification evidence: synthetic fixtures kept `token0_post_attn_residual: 0`
  with no residual word slice, while the real local target printed status 1 and
  residual words `0xbd41a6d5`, `0xbe4a334d`, `0x3f822e41`, and `0x3d7fcd1a`.
  Cleanup tracing still showed `close(3)` before final `munmap`.

## 2026-05-10T16:58:22Z

- Added verification-only oracle tooling for the token-0 post-attention
  residual. It recomputes token 0 through the existing attention output path
  outside the runtime, then applies the same f32 add between token embedding
  activation and attention output that the assembly smoke uses.
- Decision: keep the residual oracle separate from the attention-output oracle
  because it checks a new graph boundary while sharing the lower-level parser
  and scalar arithmetic helpers.
- Verification evidence: the residual oracle printed `0xbd41a6d5`,
  `0xbe4a334d`, `0x3f822e41`, and `0x3d7fcd1a`, exactly matching the runtime
  residual slice. Rebuild, no-libc harnesses, CLI/static checks, synthetic
  GGUF checks, real-model smoke, cleanup tracing, oracle py-compile, and
  whitespace checks passed.

## 2026-05-10T17:03:55Z

- The tensor directory summary now retains and prints the fixed
  `blk.0.ffn_norm.weight` descriptor after the attention output descriptor.
  This is descriptor plumbing only; the runtime does not read FFN norm payload
  bytes in this step.
- Decision: extend the existing fixed 160-byte descriptor-slot pattern and shift
  the attention RMSNorm epsilon fields after the new slot, keeping the summary a
  simple linear ABI between the loader and `_start`.
- Verification evidence: narrow synthetic fixtures printed
  `ffn_norm_tensor_found: 0`; the real local target printed the FFN norm as f32
  `[3072]` at relative offset 521428992 while preserving the existing token-0
  attention and residual exact-hex slices. Cleanup tracing still showed the
  read-only mapping released after summary and smoke output.

## 2026-05-10T17:08:07Z

- The runtime now runs a guarded token-0 FFN RMSNorm smoke from
  `token0_post_attn_residual` through the retained `blk.0.ffn_norm.weight`
  descriptor. The new gate requires the residual status, captured RMSNorm
  epsilon, f32 `[3072]` descriptor shape, and a bounded mapped payload span
  before `rmsnorm_f32` writes static FFN-normalized activation storage.
- Decision: print only `token0_ffn_norm` in this step. The first exact-hex FFN
  norm words and external oracle note remain separate so the first payload read
  and first public value slice stay independently reviewable.
- Verification evidence: narrow synthetic fixtures kept the new status at 0;
  the real local target printed `token0_ffn_norm: 1` while preserving existing
  Q/K/V/output/residual slices. Cleanup tracing still showed `close(3)` before
  the final `munmap`.

## 2026-05-10T17:11:40Z

- The runtime now prints a guarded four-word exact-hex slice from
  `token0_ffn_norm_activation` after `token0_ffn_norm_status` is 1. The FFN
  RMSNorm smoke and shared math helper were left unchanged.
- Verification evidence: narrow synthetic fixtures kept `token0_ffn_norm: 0`
  with no FFN norm word slice. The real local target printed FFN norm words
  `0xc01a392c`, `0xc116e478`, `0x416e11b8`, and `0x3fe0d866`; merged cleanup
  tracing showed those lines before the final `munmap`.

## 2026-05-10T17:17:45Z

- Added external FFN RMSNorm oracle tooling and a comparison note. The oracle
  recomputes the full 3072-word post-attention residual before RMSNorm, because
  the FFN norm scale cannot be checked from a four-word slice alone.
- Verification evidence: the oracle matched the runtime FFN norm words
  `0xc01a392c`, `0xc116e478`, `0x416e11b8`, and `0x3fe0d866`, and also matched
  the residual intermediate words. Rebuild, no-libc harnesses, CLI/static
  checks, synthetic GGUF checks, real-model smoke, cleanup tracing, oracle
  py-compile, and whitespace checks passed.

## 2026-05-10T17:24:05Z

- The tensor directory summary now retains and prints the fixed
  `blk.0.ffn_gate.weight` descriptor after the FFN RMSNorm descriptor. This is
  descriptor plumbing only; the runtime does not read FFN gate payload bytes in
  this step.
- Verification evidence: synthetic fixtures keep `ffn_gate_tensor_found: 0`;
  the real local target prints the gate projection as Q8_0 with dimensions
  `3072 x 9216` at relative offset `491347968` while preserving the existing
  FFN RMSNorm exact-hex slice. Cleanup tracing still shows the read-only mapping
  released after summary and smoke output.

## 2026-05-10T17:28:33Z

- The runtime now runs a guarded token-0 FFN gate matvec from
  `token0_ffn_norm_activation` through `blk.0.ffn_gate.weight`, requiring the
  exact Q8_0 `[3072 x 9216]` shape and a bounded full matrix span before writing
  static gate activation storage.
- Decision: keep the new public output status-only. A guarded exact-hex slice
  and oracle comparison remain separate reviewable steps, matching the previous
  projection workflow.
- Verification evidence: synthetic fixtures skipped the new gate with
  `token0_ffn_gate_matvec: 0`; the real local target printed
  `token0_ffn_gate_matvec: 1` while preserving the existing Q/K/V/output,
  residual, and FFN RMSNorm exact-hex slices. Cleanup tracing still showed
  `close(3)` before the final `munmap`.

## 2026-05-10T17:32:26Z

- The runtime now prints a guarded four-word exact-hex slice from
  `token0_ffn_gate_output` after `token0_ffn_gate_matvec_status` is 1. The FFN
  gate math and shape/bounds checks were left unchanged.
- Decision: preserve the status-only synthetic skip path. Fixtures with no real
  gate tensor still print `token0_ffn_gate_matvec: 0` and no gate output word
  labels.
- Verification evidence: the real local target printed gate output words
  `0xbf5c7417`, `0xbfa9b30c`, `0xbfecdf2f`, and `0xbfa6fe18`; merged cleanup
  tracing showed those lines between `close(3)` and the final `munmap`.

## 2026-05-10T17:38:23Z

- Added external FFN gate oracle tooling and a comparison note. The oracle
  recomputes the full token-0 path through FFN RMSNorm, then dots that
  activation with the first four `blk.0.ffn_gate.weight` rows.
- Verification evidence: the oracle printed gate output words `0xbf5c7417`,
  `0xbfa9b30c`, `0xbfecdf2f`, and `0xbfa6fe18`. A direct extraction check
  compared those four words with the runtime smoke output and matched each one
  exactly. Rebuild, no-libc harnesses, CLI/static checks, synthetic GGUF checks,
  real-model smoke, cleanup tracing, oracle py-compile, and whitespace checks
  passed.

## 2026-05-10T17:45:39Z

- The tensor directory summary now retains and prints the fixed
  `blk.0.ffn_up.weight` descriptor after the FFN gate descriptor. This is
  descriptor plumbing only; the runtime does not read FFN up payload bytes in
  this step.
- Verification evidence: synthetic fixtures kept `ffn_up_tensor_found: 0`; the
  real local target printed the FFN up projection as Q8_0 with dimensions
  `3072 x 9216` at relative offset `521441280` while preserving existing token0
  exact-hex slices. A Python parser cross-check reported the same descriptor,
  and cleanup tracing still showed `close(3)` before final `munmap`.

## 2026-05-10T17:49:06Z

- The runtime now runs a guarded token-0 FFN up matvec from
  `token0_ffn_norm_activation` through `blk.0.ffn_up.weight`, requiring the
  exact Q8_0 `[3072 x 9216]` shape and a bounded full matrix span before writing
  static FFN up activation storage.
- Decision: keep this step status-only, matching the earlier FFN gate workflow.
  A public exact-hex slice and oracle comparison remain separate reviewable
  steps.
- Verification evidence: synthetic fixtures skipped both FFN projections with
  status 0, while the real local target printed `token0_ffn_up_matvec: 1` and no
  FFN up exact-hex words. Existing Q/K/V/output/residual/FFN RMSNorm/FFN gate
  exact slices were preserved, and cleanup tracing still showed `close(3)`
  before the final `munmap`.

## 2026-05-10T17:52:27Z

- The runtime now prints a guarded four-word exact-hex slice from
  `token0_ffn_up_output` after `token0_ffn_up_matvec_status` is 1. The FFN up
  matvec math and descriptor/bounds gates were left unchanged.
- Verification evidence: synthetic fixtures kept `token0_ffn_up_matvec: 0`
  with no FFN up output word labels. The real local target printed FFN up words
  `0x3f641d75`, `0x3f60c9d6`, `0x3f65a149`, and `0x3f1ee2f1`; merged cleanup
  tracing showed those lines before the final `munmap`.

## 2026-05-10T17:58:38Z

- Added external FFN up oracle tooling and a comparison note. The oracle
  recomputes the full token-0 path through FFN RMSNorm, then dots that
  activation with the first four `blk.0.ffn_up.weight` rows.
- Verification evidence: the oracle printed FFN up output words
  `0x3f641d75`, `0x3f60c9d6`, `0x3f65a149`, and `0x3f1ee2f1`. A direct
  extraction check compared those four words with the runtime smoke output and
  matched each one exactly. Rebuild, no-libc harnesses, CLI/static checks,
  synthetic GGUF checks, real-model smoke, cleanup tracing, oracle py-compile,
  and whitespace checks passed.

## 2026-05-10T18:06:19Z

- The tensor directory summary now retains and prints the fixed
  `blk.0.ffn_down.weight` descriptor after the FFN up descriptor. This is still
  descriptor plumbing only; the runtime does not read FFN down payload bytes in
  this step.
- Verification evidence: synthetic fixtures kept `ffn_down_tensor_found: 0`;
  the real local target printed the FFN down projection as Q8_0 with dimensions
  `9216 x 3072` at relative offset `461266944`. A Python parser cross-check
  reported the same descriptor, and cleanup tracing still showed `close(3)`
  before final `munmap`.

## 2026-05-10T18:13:21Z

- The runtime now computes a guarded token-0 FFN SwiGLU activation into static
  f32 storage after the gate and up projections succeed. The activation is
  guarded by the retained FFN down descriptor so the produced 9216-f32 row is
  known to match the next projection's input width.
- Decision: keep the new runtime output status-only. The scalar helper uses
  x87 exponentiation and separate positive/negative forms for `silu(x)` to avoid
  avoidable overflow while the exact public slice and oracle comparison remain
  separate reviewable steps.
- Verification evidence: the new no-libc SwiGLU harness passed. Synthetic
  fixtures skipped the activation with status 0, while the real local target
  printed `token0_ffn_swiglu: 1` and preserved existing exact-hex slices through
  FFN up. Cleanup tracing still showed `close(3)` before final `munmap`.

## 2026-05-10T18:17:43Z

- The runtime now prints a guarded four-word exact-hex slice from
  `token0_ffn_swiglu_output` after `token0_ffn_swiglu_status` is 1. The SwiGLU
  math, shape checks, and descriptor guards were left unchanged.
- Verification evidence: synthetic fixtures kept `token0_ffn_swiglu: 0` with no
  SwiGLU output word labels. The real local target printed SwiGLU words
  `0xbe697324`, `0xbe7a2af9`, `0xbe66d77d`, and `0xbe30ee21`; a direct
  float32 calculation from the printed gate/up words matched all four bits.
  Cleanup tracing still showed `close(3)` before final `munmap`.

## 2026-05-10T18:25:06Z

- Added external token-0 FFN SwiGLU oracle tooling and a comparison note. The
  oracle recomputes the existing path through FFN norm, gate, and up, verifies
  the FFN down descriptor guard, then applies `silu(gate) * up` for the first
  four activation words.
- Verification evidence: the oracle printed SwiGLU words `0xbe697324`,
  `0xbe7a2af9`, `0xbe66d77d`, and `0xbe30ee21`. A direct extraction check
  compared runtime FFN norm, gate, up, and SwiGLU slices with the oracle output
  exactly. Rebuild, no-libc harnesses, CLI/static checks, synthetic GGUF checks,
  real-model cleanup tracing, oracle py-compile, and whitespace checks passed.

## 2026-05-10T18:30:43Z

- The runtime now computes a guarded status-only token-0 FFN down matvec from
  `token0_ffn_swiglu_output` through `blk.0.ffn_down.weight`, writing the 3072
  f32 result row into static storage only after the SwiGLU prerequisite, exact
  Q8_0 `[9216 x 3072]` shape, and full matrix bounds checks pass.
- Decision: keep this step status-only. The public exact-hex FFN down slice and
  oracle comparison remain separate reviewable steps, matching the gate/up
  projection workflow.
- Verification evidence: synthetic fixtures skipped the new projection with
  `token0_ffn_down_matvec: 0`, while the real local target printed
  `token0_ffn_down_matvec: 1` and preserved the existing SwiGLU words. Cleanup
  tracing still showed `close(3)` before the final `munmap`.

## 2026-05-10T18:34:33Z

- The runtime now prints a guarded four-word exact-hex slice from
  `token0_ffn_down_output` after `token0_ffn_down_matvec_status` is 1. The FFN
  down matvec math, descriptor guards, and bounds checks were left unchanged.
- Verification evidence: synthetic fixtures kept `token0_ffn_down_matvec: 0`
  with no FFN down output word labels. The real local target printed FFN down
  words `0xbde9febc`, `0xbec5ccf0`, `0x3ffe1c83`, and `0xbe862464`; cleanup
  tracing showed those lines before the final `munmap`.

## 2026-05-10T18:44:06Z

- Added external FFN down oracle tooling and a comparison note. The oracle
  recomputes the full token-0 path through FFN norm, all 9216 FFN gate/up rows,
  the full SwiGLU activation, and the first four `blk.0.ffn_down.weight` rows.
- Verification evidence: the exact scalar oracle took 2:45.27 and printed FFN
  down words `0xbde9febc`, `0xbec5ccf0`, `0x3ffe1c83`, and `0xbe862464`. A
  direct extraction check matched runtime and oracle FFN norm, gate, up,
  SwiGLU, and down slices exactly. Rebuild, no-libc harnesses, CLI/static
  checks, synthetic GGUF checks, real-model cleanup tracing, oracle py-compile,
  runtime purity, and whitespace checks passed.

## 2026-05-10T18:48:13Z

- The runtime now computes a guarded status-only token-0 post-FFN residual by
  adding `token0_post_attn_residual` and `token0_ffn_down_output` into separate
  static storage after the FFN down projection succeeds.
- Decision: keep this step status-only. The public exact-hex slice and oracle
  comparison remain separate reviewable steps, matching the projection workflow.
- Verification evidence: synthetic fixtures skipped the new residual with
  status 0, while the real local target printed `token0_post_ffn_residual: 1`
  and preserved the FFN down exact words. Cleanup tracing still showed
  `close(3)` before the final `munmap`.

## 2026-05-10T18:52:20Z

- The runtime now prints a guarded four-word exact-hex slice from
  `token0_post_ffn_residual` after `token0_post_ffn_residual_status` is 1. The
  residual math and prerequisite guards were left unchanged.
- Verification evidence: synthetic fixtures kept `token0_post_ffn_residual: 0`
  with no post-FFN residual word labels. The real local target printed post-FFN
  residual words `0xbe256913`, `0xbf15734b`, `0x40402562`, and `0xbe4c5582`;
  a direct float32 add check from the printed post-attention residual and FFN
  down words matched all four bits. Cleanup tracing still showed `close(3)`
  before the final `munmap`.

## 2026-05-10T18:59:08Z

- Added external post-FFN residual oracle tooling and a comparison note. The
  script reuses the full FFN down oracle path, exposes the already-computed
  post-attention residual slice, and applies the same f32-rounded residual add
  as the runtime.
- Verification evidence: the oracle printed post-FFN residual words
  `0xbe256913`, `0xbf15734b`, `0x40402562`, and `0xbe4c5582`. A real-model
  extraction check matched the oracle's post-attention residual, FFN down, and
  post-FFN residual slices exactly. Rebuild, no-libc harnesses, CLI/static
  checks, synthetic GGUF checks, cleanup tracing, oracle py-compile, runtime
  purity, and whitespace checks passed.

## 2026-05-10T19:03:30Z

- Reviewed the token-0 layer-0 forward smoke chain through post-FFN residual
  before adding layer iteration. The review found no issue in the FFN math order
  or mmap bounds checks, but did find that attention Q/K/V public slices can be
  emitted after partial-row synthetic projection successes. The next source
  step should tighten those guards before broader feature work.
- Verification evidence: rebuild and no-libc harnesses passed; CLI/static
  checks, synthetic GGUF checks, real-model cleanup tracing, oracle py-compile,
  runtime purity, tracked-artifact scan, and whitespace checks passed. External
  oracle scripts were not rerun because this was a docs-only review step.

## 2026-05-10T19:10:30Z

- Tightened the Q/K/V smoke success meaning after the token-0 forward review:
  public attention projection slices are now status-gated on exact target row
  counts rather than any positive bounded row count. The entry-point contract
  now reaches the guarded post-FFN residual add.
- Verification evidence: a disposable partial-row Q/K/V GGUF reached embedding
  dequantization and attention RMSNorm successfully, then reported Q/K/V matvec
  statuses of 0 and emitted no Q/K/V slice labels. The real target still
  reported Q/K/V status 1 and preserved the recorded post-FFN residual words.
  Rebuild, no-libc harnesses, CLI/static checks, synthetic malformed checks,
  cleanup tracing, oracle py-compile, runtime purity, tracked-artifact scan,
  and whitespace checks passed.

## 2026-05-10T19:15:44Z

- The GGUF summary now retains the tensor-info directory start offset returned
  by the metadata walker and prints it before the aligned tensor-data base. The
  field was appended after the existing summary layout so all retained tensor
  descriptor offsets stayed stable.
- Verification evidence: an empty synthetic GGUF printed
  `tensor_infos_offset: 24` with no tensor-data section, while the local target
  printed `tensor_infos_offset: 7867981` and `tensor_data_offset: 7882016`.
  The real-model token-0 post-FFN residual words were unchanged, and cleanup
  tracing still showed successful `close(3)` before final `munmap`.

## 2026-05-10T19:23:22Z

- Added a reusable GGUF tensor lookup helper with a generic 160-byte descriptor
  slot ABI. It intentionally remains off the token-0 math path; the next
  runtime step can use it for later-layer descriptor smoke coverage without
  extending the fixed summary layout.
- Verification evidence: the new assembly harness found a second descriptor,
  proved absent-name calls clear stale slot contents, and rejected an unaligned
  relative payload offset with the tensor-alignment status. Full rebuild,
  harness checks, CLI/static checks, synthetic GGUF checks, real-model cleanup
  tracing, oracle py-compile, runtime purity, tracked-artifact scan, and
  whitespace checks passed. The real-model post-FFN residual words were
  unchanged, so external oracle scripts were not rerun.

## 2026-05-10T19:29:24Z

- Wired the reusable lookup helper into the runtime as a non-math later-layer
  descriptor smoke. It captures `blk.1.attn_norm.weight` into separate scratch
  storage, prints found/dimension/type/offset fields, and does not feed the
  token-0 layer-0 math path.
- Verification evidence: an empty synthetic GGUF printed zeroed layer-1 lookup
  fields; the real target printed one dimension of `3072`, type `0`, and
  relative offset `554864640`. A Python parser cross-check reported the same
  descriptor, and the post-FFN residual exact words stayed unchanged.

## 2026-05-10T19:35:49Z

- Added the first layer-1 math smoke: `blk.1.attn_norm.weight` now normalizes
  `token0_post_ffn_residual` into separate static storage and prints only a
  status flag. The output bytes remain private until the next exact-hex slice
  step.
- Verification evidence: an empty valid GGUF stayed status-only with
  `token0_layer1_attn_norm: 0`, while the real local target printed
  `token0_layer1_attn_norm: 1` and preserved the recorded post-FFN residual
  words. Rebuild, no-libc harnesses, CLI/static checks, malformed synthetic
  checks, cleanup tracing, oracle py-compile, runtime purity, tracked-artifact
  scan, and whitespace checks passed.

## 2026-05-10T19:39:36Z

- Published the first four raw f32 words of the token-0 layer-1 attention
  RMSNorm activation behind the existing status gate. This intentionally stops
  short of external oracle comparison so the next step can review the oracle
  path separately.
- Verification evidence: the empty valid synthetic GGUF printed
  `token0_layer1_attn_norm: 0` and no layer-1 exact-hex labels. The real local
  target printed layer-1 words `0xc05ae197`, `0xc1210d34`, `0x426154e8`, and
  `0xc0a7934a`; cleanup tracing still showed `close(3)` before final `munmap`.

## 2026-05-10T19:51:31Z

- Added external layer-1 attention RMSNorm oracle tooling and a comparison note.
  The post-FFN residual oracle path now has an exact full-row mode for later
  consumers while preserving its default four-word public output.
- Verification evidence: the layer-1 oracle matched the runtime's post-FFN
  residual slice and layer-1 attention RMSNorm slice exactly:
  `0xc05ae197`, `0xc1210d34`, `0x426154e8`, and `0xc0a7934a`. Rebuild,
  no-libc harnesses, CLI/static checks, synthetic GGUF checks, real-model
  cleanup tracing, oracle py-compile, runtime purity, and exact runtime
  extraction passed.

## 2026-05-10T19:57:28Z

- Added a second reusable later-layer descriptor smoke for
  `blk.1.attn_q.weight`. It deliberately stops at descriptor capture and
  printed summary fields; no layer-1 query projection payload bytes are read by
  this step.
- Verification evidence: empty synthetic GGUF input printed zeroed layer-1 query
  descriptor fields while keeping later math statuses at 0. The real local
  target printed a Q8_0 descriptor with dimensions `3072x4096` and relative
  offset `568246272`, matching the external GGUF parser. Existing post-FFN and
  layer-1 attention RMSNorm exact words stayed unchanged, and cleanup tracing
  still showed `close(3)` before the final `munmap`.

## 2026-05-10T20:01:20Z

- Added the status-only layer-1 query projection smoke. It consumes the private
  layer-1 attention RMSNorm activation, checks the reusable
  `blk.1.attn_q.weight` descriptor for exact `3072x4096` Q8_0 shape, bounds the
  full mapped payload, and writes a private output buffer without publishing
  output words yet.
- Verification evidence: the empty synthetic GGUF printed
  `token0_layer1_attn_q_matvec: 0`, while the real local target printed
  `token0_layer1_attn_q_matvec: 1`. The recorded post-FFN residual and layer-1
  attention RMSNorm exact words stayed unchanged, and cleanup tracing still
  showed `close(3)` before the final `munmap`.

## 2026-05-10T20:04:49Z

- Published the first four raw f32 words of the token-0 layer-1 query
  projection behind the existing `token0_layer1_attn_q_matvec` status gate. This
  keeps the assembly change separate from the external oracle comparison.
- Verification evidence: the empty valid synthetic GGUF kept
  `token0_layer1_attn_q_matvec: 0` and emitted no new query-output labels. The
  real local target printed layer-1 query words `0x3f98c6d6`, `0x3e72aeb6`,
  `0x3e641287`, and `0x3e76b8f1`; cleanup tracing still showed `close(3)`
  before the final `munmap`.

## 2026-05-10T20:12:58Z

- Added external layer-1 attention query oracle tooling. It reuses the full
  layer-1 attention RMSNorm activation from the previous oracle path, then dots
  that activation against the first four rows of `blk.1.attn_q.weight` using the
  same scalar Q8_0 f32 accumulation order as the assembly matvec helper.
- Verification evidence: the oracle produced `0x3f98c6d6`, `0x3e72aeb6`,
  `0x3e641287`, and `0x3e76b8f1` for the public layer-1 query words, matching
  the current runtime labels exactly. The prerequisite post-FFN residual and
  layer-1 attention RMSNorm words stayed unchanged, and the assembly harnesses
  still passed.

## 2026-05-10T20:22:46Z

- Added descriptor-only runtime coverage for `blk.1.attn_k.weight` in its own
  reusable lookup slot. This deliberately does not read key projection payload
  bytes and leaves the layer-1 query matvec path wired to the existing query
  descriptor slot.
- Verification evidence: the empty synthetic GGUF printed zeroed layer-1 key
  descriptor fields. The real target printed the key descriptor as Q8_0
  `3072x1024` at relative offset `551522304`, matching an external parser
  check, while the existing layer-1 query output words stayed unchanged.

## 2026-05-10T20:27:11Z

- Added the status-only layer-1 key projection smoke. It reuses the private
  layer-1 attention RMSNorm activation and `blk.1.attn_k.weight` descriptor,
  requires exact Q8_0 `3072x1024` shape, bounds the complete mapped payload, and
  writes only private static output storage.
- Verification evidence: the real target printed status 1 for
  `token0_layer1_attn_k_matvec`, while a temporary empty valid GGUF kept it at
  0. Existing layer-1 RMSNorm and query output words stayed unchanged, no
  layer-1 key output labels were emitted, cleanup tracing still showed
  `close(3)` before final `munmap`, and the build, harness, oracle py-compile,
  runtime purity, artifact, and whitespace checks passed.

## 2026-05-10T20:30:34Z

- Published the first four raw f32 words of the token-0 layer-1 key projection
  behind the existing `token0_layer1_attn_k_matvec` status gate. This mirrors
  the query projection exposure and intentionally leaves external oracle
  comparison to the next step.
- Verification evidence: the real local target printed key words `0x3fb2a129`,
  `0x405dbdbe`, `0x3f5611d3`, and `0x3f1e325d`. The empty valid synthetic GGUF
  kept the layer-1 norm/query/key gates at 0 and emitted no layer-1 output
  labels; rebuild, no-libc harnesses, cleanup tracing, oracle py-compile,
  runtime purity, static-link, tracked-artifact, and whitespace checks passed.

## 2026-05-10T20:38:15Z

- Added external layer-1 attention key oracle tooling. It reuses the full
  layer-1 attention RMSNorm activation from the prior oracle path, then dots
  that activation against the first four rows of `blk.1.attn_k.weight` with the
  same scalar Q8_0 f32 accumulation order as the assembly matvec helper.
- Verification evidence: the oracle produced `0x3fb2a129`, `0x405dbdbe`,
  `0x3f5611d3`, and `0x3f1e325d` for the public layer-1 key words, matching the
  current runtime labels exactly. The assembly harnesses, oracle py-compile,
  runtime purity, static-link, tracked-artifact, and whitespace checks passed.

## 2026-05-10T20:42:42Z

- Added descriptor-only runtime coverage for `blk.1.attn_v.weight` in its own
  reusable lookup slot. The step intentionally stops before any layer-1 value
  projection payload read.
- Verification evidence: the real target printed the value descriptor as Q8_0
  `3072x1024` at relative offset `581615616`, matching an external descriptor
  parser. A temporary empty valid GGUF left the layer-1 query/key/value
  descriptor slots zeroed and kept the existing layer-1 math gates at 0. Existing
  layer-1 query/key output words stayed unchanged, and build, harness, oracle
  py-compile, runtime purity, static-link, tracked-artifact, help, and whitespace
  checks passed.

## 2026-05-10T20:46:38Z

- Added the status-only layer-1 value projection smoke. It reuses the private
  layer-1 attention RMSNorm activation and `blk.1.attn_v.weight` descriptor,
  requires exact Q8_0 `3072x1024` shape, bounds the complete mapped payload, and
  writes only private static output storage.
- Verification evidence: the real target printed
  `token0_layer1_attn_v_matvec: 1`, while a temporary empty valid GGUF kept it
  at 0. No
  `token0_layer1_attn_v_output*` labels were emitted yet; existing layer-1
  query/key words stayed unchanged, cleanup tracing still showed `close(3)`
  before final `munmap`, and the build, harness, oracle py-compile, runtime
  purity, static-link, tracked-artifact, help, and whitespace checks passed.

## 2026-05-10T20:49:38Z

- Published the first four raw f32 words of the token-0 layer-1 value
  projection behind the existing `token0_layer1_attn_v_matvec` status gate. This
  mirrors the query/key exposure pattern and leaves independent oracle
  comparison as a separate audit step.
- Verification evidence: the real local target printed value words
  `0x3d6bd91b`, `0x3d763224`, `0x3d709b92`, and `0xbcca1ab6`. The empty valid
  synthetic GGUF kept the layer-1 norm/query/key/value gates at 0 and emitted no
  layer-1 value-output labels; rebuild, no-libc harnesses, cleanup tracing,
  oracle py-compile, runtime purity, static-link, tracked-artifact, help, and
  whitespace checks passed.

## 2026-05-10T20:57:52Z

- Added external layer-1 attention value oracle tooling. It reuses the full
  layer-1 attention RMSNorm activation from the prior oracle path, then dots
  that activation against the first four rows of `blk.1.attn_v.weight` with the
  same scalar Q8_0 f32 accumulation order as the assembly matvec helper.
- Verification evidence: the oracle produced `0x3d6bd91b`, `0x3d763224`,
  `0x3d709b92`, and `0xbcca1ab6` for the public layer-1 value words, matching
  the current runtime labels exactly. The assembly harnesses, oracle
  py-compile, runtime purity, static-link, tracked-artifact, help, and
  whitespace checks passed.

## 2026-05-10T21:04:10Z

- Added descriptor-only runtime coverage for `blk.1.attn_output.weight` in its
  own reusable lookup slot. The step intentionally stops before any layer-1
  output projection payload read.
- Verification evidence: the real target printed the output descriptor as Q8_0
  `4096x3072` at relative offset `554876928`, matching an external descriptor
  parser. A temporary empty valid GGUF left the layer-1 output descriptor slot
  zeroed, kept the layer-1 norm/query/key/value gates at 0, and emitted no
  `token0_layer1_attn_output*` labels. Build, harness, oracle py-compile,
  runtime purity, static-link, tracked-artifact, help, and whitespace checks
  passed.

## 2026-05-10T21:09:14Z

- Added the status-only layer-1 attention context smoke. It mirrors the
  layer-0 grouped-query expansion but reads from the private layer-1 value
  projection buffer and uses `blk.1.attn_output.weight` only as an exact
  Q8_0 `4096x3072` shape guard.
- Verification evidence: the real target printed
  `token0_layer1_attn_context: 1` while the established layer-1 norm/query/key
  and value exact-hex slices stayed unchanged. A temporary empty valid GGUF kept
  the new context gate at 0. Static inspection of the new function found no
  references to the output-projection offset, mapping base, or matvec helper,
  confirming this step did not add output-projection payload reads.

## 2026-05-10T21:13:05Z

- Published the first four raw f32 words of the token-0 layer-1 attention
  context behind the existing context status gate. Since this is still the
  one-token context expansion step, the first query head copies the first
  KV-head value block unchanged and no output-projection payload bytes are read.
- Verification evidence: the real target printed context words `0x3d6bd91b`,
  `0x3d763224`, `0x3d709b92`, and `0xbcca1ab6`, matching the first four
  layer-1 value words already published. The empty valid synthetic GGUF kept the
  layer-1 context gate at 0 and emitted no layer-1 context word labels; build,
  no-libc harnesses, static no-output-projection-read check, oracle
  py-compile, runtime purity, static-link, tracked-artifact, help, and
  whitespace checks passed.

## 2026-05-10T21:19:54Z

- Added the external layer-1 attention context oracle note. It ties the already
  independent value projection oracle to the one-token grouped-query attention
  rule: softmax over one entry is 1, and each 128-word KV-head value block is
  copied into four query heads, so the first four context words must equal the
  first four layer-1 value words.
- Verification evidence: the real runtime still printed context words
  `0x3d6bd91b`, `0x3d763224`, `0x3d709b92`, and `0xbcca1ab6`, matching the
  value projection words. The external layer-1 value oracle rerun reproduced
  those value words, the empty valid GGUF kept the context gate at 0, and the
  build, no-libc harnesses, static no-output-projection-read check, oracle
  py-compile, runtime purity, static-link, tracked-artifact, help, and
  whitespace checks passed.

## 2026-05-10T21:24:38Z

- Added the status-only layer-1 attention output-projection smoke. It consumes
  the private grouped-query context, requires the reusable
  `blk.1.attn_output.weight` descriptor to be exact Q8_0 `4096x3072`, bounds the
  full mapped payload, and writes only private static output storage.
- Verification evidence: the real target printed
  `token0_layer1_attn_output_matvec: 1` while the established layer-1
  norm/query/key/value/context exact-hex slices stayed unchanged. A temporary
  empty valid GGUF kept the new output gate at 0, no layer-1 output word labels
  exist yet, cleanup tracing still showed `close(3)` before final `munmap`, and
  the build, harness, oracle py-compile, runtime purity, static-link,
  tracked-artifact, help, and whitespace checks passed.

## 2026-05-10T21:27:44Z

- Published the first four raw f32 words of the token-0 layer-1 attention
  output projection behind the existing `token0_layer1_attn_output_matvec`
  status gate. This only exposes the private buffer that the previous smoke step
  already wrote; independent oracle comparison remains the next audit step.
- Verification evidence: the real local target printed output-projection words
  `0x3deaa744`, `0x3cb6f294`, `0xbf14cf4f`, and `0xbced5550`, while established
  layer-1 norm/query/key/value/context slices stayed unchanged. The empty valid
  synthetic GGUF kept the output gate at 0 and emitted no layer-1 output labels;
  build, no-libc harnesses, cleanup tracing, oracle py-compile, runtime purity,
  static-link, tracked-artifact, help, and whitespace checks passed.

## 2026-05-10T21:36:13Z

- Added external layer-1 attention output-projection oracle tooling. It
  recomputes the full layer-1 value projection from the layer-1 attention
  RMSNorm activation, expands the one-token grouped-query context, then dots
  that context against the first four rows of `blk.1.attn_output.weight`.
- Verification evidence: the new oracle produced `0x3deaa744`, `0x3cb6f294`,
  `0xbf14cf4f`, and `0xbced5550`, matching the current runtime labels exactly.
  The prerequisite post-FFN residual, layer-1 RMSNorm, and layer-1 context
  public slices also matched the oracle output; build, no-libc harnesses,
  oracle py-compile, runtime purity, static-link, tracked-artifact, help, and
  whitespace checks passed.

## 2026-05-10T21:40:07Z

- Added the status-only layer-1 post-attention residual smoke. It adds the
  private layer-0 post-FFN residual buffer to the private layer-1 attention
  output buffer, writes a separate 3072-f32 residual buffer, and emits only a
  status line for this step.
- Verification evidence: the real target printed
  `token0_layer1_post_attn_residual: 1` while the established layer-1 output
  projection words stayed unchanged. A temporary empty valid GGUF kept the new
  residual gate at 0. Build, no-libc harnesses, oracle py-compile, runtime
  purity, static-link, tracked-artifact, help, and whitespace checks passed.

## 2026-05-10T21:44:55Z

- Published the first four raw f32 words of the token-0 layer-1 post-attention
  residual behind the existing residual status gate. This only exposes the
  private buffer that the previous smoke step already wrote; no new tensor
  payload bytes are read.
- Verification evidence: the real target printed residual words `0xbd4055c4`,
  `0xbf0fbbb6`, `0x401af18e`, and `0xbe6a002c`. The empty valid synthetic GGUF
  kept the residual gate at 0 and emitted no layer-1 post-attention residual
  word labels; build, no-libc harnesses, oracle py-compile, runtime purity,
  static-link, tracked-artifact, help, and whitespace checks passed.

## 2026-05-10T21:53:36Z

- Added external layer-1 post-attention residual oracle tooling. It reuses the
  independent layer-1 output-projection oracle path, then f32-adds the first
  four layer-0 post-FFN residual words to the first four layer-1 attention
  output words.
- Verification evidence: the new oracle produced `0xbd4055c4`, `0xbf0fbbb6`,
  `0x401af18e`, and `0xbe6a002c`, matching the current runtime labels exactly.
  Build, no-libc harnesses, oracle py-compile, runtime purity, static-link,
  tracked-artifact, help, and whitespace checks passed.

## 2026-05-10T22:00:45Z

- Added descriptor-only runtime coverage for `blk.1.ffn_norm.weight`. The new
  path uses `gguf_lookup_tensor_info`, stores the summary in a separate
  process-owned layer-1 FFN norm slot, and prints only descriptor fields.
- Verification evidence: the real target printed found `1`, dimension count
  `1`, dim0 `3072`, type `0`, and offset `645120000`; an independent GGUF
  parser cross-check reported the same descriptor. Established layer-1
  output-projection and post-attention residual exact-hex slices stayed
  unchanged, and static inspection found no FFN norm payload-offset use outside
  descriptor summary printing.

## 2026-05-10T22:05:22Z

- Added the status-only layer-1 FFN RMSNorm smoke. It consumes the private
  layer-1 post-attention residual buffer, resolves and bounds the reusable
  `blk.1.ffn_norm.weight` f32 payload, and writes a separate private activation
  buffer without publishing any f32 words yet.
- Verification evidence: the real target printed `token0_layer1_ffn_norm: 1`
  while established layer-1 output-projection and post-attention residual words
  stayed unchanged. A temporary empty valid GGUF kept the new gate at 0 and
  emitted no layer-1 FFN norm word labels; build, no-libc harnesses, cleanup
  tracing, oracle py-compile, runtime purity, static-link, tracked-artifact,
  help, status-only label, and whitespace checks passed.

## 2026-05-10T22:13:54Z

- Handled the transient operator instruction to stop feature work and start the
  required two-pass review gate. Review pass 1 inspected the committed layer-1
  FFN norm status path, descriptor lookup, bounds checks, and artifact purity;
  it found no blocking runtime correctness issue.
- Durable process note: the worktree already contained an unstaged
  `src/entry/_start.s` feature diff that publishes the layer-1 FFN norm slice.
  The review step left that runtime diff unstaged and recorded that pass 2 must
  complete before feature work resumes.
- Verification evidence for the review pass: build and no-libc harnesses
  passed, help output worked, whitespace checks passed, runtime source remained
  `.s` only, the executable remained statically linked, and no tracked model or
  large artifact matched the scan.

## 2026-05-10T22:15:49Z

- Completed review pass 2 for the layer-1 FFN norm gate. The pass checked that
  oracle coverage is current through the committed layer-1 post-attention
  residual slice, that the queued FFN norm slice-publish diff only exposes
  private static activation words behind the existing status gate, and that
  continuation state now points back to the feature publish.
- Verification evidence: a clean rebuild, no-libc harnesses, help output,
  whitespace check, runtime source purity scan, static-link inspection, oracle
  py-compile, and tracked-artifact scan all passed with the pre-existing
  unstaged runtime diff still left out of the review commit.

## 2026-05-10T22:20:20Z

- Published the first four raw f32 words of the token-0 layer-1 FFN-normalized
  activation behind the existing `token0_layer1_ffn_norm` status gate. This
  exposes only the private activation buffer that the prior status smoke already
  wrote, so the next audit step is an independent oracle recomputation.
- Verification evidence: the real target printed `token0_layer1_ffn_norm: 1`
  with words `0xbec8ddb4`, `0xc11f7d85`, `0x40d46234`, and `0xbfe2ec8e`. A
  24-byte empty valid GGUF kept the gate at 0 and emitted no layer-1 FFN norm
  word labels; build, no-libc harnesses, help, oracle py-compile, runtime
  purity, static-link, tracked-artifact, and whitespace checks passed.

## 2026-05-10T22:30:55Z

- Added external layer-1 FFN RMSNorm oracle tooling. The key audit constraint is
  that RMSNorm cannot be checked from the four published residual words alone;
  the script recomputes the full 3072-word layer-1 attention output and
  post-attention residual before applying `blk.1.ffn_norm.weight`.
- Verification evidence: the new oracle produced the four published layer-1
  FFN norm words exactly, while the prerequisite layer-1 attention RMSNorm,
  value, context, output, and residual public slices still matched the assembled
  runtime. Build, no-libc harnesses, help, oracle py-compile, runtime purity,
  static-link, tracked-artifact, large-file, and whitespace checks passed.

## 2026-05-11T00:12:00Z

- Handled the transient operator instruction to stop feature work and start a
  new two-pass repository-wide review gate. Pass 1 found no runtime purity or
  build-system violation, but it did find an important maintainability blocker:
  `_start.s` has grown into a broad orchestration, storage, lookup, and printing
  module. Feature work remains stopped pending the required second pass.
- Verification evidence: clean rebuild, no-libc harnesses, help output, current
  real-target layer-1 FFN norm smoke, oracle py-compile, runtime source purity,
  static-link, tracked-artifact, large-file, and whitespace checks passed.

## 2026-05-11T00:39:54Z

- Completed the required second repository-wide review pass. It independently
  confirmed that the next risk is maintainability rather than runtime purity or
  math correctness: `_start.s` now carries too many unrelated responsibilities
  to keep extending safely.
- Verification evidence: clean rebuild, no-libc harnesses, help output, current
  real-target layer-1 FFN norm smoke, oracle py-compile, runtime source purity,
  static-link, tracked-artifact, large-file, and whitespace checks passed.

## 2026-05-11T00:45:01+02:00

- Per the review gate, performed the first behavior-preserving `_start.s`
  responsibility split before resuming feature work. Generic exact-string and
  bounded/decimal/hex output helpers moved into a focused runtime text module;
  no runtime output logic was changed.
- Verification evidence: help output and the current real-target layer-1 handoff
  smoke were compared against pre-split baselines with no diff. The smoke still
  reported layer-1 FFN norm status 1 and words `0xbec8ddb4`, `0xc11f7d85`,
  `0x40d46234`, and `0xbfe2ec8e`. Build, no-libc harnesses, whitespace,
  runtime source purity, static-link, exported-symbol, tracked-artifact, and
  large-file checks passed.

## 2026-05-11T00:50:12+02:00

- Added descriptor-only coverage for the layer-1 FFN gate and up tensors. The
  runtime resolves both names through `gguf_lookup_tensor_info`, keeps separate
  scratch slots, and prints only descriptor fields so no new Q8_0 payload bytes
  are consumed in this step.
- Verification evidence: the real target reported both descriptors as present
  with dimensions `3072 x 9216`, type `8`, and offsets `615038976` and
  `645132288`; an independent GGUF parser reported the same values. The
  existing layer-1 FFN norm status and four public words stayed unchanged.
  Build, no-libc harnesses, help, whitespace, runtime purity, static-link,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T00:56:00+02:00

- Handled the live operator instruction to prioritize `_start.s` splitting by
  putting the new layer-1 FFN gate matvec smoke, private status word, private
  output buffer, and status printer in focused `src/infer` code. `_start.s`
  now only exposes the already-owned handoff slots and calls the focused status
  routine.
- Verification evidence: the real target printed
  `token0_layer1_ffn_gate_matvec: 1` while the existing layer-1 FFN norm status
  and four public words stayed unchanged. A temporary empty valid GGUF printed
  status `0`. Build, no-libc harnesses, help, oracle py-compile, whitespace,
  runtime purity, static-link, exported-symbol, tracked-artifact, and tracked
  large-file checks passed.

## 2026-05-11T01:02:21+02:00

- Treated the still-present transient split instruction as active and made it a
  continuing split-first state before any new layer-1 FFN up behavior. The
  behavior-preserving extraction moved the existing layer-1 FFN RMSNorm smoke
  body into the focused FFN inference module; `_start.s` now exports only the
  handoff slots that the moved routine was already reading and writing
  logically.
- Verification evidence: the real target still reported the same layer-1 FFN
  norm words `0xbec8ddb4`, `0xc11f7d85`, `0x40d46234`, and `0xbfe2ec8e`,
  followed by layer-1 FFN gate matvec status `1`. A temporary empty valid GGUF
  kept both layer-1 FFN norm and gate statuses at `0`. Build, no-libc
  harnesses, help, oracle py-compile, whitespace, runtime purity, static-link,
  undefined-symbol, exported-symbol, tracked-artifact, and tracked large-file
  checks passed.

## 2026-05-11T01:06:49+02:00

- Finished the behavior-preserving layer-1 FFN norm print relocation. The norm
  status write and exact-hex slice now share the focused FFN wrapper, which
  keeps `_start.s` as an orchestration caller while preserving the diagnostic
  order before the gate matvec status.
- Verification evidence: the real target still printed the same layer-1 FFN
  norm status and words `0xbec8ddb4`, `0xc11f7d85`, `0x40d46234`, and
  `0xbfe2ec8e`, followed by gate matvec status `1`. A temporary empty valid
  GGUF printed only the norm and gate statuses at `0` for this region. Build,
  no-libc harnesses, help, oracle py-compile, whitespace, runtime purity,
  static-link, undefined-symbol, exported-symbol, tracked-artifact, and tracked
  large-file checks passed.

## 2026-05-11T01:11:21+02:00

- Added status-only layer-1 FFN up matvec coverage in the focused FFN inference
  module. The up path mirrors the existing gate path: descriptor, type, shape,
  and complete Q8_0 payload bounds are checked before reading mapped tensor
  bytes, and the new diagnostic line is appended after the existing gate status.
- Verification evidence: the real target reported
  `token0_layer1_ffn_up_matvec: 1` after the unchanged layer-1 FFN norm words
  and gate status. A temporary empty valid GGUF kept the norm, gate, and up
  statuses at `0`. Build,
  no-libc harnesses, help, oracle py-compile, whitespace, runtime purity,
  static-link, undefined-symbol, exported-symbol, tracked-artifact, and tracked
  large-file checks passed.

## 2026-05-11T01:21:37+02:00

- Added the first public layer-1 FFN gate projection slice while keeping the
  focused inference module responsible for the private gate output buffer and
  its printer. The status remains the guard: synthetic non-target inputs print
  only the zero statuses, while the real target emits the four gate words before
  the existing up status line.
- Verification evidence: the real target printed gate output words
  `0xbe34ea97`, `0xbfcc8119`, `0xbf150238`, and `0xbf882cef`; a one-off
  external Python oracle recomputed the upstream layer-1 path and matched those
  words exactly. Build, no-libc harnesses, help, oracle py-compile, whitespace,
  runtime purity, static-link, undefined-symbol, exported-symbol,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T01:34:10+02:00

- Entry-source refactor decision: keep `_start` as one assembled translation
  unit for now, but split the 8k-line source into responsibility-named include
  fragments under `src/entry/start/`. This reduces the editing surface without
  changing local-label reachability, output order, or symbol ownership.
- Follow-up risk: the physical split is only the first maintainability pass.
  The largest remaining fragments are entry orchestration, token-0 smoke logic,
  output slice printers, and rodata; `src/gguf/load_header.s` is also still
  large enough to deserve a later structural split.
- Verification evidence: the runtime rebuilt, all no-libc harness checks
  passed, and concatenating the new entry fragments reproduced the prior
  `_start.s` exactly.

## 2026-05-11T09:29:02+02:00

- Followed up on the remaining large-file risk with behavior-preserving include
  splits for the GGUF loader and the largest entry fragments. The split stays
  conservative: each driver assembles its fragments as one translation unit, so
  local-label reachability and diagnostic order are unchanged.
- Added a durable continuation rule to prevent this pattern from recurring:
  substantial new runtime code should not be added to files near or above 1000
  lines without first splitting by responsibility or moving the work into a
  focused module, and introduced include fragments must be listed as Makefile
  dependencies.
- Verification evidence: reconstruction checks passed for the GGUF loader and
  the split entry fragments after normalizing terminal blank lines, then
  `make`, `make check`, and `git diff --check` passed.

## 2026-05-11T09:55:40+02:00

- Added the first public layer-1 FFN up projection slice behind the existing up
  matvec status gate. The status line remains the guard: non-target inputs do
  not print output words, while the real target emits the four up words after
  `token0_layer1_ffn_up_matvec: 1`.
- Verification evidence: the real target printed up output words `0x3f1797a4`,
  `0x3f80ec8f`, `0xbe651441`, and `0x3f2943b9`; a one-off external Python
  oracle recomputed the upstream layer-1 path and matched those words exactly.
  A temporary empty valid GGUF kept layer-1 FFN norm/gate/up statuses at `0` and
  emitted no layer-1 FFN output word labels. Build, no-libc harnesses, help,
  oracle py-compile, whitespace, runtime purity, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T10:00:46+02:00

- Added status-only layer-1 FFN SwiGLU coverage in the focused FFN inference
  module. This is pure retained-buffer math: the new smoke consumes the private
  gate/up projection outputs only after their statuses are both `1`, writes a
  private SwiGLU output buffer for the next slice/down step, and does not read
  mapped tensor payload bytes.
- Verification evidence: the real target printed the unchanged layer-1 FFN
  norm/gate/up diagnostics followed by `token0_layer1_ffn_swiglu: 1`. A
  temporary empty valid GGUF kept layer-1 FFN norm/gate/up/SwiGLU statuses at
  `0` and emitted no layer-1 FFN output word labels. Build, no-libc harnesses,
  help, whitespace, runtime purity, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T10:06:29+02:00

- Added the first public layer-1 FFN SwiGLU activation slice behind the existing
  SwiGLU status gate. This keeps the focused inference module responsible for
  the private activation buffer and mirrors the earlier gate/up slice behavior:
  non-target inputs print only zero statuses, while the real target emits four
  SwiGLU words immediately after the status line.
- Verification evidence: the real target printed SwiGLU output words
  `0xbd436233`, `0xbe8aab8b`, `0x3d3f2f78`, and `0xbe38ceee`; the existing
  Python oracle scalar SwiGLU routine reproduced those values from the
  published gate/up words. A temporary empty valid GGUF kept layer-1 FFN
  norm/gate/up/SwiGLU statuses at `0` and emitted no layer-1 FFN output word
  labels. Build, no-libc harnesses, help, oracle py-compile, whitespace,
  runtime purity, static-link, undefined-symbol, exported-symbol,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T10:12:18+02:00

- Added descriptor-only coverage for the layer-1 FFN down tensor. The new
  descriptor is intentionally only a handoff and summary proof in this step; no
  `blk.1.ffn_down.weight` payload bytes are read before the next guarded matvec
  step.
- Verification evidence: the real target reported the layer-1 down descriptor
  as found with dimensions `9216x3072`, type `8`, and offset `584957952`, while
  the existing layer-1 FFN norm/gate/up/SwiGLU diagnostics remained unchanged.
  A temporary empty valid GGUF kept gate/up/down descriptor slots zeroed and all
  layer-1 FFN statuses at `0`. Build, harnesses, help, oracle py-compile,
  whitespace, runtime purity, static-link, undefined-symbol, exported-symbol,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T10:21:04+02:00

- Added status-only layer-1 FFN down matvec coverage in a new focused inference
  source rather than growing the existing layer-1 FFN module beyond the
  near-1000-line threshold. The new path consumes the retained layer-1 SwiGLU
  activation and the `blk.1.ffn_down.weight` descriptor only after descriptor,
  type, shape, and full Q8_0 payload bounds checks.
- Verification evidence: the real target reported
  `token0_layer1_ffn_down_matvec: 1` after the unchanged layer-1 FFN
  norm/gate/up/SwiGLU diagnostics. A temporary empty valid GGUF kept layer-1
  FFN norm/gate/up/SwiGLU/down statuses at `0`. Build, no-libc harnesses, help,
  oracle py-compile, whitespace, runtime purity, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T10:30:14+02:00

- Added the first public layer-1 FFN down projection slice behind the existing
  down matvec status gate. This is a diagnostic publish-only step: the private
  down output buffer was already produced by the bounded matvec smoke, and the
  new printer only reads its first four words after status `1`.
- Verification evidence: the real target printed down output words
  `0x3babc025`, `0x3db2eb07`, `0xbeba3568`, and `0x3df45039` immediately after
  `token0_layer1_ffn_down_matvec: 1`. A temporary empty valid GGUF kept the
  layer-1 FFN statuses at `0` and emitted no layer-1 down output labels. Build,
  no-libc harnesses, help, oracle py-compile, whitespace, runtime purity,
  static-link, undefined-symbol, exported-symbol, tracked-artifact, and tracked
  large-file checks passed.

## 2026-05-11T10:36:48+02:00

- Added status-only layer-1 post-FFN residual coverage in the focused FFN down
  inference module. The new step is pure retained-buffer math: it waits for the
  layer-1 post-attention residual and FFN down statuses, adds the two 3072-wide
  f32 rows into a reusable post-FFN residual buffer, and prints only one status
  line in this iteration.
- Verification evidence: the real target printed the unchanged layer-1 FFN
  down output words followed by `token0_layer1_post_ffn_residual: 1`. A
  temporary empty valid GGUF kept the new status at `0` and emitted no
  post-FFN residual output labels. Build, no-libc harnesses, help, oracle
  py-compile, whitespace, runtime source extension, static-link,
  undefined-symbol, exported-symbol, tracked-artifact, and tracked large-file
  checks passed.

## 2026-05-11T10:48:47+02:00

- Added the first public layer-1 post-FFN residual slice behind the existing
  post-FFN residual status gate. The focused FFN down module remains the owner
  of the retained residual buffer, and non-target inputs print only the zero
  status without residual word labels.
- Verification evidence: the real target printed post-FFN residual words
  `0xbd2addbf`, `0xbef2bcaa`, `0x4003aae1`, and `0xbddfb01f` immediately after
  `token0_layer1_post_ffn_residual: 1`. A narrow f32-add oracle using the
  adjacent published layer-1 post-attention residual and FFN down output words
  reproduced those values exactly. Full-path Python recomputation was abandoned
  for this loop because the scalar/vectorized one-off scripts were too slow for
  routine verification; a persistent optimized oracle can be added later if
  review says this evidence is too narrow. Build, no-libc harnesses, help,
  negative empty-GGUF guard check, oracle py-compile, whitespace, source
  extension, static-link, undefined-symbol, exported-symbol, tracked-artifact,
  and tracked large-file checks passed.

## 2026-05-11T10:54:05+02:00

- Review pass 1 over the completed layer-1 FFN down and post-FFN residual slice
  path found the runtime guards and output ordering coherent, but treated the
  missing durable oracle for the committed layer-1 FFN branch as a blocker
  before layer-2 scope increases. The current evidence is good enough to trust
  the status gates, but not durable enough for a repeatable branch-level
  comparison.
- Verification evidence for the review: the real target still publishes the
  layer-1 down descriptor, down words, and post-FFN residual words recorded in
  state; a 24-byte empty valid GGUF keeps the reviewed statuses at zero and
  emits no guarded output labels. Build, harnesses, help, oracle py-compile,
  whitespace, source extension, static-link, tracked-artifact, and tracked
  large-file checks passed.

## 2026-05-11T11:09:55+02:00

- Added durable external oracle coverage for the completed token-0 layer-1 FFN
  branch. The new script keeps exact scalar Q8_0 dot accumulation for the
  full gate/up/SwiGLU vectors before checking the down and post-FFN residual
  public slices, so the run is intentionally slow and should remain targeted
  verification rather than a default check.
- Verification evidence: the exact oracle matched the runtime for the layer-1
  FFN gate, up, SwiGLU, down, and post-FFN residual public words. The script
  also reuses the full layer-1 FFN norm activation and post-attention residual
  arrays from the previous oracle path, which removes the review blocker without
  changing runtime assembly.

## 2026-05-11T11:23:59+02:00

- Review pass 1 over the completed layer-1 FFN branch found no blocking issue
  in the branch ordering, status gates, mmap payload bounds, or durable oracle
  coverage. The previous oracle gap is closed for the public gate/up/SwiGLU/down
  and post-FFN residual words.
- Verification evidence for the review: the exact scalar oracle reproduced the
  runtime's layer-1 post-attention residual, FFN norm, gate/up/SwiGLU/down, and
  post-FFN residual public words exactly; a temporary empty valid GGUF kept the
  reviewed branch statuses at `0` with no guarded layer-1 FFN output labels.
  Final whitespace, runtime source extension, static-link, undefined-symbol,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T11:41:06+02:00

- Review pass 2 over the completed layer-1 FFN branch found no blocking issue in
  the branch ordering, status gates, mmap payload bounds, oracle coverage, or the
  current module-size surface. The two-pass review gate is complete.
- Verification evidence for the review: build, harnesses, help, oracle
  py-compile, real target smoke, exact scalar branch oracle, and the empty-GGUF
  negative guard check passed. The runtime's layer-1 FFN gate/up/SwiGLU/down and
  post-FFN residual public words matched the oracle exactly.

## 2026-05-11T11:49:40+02:00

- Added descriptor-only layer-2 attention RMSNorm setup through the reusable
  tensor-info lookup helper. The new `blk.2.attn_norm.weight` slot is separate
  from layer-1 handoff state, prints only directory fields, and does not touch
  tensor payload bytes.
- Verification evidence: the real target reported found `1`, one dimension
  `3072`, f32 type `0`, and relative offset `678555648`; a temporary empty
  valid GGUF kept the new slot zeroed. Build, harnesses, help, oracle
  py-compile, whitespace, runtime source extension, static-link,
  undefined-symbol, exported-symbol, tracked-artifact, and tracked large-file
  checks passed.

## 2026-05-11T11:55:51+02:00

- Added status-only layer-2 attention RMSNorm coverage in a focused inference
  module. The new path reads `blk.2.attn_norm.weight` only after the layer-1
  post-FFN residual status is present and the f32 descriptor shape plus full
  payload span have been checked against the live mapping.
- Verification evidence: the real target kept the existing layer-1 post-FFN
  residual words and reported `token0_layer2_attn_norm: 1`; a temporary empty
  valid GGUF reported zeroed layer-2 descriptor fields and
  `token0_layer2_attn_norm: 0`. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T12:10:11+02:00

- Published the first guarded layer-2 attention RMSNorm activation slice from
  the focused layer-2 inference module. The new labels are emitted only after
  `token0_layer2_attn_norm: 1`, and the empty-GGUF guard path still prints only
  the zero status without any guarded layer-2 word labels.
- Verification evidence: the real target printed layer-2 norm words
  `0xbf898056`, `0xc152dc8b`, `0x4248afc4`, and `0xc0556342`. The external
  oracle recomputed the full layer-1 post-FFN residual and then applied
  `blk.2.attn_norm.weight`; its words matched the runtime exactly. Build,
  harnesses, help, oracle py-compile, whitespace, runtime source extension,
  tracked include dependencies, static-link, undefined-symbol, exported-symbol,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T12:15:23+02:00

- Added descriptor-only layer-2 attention query setup. The new
  `blk.2.attn_q.weight` descriptor is retained in its own layer-2 scratch slot
  and published only as summary fields, leaving tensor payload bytes untouched
  for this step.
- Verification evidence: the real target reported found `1`, dimensions
  `3072` and `4096`, Q8_0 type `8`, and relative offset `691937280`; the
  previously published layer-2 RMSNorm status and words stayed unchanged. A
  temporary empty valid GGUF kept both layer-2 descriptor slots zeroed and kept
  `token0_layer2_attn_norm: 0`. The exact layer-2 norm oracle was not part of
  this descriptor-only verification; its durable coverage remains from the
  prior layer-2 norm slice step. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, tracked include dependencies,
  static-link, undefined-symbol, exported-symbol, tracked-artifact, and tracked
  large-file checks passed.

## 2026-05-11T12:26:02+02:00

- Added status-only layer-2 attention query matvec coverage in the focused
  layer-2 inference module. The new path waits for the layer-2 attention
  RMSNorm activation and requires the `blk.2.attn_q.weight` descriptor to be a
  bounded Q8_0 `[3072 x 4096]` matrix before handing its mmap span to the shared
  matvec helper.
- Verification evidence: the real target preserved the published layer-2
  RMSNorm words and reported `token0_layer2_attn_q_matvec: 1`. A temporary
  empty valid GGUF kept both layer-2 descriptor slots zeroed and reported
  `token0_layer2_attn_norm: 0` plus `token0_layer2_attn_q_matvec: 0`, with no
  guarded layer-2 norm word labels. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, tracked include dependencies,
  static-link, undefined-symbol, exported-symbol, tracked-artifact, and tracked
  large-file checks passed.

## 2026-05-11T12:40:44+02:00

- Published the first guarded layer-2 attention query projection slice from the
  focused layer-2 inference module. The new labels are emitted only after
  `token0_layer2_attn_q_matvec: 1`, and the empty-GGUF guard path still prints
  only zero statuses without any guarded layer-2 query output labels.
- Verification evidence: the real target printed query output words
  `0x3f29ab97`, `0x3fa60667`, `0x4000572f`, and `0x3fb6f799`. The focused
  external oracle recomputed the full upstream layer-1 post-FFN residual, the
  layer-2 attention RMSNorm activation, and the first four rows of
  `blk.2.attn_q.weight`; its words matched the runtime exactly. Build,
  harnesses, help, oracle py-compile, whitespace, runtime source extension,
  tracked include dependencies, static-link, undefined-symbol, exported-symbol,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T12:46:52+02:00

- Added descriptor-only layer-2 attention key setup. The new
  `blk.2.attn_k.weight` descriptor is retained in its own exported layer-2
  scratch slot and published only as summary fields, so this step does not read
  key matrix payload bytes.
- Verification evidence: the real target reported found `1`, dimensions
  `3072` and `1024`, Q8_0 type `8`, and relative offset `675213312`; the
  previously published layer-2 RMSNorm and query output words stayed unchanged.
  A temporary empty valid GGUF kept the layer-2 norm/query/key descriptor slots
  zeroed and kept the layer-2 norm/query statuses at `0`. Build, harnesses,
  help, oracle py-compile, whitespace, runtime source extension, tracked include
  dependencies, static-link, undefined-symbol, exported-symbol,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T12:52:45+02:00

- Added status-only layer-2 attention key matvec coverage in the focused
  layer-2 attention module. The new path waits for the layer-2 attention
  RMSNorm activation and requires `blk.2.attn_k.weight` to be a bounded Q8_0
  `[3072 x 1024]` matrix before handing its mmap span to the shared matvec
  helper.
- Verification evidence: the real target preserved the published layer-2
  RMSNorm/query words and reported `token0_layer2_attn_k_matvec: 1`. A
  temporary empty valid GGUF kept layer-2 descriptor slots zeroed and reported
  `token0_layer2_attn_norm: 0`, `token0_layer2_attn_q_matvec: 0`, and
  `token0_layer2_attn_k_matvec: 0`, with no guarded layer-2 output labels.
  Build, harnesses, help, oracle py-compile, whitespace, runtime source
  extension, tracked include dependencies, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T13:07:06+02:00

- Published the first guarded layer-2 attention key projection slice from the
  focused layer-2 inference module. The labels are emitted only after
  `token0_layer2_attn_k_matvec: 1`, and the empty-GGUF guard path still prints
  only zero layer-2 statuses without any guarded layer-2 output labels.
- Verification evidence: the real target printed key output words
  `0xc0775316`, `0xbecc9c4c`, `0xbfd669ad`, and `0x4005155d`. The focused
  external oracle recomputed the full upstream layer-1 post-FFN residual, the
  layer-2 attention RMSNorm activation, and the first four rows of
  `blk.2.attn_k.weight`; its words matched the runtime exactly. Build,
  harnesses, help, oracle py-compile, whitespace, runtime source extension,
  tracked include dependencies, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T13:14:42+02:00

- Added descriptor-only layer-2 attention value setup. The new
  `blk.2.attn_v.weight` descriptor is retained in its own exported layer-2
  scratch slot and published only as summary fields, so this step does not read
  value matrix payload bytes.
- Verification evidence: the real target reported found `1`, dimensions
  `3072` and `1024`, Q8_0 type `8`, and relative offset `705306624`; the
  existing layer-2 RMSNorm/query/key statuses and published query/key words
  stayed unchanged. A temporary empty valid GGUF kept layer-2 descriptor slots
  zeroed and reported layer-2 norm/query/key statuses at `0`. Build, harnesses,
  help, oracle py-compile, whitespace, runtime source extension, tracked include
  dependencies, static-link, undefined-symbol, exported-symbol,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T13:19:43+02:00

- Added status-only layer-2 attention value matvec coverage in the focused
  layer-2 attention module. The new path waits for the layer-2 attention
  RMSNorm activation and requires `blk.2.attn_v.weight` to be a bounded Q8_0
  `[3072 x 1024]` matrix before handing its mmap span to the shared matvec
  helper.
- Verification evidence: the real target preserved the published layer-2
  RMSNorm/query/key words and reported `token0_layer2_attn_v_matvec: 1`. A
  temporary empty valid GGUF kept layer-2 descriptor slots zeroed and reported
  `token0_layer2_attn_norm: 0`, `token0_layer2_attn_q_matvec: 0`,
  `token0_layer2_attn_k_matvec: 0`, and `token0_layer2_attn_v_matvec: 0`, with
  no guarded layer-2 output labels. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, tracked include dependencies,
  static-link, undefined-symbol, exported-symbol, tracked-artifact, and tracked
  large-file checks passed.

## 2026-05-11T13:34:01+02:00

- Published the first guarded layer-2 attention value projection slice from the
  focused layer-2 inference module. The new labels are emitted only after
  `token0_layer2_attn_v_matvec: 1`, and the empty-GGUF guard path still prints
  only zero layer-2 statuses without any guarded layer-2 output labels.
- Verification evidence: the real target printed value output words
  `0x3d38e19b`, `0x3ae7765b`, `0xbd4bbba8`, and `0xbf48b85f`. The focused
  external oracle recomputed the full upstream layer-1 post-FFN residual, the
  layer-2 attention RMSNorm activation, and the first four rows of
  `blk.2.attn_v.weight`; its words matched the runtime exactly. Build,
  harnesses, help, oracle py-compile, whitespace, runtime source extension,
  tracked include dependencies, static-link, undefined-symbol, exported-symbol,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T13:40:15+02:00

- Added descriptor-only layer-2 attention output-projection setup. The
  `blk.2.attn_output.weight` descriptor is retained in its own scratch slot and
  printed after the layer-2 value descriptor, but this step intentionally avoids
  reading output-projection matrix payload bytes.
- Verification evidence: the real target reported found `1`, dimensions
  `4096` and `3072`, Q8_0 type `8`, and relative offset `678567936`; existing
  layer-2 norm/query/key/value statuses and output words were unchanged. A
  temporary empty valid GGUF kept all layer-2 attention descriptor slots zeroed,
  including the new output slot, and kept layer-2 norm/query/key/value statuses
  at `0` with no guarded layer-2 output labels. Build, harnesses, help, oracle
  py-compile, whitespace, runtime source extension, tracked include
  dependencies, static-link, undefined-symbol, exported-symbol,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T13:47:03+02:00

- Added focused layer-2 single-token attention context smoke in
  `src/infer/token0_layer2_attn_context.s` instead of extending the 997-line
  layer-2 attention projection module. The context gate requires the retained
  layer-2 value projection status plus the layer-2 value and output-projection
  descriptor shapes, then repeats each 128-f32 KV-head block four times for the
  associated query heads. The output-projection descriptor remains a shape gate
  only; this step does not read `blk.2.attn_output.weight` payload bytes.
- Verification evidence: the real target printed
  `token0_layer2_attn_context: 1` with first-four context words
  `0x3d38e19b`, `0x3ae7765b`, `0xbd4bbba8`, and `0xbf48b85f`, matching the
  retained layer-2 value projection first-four words exactly. A temporary
  24-byte empty valid GGUF kept the layer-2 value/output descriptor slots
  zeroed and kept layer-2 norm/query/key/value/context statuses at `0`, with no
  guarded layer-2 output labels. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, tracked include dependencies,
  static-link, undefined-symbol, exported-symbol, tracked-artifact, and tracked
  large-file checks passed.

## 2026-05-11T13:54:02+02:00

- Added focused layer-2 attention output-projection matvec status coverage in
  `src/infer/token0_layer2_attn_output.s`. The new path waits for the retained
  layer-2 context, requires `blk.2.attn_output.weight` to be a bounded Q8_0
  `[4096 x 3072]` matrix, and fills private 3072-f32 output storage without
  publishing exact-hex output words yet.
- Verification evidence: the real target preserved the layer-2 value/context
  status path and reported `token0_layer2_attn_output_matvec: 1` with no
  `token0_layer2_attn_output*_f32_hex` labels. A temporary empty valid GGUF
  kept layer-2 output descriptor slots zeroed and kept layer-2
  norm/query/key/value/context/output statuses at `0`, again with no guarded
  layer-2 output-projection words. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, tracked include dependencies,
  static-link, undefined-symbol, exported-symbol, tracked-artifact, and tracked
  large-file checks passed.

## 2026-05-11T14:11:57+02:00

- Published the first guarded layer-2 attention output-projection slice from the
  focused output module. The labels are emitted only after
  `token0_layer2_attn_output_matvec: 1`; the help text now describes this path
  as an output matvec slice instead of status-only coverage.
- Verification evidence: the real target printed output-projection words
  `0x3eade180`, `0x3ee0fb2f`, `0xbff22222`, and `0x3e24eb6b`. The focused
  external oracle recomputed the full upstream layer-1 post-FFN residual,
  layer-2 attention RMSNorm, all 1024 layer-2 value rows, the expanded
  single-token grouped-query context, and the first four rows of
  `blk.2.attn_output.weight`; its output words matched the runtime exactly.
  A temporary empty valid GGUF kept the layer-2 output descriptor zeroed and
  kept layer-2 norm/query/key/value/context/output statuses at `0`, with no
  guarded layer-2 output-projection words. Build, harnesses, help, oracle
  py-compile, whitespace, runtime source extension, tracked include
  dependencies, static-link, undefined-symbol, exported-symbol,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T14:17:31+02:00

- Added status-only layer-2 post-attention residual coverage in a new focused
  inference module. The path waits for the retained layer-1 post-FFN residual
  and layer-2 attention output-projection statuses, rechecks the 3072-wide
  output descriptor, and writes private residual storage without publishing any
  residual exact-hex words yet.
- Verification evidence: the real target reported the upstream residual and
  layer-2 output statuses at `1`, then reported
  `token0_layer2_post_attn_residual: 1`. A temporary 24-byte empty valid GGUF
  kept the layer-2 output and post-attention residual statuses at `0`, with no
  guarded layer-2 output labels. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, tracked include dependencies,
  static-link, undefined-symbol, exported-symbol, tracked-artifact, and tracked
  large-file checks passed.

## 2026-05-11T14:24:38+02:00

- Published the first guarded layer-2 post-attention residual slice from the
  focused residual module. The new labels are emitted only after
  `token0_layer2_post_attn_residual: 1`; the empty-GGUF guard path still prints
  only the zero output/residual statuses and no guarded layer-2 residual words.
- Verification evidence: the real target printed residual words `0x3e9885c8`,
  `0xbd0e0bd8`, `0x3e299d00`, and `0x3d544d6e`. The focused external oracle
  reused the layer-2 attention output oracle path, performed the f32 residual
  adds, and matched those words exactly. Build, harnesses, help, oracle
  py-compile, whitespace, runtime source extension, tracked include
  dependencies, static-link, undefined-symbol, exported-symbol,
  tracked-artifact, and tracked large-file checks passed.
- The layer-2 attention through post-attention residual path is now a coherent
  branch, so the next iteration should run review gate pass 1 before starting
  layer-2 FFN feature work.

## 2026-05-11T14:30:12+02:00

- Completed the first review-gate pass for the layer-2 attention through
  post-attention residual branch. No blocking findings were found; the review
  emphasized mmap lifetime, tensor shape/type/bounds gates, status-gated exact
  slice publication, oracle arithmetic, and the near-1000-line split risk in the
  older layer-2 attention projection module.
- Verification evidence: build, harnesses, help, oracle py-compile, real-target
  runtime/oracle comparison, empty-GGUF guard behavior, whitespace, runtime
  source extension, tracked include dependency, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T14:45:29+02:00

- Completed the second review-gate pass for the layer-2 attention through
  post-attention residual branch. No blocking findings were found. The review
  treated Q/K projection slices as sidecar smoke coverage for this one-token
  branch; the durable handoff into layer-2 FFN work remains the guarded
  post-attention residual buffer.
- Verification evidence: build, harnesses, help, oracle py-compile, real-target
  layer-2 status/output/residual smoke, the focused residual oracle diff, and
  empty-GGUF guard behavior passed, along with the static purity, symbol,
  include-dependency, tracked-artifact, and large-file scans. A broad standalone
  Q/K/V oracle batch was stopped because the first standalone Q oracle was too
  slow for this review pass; the optimized residual oracle covers the
  output/residual handoff needed for the next layer-2 FFN descriptor step.

## 2026-05-11T14:52:59+02:00

- Added descriptor-only coverage for `blk.2.ffn_norm.weight` in the entry-side
  lookup chain. The retained slot prints found, dimension count, dim0, type, and
  relative offset after the layer-2 attention output descriptor. This step does
  not introduce a layer-2 FFN norm runtime status and does not read FFN norm
  payload bytes.
- Verification evidence: the real target printed found `1`, dimensions `1`,
  dim0 `3072`, type `0`, and offset `768811008` for the new descriptor while
  preserving the reviewed layer-2 attention output and post-attention residual
  statuses. A temporary 24-byte empty valid GGUF kept the new descriptor fields
  at `0`. Build, harnesses, help, oracle py-compile, whitespace, runtime source
  extension, include dependency, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T15:00:21+02:00

- Added status-only layer-2 FFN RMSNorm smoke coverage after the retained
  layer-2 post-attention residual. The path requires the retained
  `blk.2.ffn_norm.weight` descriptor, epsilon metadata, f32 `[3072]` shape, and
  complete mapped payload bounds before filling private activation storage. It
  intentionally publishes only `token0_layer2_ffn_norm` in this step.
- Verification evidence: the real target preserved the reviewed layer-2 output
  and post-attention residual statuses and printed `token0_layer2_ffn_norm: 1`.
  A temporary 24-byte empty valid GGUF kept the new status at `0`. Build,
  harnesses, help, oracle py-compile, whitespace, runtime source extension,
  include dependency, static-link, undefined-symbol, exported-symbol,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T15:09:57+02:00

- Published the first guarded layer-2 FFN RMSNorm activation slice from the
  focused FFN module. The four exact-hex labels are emitted only after
  `token0_layer2_ffn_norm: 1`; the empty-GGUF guard path still prints only the
  zero status and no guarded layer-2 FFN norm words.
- Verification evidence: the real target printed layer-2 FFN RMSNorm words
  `0x40522d9d`, `0xbf5d5852`, `0x3fc92f4e`, and `0x3f3f5579`. The focused
  external oracle recomputed the full upstream layer-1 post-FFN residual,
  layer-2 attention output, full layer-2 post-attention residual, and
  `blk.2.ffn_norm.weight` RMSNorm activation; its output words matched the
  runtime exactly. Build, harnesses, help, oracle py-compile, whitespace,
  runtime source extension, include dependency, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T15:17:15+02:00

- Added descriptor-only layer-2 FFN gate coverage in the entry-side lookup
  chain. The retained `blk.2.ffn_gate.weight` slot prints found, dimension
  count, dim0, dim1, type, and relative offset, and no new runtime path reads
  gate payload bytes in this step.
- Verification evidence: the real target printed found `1`, dimensions `2`,
  dim0 `3072`, dim1 `9216`, type `8`, and offset `738729984` while preserving
  the reviewed layer-2 post-attention residual and FFN RMSNorm slices. A
  temporary 24-byte empty valid GGUF kept the new slot zeroed and emitted no
  guarded layer-2 FFN norm words. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, include dependency, static-link,
  undefined-symbol, exported-symbol, tracked-artifact, and tracked large-file
  checks passed.

## 2026-05-11T15:23:20+02:00

- Added status-only layer-2 FFN gate matvec coverage in the focused FFN module.
  The path waits for the layer-2 FFN RMSNorm status, rechecks the retained
  `blk.2.ffn_gate.weight` Q8_0 `[3072 x 9216]` descriptor and full mapped
  payload bounds, fills private 9216-f32 output storage, and intentionally
  publishes only the status line.
- Verification evidence: the real target preserved the reviewed layer-2 FFN
  RMSNorm words and printed `token0_layer2_ffn_gate_matvec: 1`; a temporary
  24-byte empty valid GGUF kept the layer-2 FFN norm and gate matvec statuses
  at `0`. Build, harnesses, help, oracle py-compile, whitespace, runtime source
  extension, include dependency, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T15:31:56+02:00

- Published the first guarded layer-2 FFN gate matvec output slice from the
  focused FFN module. The four exact-hex labels are emitted only after
  `token0_layer2_ffn_gate_matvec: 1`; the 24-byte empty valid GGUF guard path
  still keeps the layer-2 FFN norm and gate statuses at `0` and emits no
  guarded gate output words.
- Verification evidence: the real target printed gate words `0x4204511d`,
  `0xbfebf5bb`, `0x414216d1`, and `0x3f72ec48`. The focused external oracle
  reused the full layer-2 FFN RMSNorm oracle path, dotted the activation with
  the first four rows of `blk.2.ffn_gate.weight`, and matched the runtime slice
  exactly. Build, harnesses, help, oracle py-compile, whitespace, runtime source
  extension, include dependency, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T15:37:10+02:00

- Added descriptor-only coverage for `blk.2.ffn_up.weight` in the entry-side
  lookup chain after the layer-2 FFN gate descriptor. The retained slot prints
  found, dimension count, dim0, dim1, type, and relative offset; no FFN up
  payload bytes are read in this step.
- Verification evidence: the real target printed found `1`, dimensions `2`,
  dim0 `3072`, dim1 `9216`, type `8`, and offset `768823296` while preserving
  the reviewed layer-2 FFN RMSNorm and gate output slices. A temporary 24-byte
  empty valid GGUF kept the new slot zeroed and did not unlock layer-2 FFN
  payload smoke. Build, harnesses, help, oracle py-compile, whitespace, runtime
  source extension, include dependency, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T15:43:58+02:00

- Added status-only layer-2 FFN up matvec coverage in the focused FFN module.
  The path mirrors the gate projection guards with the retained
  `blk.2.ffn_up.weight` Q8_0 `[3072 x 9216]` descriptor, verifies the complete
  mapped payload span, fills private 9216-f32 output storage, and publishes only
  `token0_layer2_ffn_up_matvec`.
- Verification evidence: the real target preserved the reviewed layer-2 FFN
  RMSNorm and gate output slices and printed `token0_layer2_ffn_up_matvec: 1`.
  A temporary 24-byte empty valid GGUF kept the layer-2 FFN norm, gate, and up
  matvec statuses at `0`. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, include dependency, static-link,
  undefined-symbol, exported-symbol, tracked-artifact, and tracked large-file
  checks passed.

## 2026-05-11T15:52:23+02:00

- Published the first guarded layer-2 FFN up matvec output slice from the
  focused FFN module. The four exact-hex labels are emitted only after
  `token0_layer2_ffn_up_matvec: 1`; the 24-byte empty valid GGUF guard path
  still keeps layer-2 FFN norm, gate, and up statuses at `0` and emits no
  guarded FFN norm/gate/up output words.
- Verification evidence: the real target printed up words `0x4289660c`,
  `0x3ef6cc7e`, `0xc1421f69`, and `0x3e00b19d`. The focused external oracle
  reused the full layer-2 FFN RMSNorm oracle path, dotted the activation with
  the first four rows of `blk.2.ffn_up.weight`, and matched the runtime slice
  exactly. Build, harnesses, help, oracle py-compile, whitespace, runtime
  source extension, include dependency, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T15:59:01+02:00

- Added status-only layer-2 FFN SwiGLU smoke coverage in the focused FFN module.
  The path is a pure activation step over the retained private gate/up matvec
  buffers, requires both projection statuses, fills a private 9216-f32 SwiGLU
  buffer, and publishes only `token0_layer2_ffn_swiglu`.
- Verification evidence: the real target printed `token0_layer2_ffn_swiglu: 1`
  after the reviewed layer-2 FFN norm/gate/up slices and printed no guarded
  SwiGLU output labels. A temporary 24-byte empty valid GGUF kept layer-2 FFN
  norm, gate, up, and SwiGLU statuses at `0`. Build, harnesses, help, oracle
  py-compile, whitespace, runtime source extension, include dependency,
  static-link, undefined-symbol, exported-symbol, tracked-artifact, and tracked
  large-file checks passed.

## 2026-05-11T16:05:07+02:00

- Published the first guarded layer-2 FFN SwiGLU activation slice from the
  focused FFN module. The four exact-hex labels are emitted only after
  `token0_layer2_ffn_swiglu: 1`; the 24-byte empty valid GGUF guard path keeps
  layer-2 FFN norm, gate, up, and SwiGLU statuses at `0` and emits no guarded
  layer-2 FFN output words.
- Verification evidence: the real target printed SwiGLU words `0x450e084e`,
  `0xbdf8abeb`, `0xc3132ce7`, and `0x3db01261`. The focused external oracle
  reused the full layer-2 FFN RMSNorm path, recomputed the first four gate/up
  projection words, applied `silu(gate[i]) * up[i]`, and matched the runtime
  slice exactly. Build, harnesses, help, oracle py-compile, whitespace, runtime
  source extension, include dependency, static-link, undefined-symbol,
  exported-symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T16:11:52+02:00

- Added descriptor-only coverage for `blk.2.ffn_down.weight` after the layer-2
  FFN up descriptor. The retained slot prints found, dimension count, dim0,
  dim1, type, and relative offset; the runtime still does not read layer-2
  FFN-down payload bytes.
- Verification evidence: the real target printed found `1`, dimensions `2`,
  dim0 `9216`, dim1 `3072`, type `8`, and offset `708648960` while preserving
  the reviewed layer-2 FFN norm/gate/up/SwiGLU status and exact-hex slices. A
  temporary 24-byte empty valid GGUF kept the new slot zeroed and emitted no
  guarded layer-2 FFN output words. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, include dependency, static-link,
  undefined-symbol, exported-symbol, no-payload-reference, tracked-artifact,
  and tracked large-file checks passed.

## 2026-05-11T16:18:34+02:00

- Added status-only layer-2 FFN-down matvec coverage in a focused down module.
  The path waits for the layer-2 SwiGLU status, rechecks the retained
  `blk.2.ffn_down.weight` Q8_0 `[9216 x 3072]` descriptor, proves the complete
  mapped payload span, fills private 3072-f32 down output storage, and prints
  only `token0_layer2_ffn_down_matvec`.
- Verification evidence: the real target preserved the reviewed layer-2 FFN
  norm/gate/up/SwiGLU exact-hex slices and printed
  `token0_layer2_ffn_down_matvec: 1`. A temporary 24-byte empty valid GGUF kept
  the layer-2 FFN norm, gate, up, SwiGLU, and down statuses at `0` and emitted
  no guarded layer-2 FFN down output words. Build, harnesses, help, oracle
  py-compile, whitespace, runtime source extension, include dependency,
  static-link, undefined-symbol, exported-symbol, no-output-slice,
  tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T16:28:01+02:00

- Published the first guarded layer-2 FFN-down matvec output slice from the
  focused down module. The four exact-hex labels are emitted only after
  `token0_layer2_ffn_down_matvec: 1`; the 24-byte empty valid GGUF guard path
  keeps layer-2 FFN norm/gate/up/SwiGLU/down statuses at `0` and emits no
  guarded layer-2 FFN output words.
- Verification evidence: the real target printed down words `0x440c0a37`,
  `0xc2008554`, `0xc2a866d8`, and `0xc15e77da`. The focused external oracle
  recomputed the full layer-2 FFN RMSNorm, gate/up projections, full 9216-word
  SwiGLU activation, and first four rows of `blk.2.ffn_down.weight`, matching
  the runtime slice exactly. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, include dependency, static-link,
  undefined-symbol, exported-symbol, tracked-artifact, and tracked large-file
  checks passed.

## 2026-05-11T16:36:23+02:00

- Added status-only layer-2 post-FFN residual coverage in the focused FFN-down
  module. The path waits for the retained layer-2 post-attention residual and
  FFN-down output statuses, rechecks the 3072-wide down descriptor, fills a
  retained 3072-f32 post-FFN residual buffer, and prints only
  `token0_layer2_post_ffn_residual`.
- Verification evidence: the real target preserved the reviewed layer-2 FFN
  norm/gate/up/SwiGLU/down exact-hex slices and printed
  `token0_layer2_post_ffn_residual: 1` with no residual output words. A
  temporary 24-byte empty valid GGUF kept the layer-2 post-attention residual,
  FFN norm/gate/up/SwiGLU/down, and post-FFN residual statuses at `0`. Build,
  harnesses, help, oracle py-compile, whitespace, runtime source extension,
  include dependency, static-link, undefined-symbol, exported-symbol,
  no-output-slice, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T16:44:25+02:00

- Published the first guarded layer-2 post-FFN residual slice from the focused
  FFN-down module. The labels are emitted only after the residual status is
  `1`, and the help text now describes this as an output slice rather than a
  status-only smoke.
- Verification evidence: the real-target runtime/oracle diff was empty for the
  layer-2 post-attention residual, FFN norm/gate/up/SwiGLU/down, and post-FFN
  residual public labels. The new residual words are `0x440c1d48`,
  `0xc200a8d7`, `0xc2a8120a`, and `0xc15da38d`; the 24-byte empty valid GGUF
  kept the layer-2 FFN and post-residual gates at `0` and emitted no guarded
  layer-2 FFN/post-residual output words.
- Decision: this completes the layer-2 FFN branch slice sequence, so the next
  iteration should enter the two-pass review gate before adding new feature
  scope.

## 2026-05-11T16:49:28+02:00

- Ran layer-2 FFN branch review gate pass 1. No blocking findings: ordering
  keeps mapped tensor reads before `gguf_release_mapping`, mapped payload reads
  remain descriptor/bounds-gated, retained-buffer steps are status-gated, and
  the external oracle boundary matches the public exact-hex slice chain through
  the post-FFN residual.
- Verification evidence: build/check/help/oracle py-compile passed; the
  real-target runtime/oracle comparison was empty for layer-2 post-attention
  residual plus FFN norm/gate/up/SwiGLU/down/post-residual labels; the empty
  valid GGUF guard path kept reviewed layer-2 statuses at `0` and emitted no
  guarded exact-hex labels; whitespace, source-extension, include-dependency,
  static-link, undefined-symbol, exported-symbol, tracked-artifact, and
  large-file scans passed.

## 2026-05-11T16:54:48+02:00

- Ran layer-2 FFN branch review gate pass 2. No blocking findings: exported and
  non-trivial internal contracts are present, handoff storage ownership is
  explicit, CLI/help text and smoke orchestration match the published layer-2
  FFN/post-residual surface, and Makefile dependency coverage remains explicit.
- Verification evidence: build/check/help/oracle py-compile passed; the
  real-target runtime/oracle comparison was empty for the reviewed layer-2
  public exact-hex labels; the empty valid GGUF guard path kept reviewed
  descriptor/status gates at `0` and emitted no guarded layer-2 output labels;
  whitespace, source-extension, include-dependency, static-link,
  undefined-symbol, exported-symbol, tracked-artifact, and large-file scans
  passed.
- Decision: the two-pass layer-2 FFN branch review gate is complete. Feature
  work may resume, but layer-3 work should start in focused layer-3 modules or
  Makefile-tracked include fragments rather than extending near-threshold
  layer-2 files.

## 2026-05-11T17:02:01+02:00

- Started layer-3 attention scope with descriptor-only retained lookup coverage
  for `blk.3.attn_norm.weight`. The bootstrap lookup, summary printer, request
  text, summary labels, and retained state live in focused Makefile-tracked
  layer-3 fragments; no layer-3 payload-read logic was added.
- Verification evidence: the real target printed found `1`, dimensions `1`,
  dim0 `3072`, type `0`, and offset `802246656` for the new descriptor while
  preserving the reviewed layer-2 post-FFN residual status and exact-hex words.
  A temporary 24-byte empty valid GGUF kept the new descriptor slot zeroed and
  emitted no guarded layer-2 post-FFN residual exact-hex labels. Build,
  harnesses, help, oracle py-compile, whitespace, runtime source extension,
  include dependency, descriptor-only, static-link, undefined-symbol, and symbol
  checks passed.

## 2026-05-11T17:10:24+02:00

- Added status-only layer-3 attention RMSNorm coverage in a focused inference
  module. The path waits for the retained layer-2 post-FFN residual, rechecks
  `blk.3.attn_norm.weight` and RMSNorm epsilon metadata, bounds the complete
  mapped 3072-f32 weight span, fills private layer-3 norm activation storage,
  and prints only `token0_layer3_attn_norm`.
- Verification evidence: the real target preserved the layer-2 post-FFN
  residual words and printed `token0_layer3_attn_norm: 1`; a temporary 24-byte
  empty valid GGUF kept the layer-3 descriptor fields and new status at `0`;
  scans found no layer-3 RMSNorm exact-hex output labels and no query/key/value
  or output expansion. Build, harnesses, help, oracle py-compile, whitespace,
  runtime source extension, include dependency, static-link, undefined-symbol,
  symbol, tracked-artifact, and tracked large-file checks passed.

## 2026-05-11T17:19:19+02:00

- Published the first guarded layer-3 attention RMSNorm output slice from the
  focused layer-3 module. The labels are emitted only after
  `token0_layer3_attn_norm: 1`, and the help text now describes layer-3
  attention RMSNorm as an output slice rather than a status-only smoke.
- Verification evidence: the real-target runtime/oracle diff was empty for the
  layer-2 post-FFN residual and layer-3 attention RMSNorm public labels. The
  new layer-3 RMSNorm words are `0x41be7bcf`, `0xc06721de`, `0xc13cb538`, and
  `0xbfe354dc`; the 24-byte empty valid GGUF kept the layer-3 descriptor fields
  and status at `0` and emitted no guarded layer-3 RMSNorm output words. Build,
  harnesses, help, oracle py-compile, whitespace, runtime source extension,
  include dependency, static-link, undefined-symbol, symbol, tracked-artifact,
  and tracked large-file checks passed.

## 2026-05-11T17:27:30+02:00

- Added descriptor-only retained lookup coverage for `blk.3.attn_q.weight` in
  the focused layer-3 bootstrap, state, rodata, and summary fragments. The path
  publishes the query matrix descriptor but does not add any layer-3 query
  matvec or Q8_0 payload read.
- Verification evidence: the real target reported the new descriptor as found
  with dimensions `3072x4096`, type `8`, and relative offset `815628288`, while
  preserving the existing layer-2 post-FFN residual and layer-3 RMSNorm exact
  slices. The runtime/oracle diff for those existing public labels was empty.
  A 24-byte header-only GGUF left both layer-3 descriptor slots and dependent
  statuses at `0`. Build, harnesses, help, oracle py-compile, whitespace,
  runtime source extension, include dependency, no-layer3-query-matvec,
  static-link, undefined-symbol, symbol, tracked-artifact, and tracked
  large-file scans passed.

## 2026-05-11T17:34:13+02:00

- Added status-only layer-3 attention query projection coverage in the focused
  layer-3 module. The smoke waits for `token0_layer3_attn_norm`, rechecks the
  retained query descriptor shape/type, bounds the complete Q8_0 matrix payload,
  fills private query-output storage, and prints no query output words yet.
- Verification evidence: the real target reported
  `token0_layer3_attn_q_matvec: 1` while preserving the layer-2 post-FFN
  residual and layer-3 RMSNorm guarded
  words, and a runtime/oracle diff for those existing public slices was empty.
  The 24-byte empty valid GGUF kept the layer-3 descriptors and dependent
  statuses at `0`, printed `token0_layer3_attn_q_matvec: 0`, and emitted no
  guarded output labels. Build, harnesses, help, oracle py-compile, whitespace,
  runtime source extension, include dependency, static-link, undefined-symbol,
  symbol, no-layer3-query-output-label, tracked-artifact, and tracked large-file
  scans passed.

## 2026-05-11T17:41:46+02:00

- Published the first guarded layer-3 attention query output slice from the
  focused layer-3 module. The labels are emitted only after
  `token0_layer3_attn_q_matvec: 1`, and the help text now describes layer-3
  query as an output slice rather than a status-only smoke.
- Verification evidence: the real-target runtime/oracle diff was empty for the
  layer-2 post-FFN residual, layer-3 attention RMSNorm, and layer-3 attention
  query public labels. The new query words are `0x3de458d2`, `0x3eae6d55`,
  `0x3d06883d`, and `0xbe14568c`; the 24-byte empty valid GGUF kept the
  layer-3 descriptor fields and dependent statuses at `0` and emitted no
  guarded layer-3 query output words. Build, harnesses, help, oracle
  py-compile, whitespace, runtime source extension, include dependency,
  static-link, undefined-symbol, symbol, tracked-artifact, and tracked
  large-file scans passed.

## 2026-05-11T17:48:20+02:00

- Added descriptor-only retained lookup coverage for `blk.3.attn_k.weight` in
  the focused layer-3 entry fragments. The runtime now publishes the key
  descriptor summary but still has no layer-3 key matvec, output storage, or
  payload-read path.
- Verification evidence: the real target reported the new descriptor as found
  with dimensions `3072x1024`, type `8`, and relative offset `798904320`, while
  preserving the layer-2 post-FFN residual, layer-3 RMSNorm, and layer-3 query
  output public exact-hex slices. The runtime/oracle diff for those existing
  public labels was empty. A 24-byte header-only GGUF left all layer-3
  descriptor slots and dependent statuses at `0`. Build, harnesses, help,
  oracle py-compile, whitespace, runtime source extension, include dependency,
  descriptor-only, static-link, undefined-symbol, symbol, tracked-artifact, and
  tracked large-file scans passed.

## 2026-05-11T17:55:14+02:00

- Added status-only layer-3 attention key projection coverage in the focused
  layer-3 module. The smoke waits for `token0_layer3_attn_norm`, rechecks the
  retained key descriptor shape/type, bounds the complete Q8_0 matrix payload,
  fills private key-output storage, and prints no key output words yet.
- Verification evidence: the real target reported
  `token0_layer3_attn_k_matvec: 1` while preserving the existing layer-2
  post-FFN residual, layer-3 RMSNorm, and layer-3 query output slices; the
  runtime/oracle diff for those existing public labels was empty. The 24-byte
  empty valid GGUF kept the layer-3 descriptors and dependent statuses at `0`,
  printed `token0_layer3_attn_k_matvec: 0`, and emitted no guarded layer-3 key
  output labels. Build, harnesses, help, oracle py-compile, whitespace, runtime
  source extension, include dependency, no-layer3-key-output-label,
  static-link, undefined-symbol, symbol, tracked-artifact, and tracked
  large-file scans passed.
- Verification note: two static probe invocations were corrected during
  verification because they inspected tool behavior rather than repository
  state; the corrected include-dependency and dynamic-section checks passed.

## 2026-05-11T18:02:46+02:00

- Published the first guarded layer-3 attention key output slice from the
  focused layer-3 module. The labels are emitted only after
  `token0_layer3_attn_k_matvec: 1`, and the help text now describes layer-3 key
  as an output slice rather than a status-only smoke.
- Verification evidence: the real-target runtime/oracle diff was empty for the
  layer-2 post-FFN residual, layer-3 attention RMSNorm, and layer-3 attention
  key public labels. The new key words are `0xbaf936b2`, `0xbcf1bab9`,
  `0x3c7af998`, and `0x3c825ee2`; the 24-byte empty valid GGUF kept the
  layer-3 descriptor fields and dependent statuses at `0` and emitted no
  guarded layer-3 key output words. Build, harnesses, help, oracle
  py-compile, whitespace, runtime source extension, include dependency,
  static-link, undefined-symbol, symbol, tracked-artifact, and tracked
  large-file scans passed.

## 2026-05-11T18:08:17+02:00

- Added descriptor-only retained lookup coverage for `blk.3.attn_v.weight` in
  the focused layer-3 entry fragments. The runtime now publishes the value
  descriptor summary but still has no layer-3 value matvec, output storage, or
  payload-read path.
- Verification evidence: the real target reported the new descriptor as found
  with dimensions `3072x1024`, type `8`, and relative offset `828997632`, while
  preserving the layer-2 post-FFN residual, layer-3 RMSNorm, layer-3 query
  output, and layer-3 key output public exact-hex slices. A 24-byte header-only
  GGUF left all layer-3 descriptor slots and dependent statuses at `0`. Build,
  harnesses, help, oracle py-compile, whitespace, runtime source extension,
  corrected include dependency, descriptor-only, static-link, undefined-symbol,
  symbol, tracked-artifact, and tracked large-file scans passed.
- Verification note: the first include-dependency probe inspected
  `source:include` strings because `rg` printed filenames; the corrected probe
  disabled filename prefixes and passed.

## 2026-05-11T18:14:44+02:00

- Added status-only layer-3 attention value projection coverage. The smoke waits
  for the layer-3 attention RMSNorm activation, rechecks the retained
  `blk.3.attn_v.weight` shape/type, bounds the complete Q8_0 matrix payload,
  and fills private value-output storage without publishing value output words.
- Verification evidence: the real target reported
  `token0_layer3_attn_v_matvec: 1` while preserving the existing layer-2
  post-FFN residual, layer-3 RMSNorm, layer-3 query output, and layer-3 key
  output slices; focused runtime/oracle diffs for the public query and key
  labels were empty. The 24-byte empty valid GGUF kept the layer-3 descriptors
  and dependent statuses at `0`, including the new value matvec status, and no
  layer-3 value output labels were emitted. Build, harnesses, help, oracle
  py-compile, whitespace, runtime source extension, include dependency,
  no-layer3-value-output-label, static-link, undefined-symbol, symbol,
  tracked-artifact, and tracked large-file scans passed.
- Planning note: the focused layer-3 attention module is now close enough to
  the 1000-line threshold that the next value-output feature slice should start
  with a behavior-preserving split or move into focused tracked source.

## 2026-05-11T18:22:17+02:00

- Split the existing layer-3 attention exact-hex rodata labels and printer
  helpers for the RMSNorm, query, and key public slices into a focused
  Makefile-tracked include. This preserves behavior while leaving the main
  layer-3 attention module comfortably below the project threshold before value
  output words are published.
- Verification evidence: the real-target runtime/oracle diff for the moved
  public labels was empty, the real target still reported all layer-3
  norm/query/key/value descriptors and matvec statuses as available, and no
  value output labels were emitted. The 24-byte empty GGUF kept every layer-3
  descriptor/status at `0` and emitted no guarded layer-3 exact-hex labels.
  Include dependency checks confirmed touching the new fragment schedules the
  layer-3 object rebuild; build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, static-link, undefined-symbol, symbol,
  tracked-artifact, and tracked large-file scans passed.

## 2026-05-11T18:30:21+02:00

- Published the first guarded layer-3 attention value output slice from the
  focused layer-3 slice include. The labels are emitted only after
  `token0_layer3_attn_v_matvec: 1`, using the private value projection buffer
  already filled by the bounded Q8_0 matvec smoke.
- Verification evidence: the focused runtime/oracle diff was empty for the
  layer-2 post-FFN residual, layer-3 attention RMSNorm, and new layer-3 value
  output public labels. The new value words are `0x3a75acca`, `0x3baaa296`,
  `0xbbde3580`, and `0x3bcdaf05`; the 24-byte empty valid GGUF kept all
  layer-3 descriptor fields and dependent statuses at `0` and emitted no
  guarded layer-3 exact-hex labels. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, include dependency, static-link,
  undefined-symbol, and symbol checks passed.

## 2026-05-11T18:37:00+02:00

- Added descriptor-only retained lookup coverage for `blk.3.attn_output.weight`
  in the focused layer-3 entry fragments. The runtime publishes the output
  descriptor summary but still has no layer-3 attention context, output matvec,
  output storage, or payload-read path for that matrix.
- Verification evidence: the real target reported the output descriptor as
  found with dimensions `4096x3072`, type `8`, and relative offset
  `802258944`, while preserving the existing layer-2 post-FFN residual,
  layer-3 RMSNorm, and layer-3 value public exact-hex labels against the
  focused external oracle. The 24-byte empty valid GGUF kept every layer-3
  descriptor field and dependent status at `0` and emitted no guarded layer-3
  exact-hex labels. Build, harnesses, help, oracle py-compile, whitespace,
  runtime source extension, include dependency, descriptor-only, static-link,
  undefined-symbol, symbol, tracked-artifact, and tracked large-file scans
  passed.
- Verification note: one initial empty-GGUF check accidentally created a
  21-byte file, and one static-link probe treated `readelf -d`'s zero exit
  status as a failure. Both probes were corrected and passed before commit.

## 2026-05-11T18:43:12+02:00

- Added a status-only layer-3 attention context smoke in a focused module. The
  context path requires the layer-3 Q/K/V matvec statuses, checks Q/K/V
  descriptor shapes, uses the retained output projection descriptor only as a
  shape guard, and expands the single-token grouped-query context from the
  existing layer-3 value output without reading output-projection payload bytes.
- Verification evidence: the real target reported
  `token0_layer3_attn_context: 1` while preserving the existing layer-2
  post-FFN residual, layer-3 attention RMSNorm, and layer-3 value public
  exact-hex labels against the focused external oracle. The 24-byte empty valid
  GGUF kept every layer-3 descriptor field and dependent status at `0`,
  including the new context status, and emitted no guarded layer-3 exact-hex
  labels. Build, harnesses, help, oracle py-compile, whitespace, runtime source
  extension, include dependency, no-output-payload, no-context-label,
  static-link, undefined-symbol, and symbol checks passed.

## 2026-05-11T18:51:04+02:00

- Published the first guarded layer-3 attention context exact-hex slice from
  the focused context module. The context printer is gated only on
  `token0_layer3_attn_context: 1`; the context builder still uses
  `blk.3.attn_output.weight` only as a descriptor shape guard and has no
  output-projection payload-read path.
- Verification evidence: the focused runtime/oracle diff was empty for the
  layer-2 post-FFN residual, layer-3 attention RMSNorm, layer-3 value, and new
  layer-3 context public labels. The new context words are `0x3a75acca`,
  `0x3baaa296`, `0xbbde3580`, and `0x3bcdaf05`; the 24-byte empty valid GGUF
  kept all layer-3 descriptor fields and dependent statuses at `0`, including
  `token0_layer3_attn_context: 0`, and emitted no guarded layer-3 context
  words. Build, harnesses, help, oracle py-compile, whitespace, runtime source
  extension, include dependency, no-output-payload, static-link,
  undefined-symbol, symbol, line-count, tracked-artifact, and tracked
  large-file scans passed.

## 2026-05-11T18:57:23+02:00

- Added status-only layer-3 attention output-projection coverage. The focused
  smoke consumes the guarded layer-3 context, rechecks the retained
  `blk.3.attn_output.weight` shape/type, bounds the complete Q8_0 matrix
  payload against the live mapping, and fills private output storage without
  publishing output exact-hex words.
- Verification evidence: the real target reported
  `token0_layer3_attn_output_matvec: 1`, while the 24-byte empty valid GGUF
  kept the context and new output matvec gates at `0`. Existing public layer-2
  post-FFN residual, layer-3 RMSNorm, value, and context exact-hex slices still
  matched the focused oracle; no `token0_layer3_attn_output*_f32_hex` labels
  were emitted. Clean build, harnesses, help, oracle py-compile, whitespace,
  runtime source extension, include dependency, static-link, undefined-symbol,
  symbol, line-count, tracked-artifact, and tracked large-file scans passed.

## 2026-05-11T19:04:15+02:00

- Published the first guarded layer-3 attention output-projection slice from
  the focused output module. The words are emitted only after
  `token0_layer3_attn_output_matvec: 1`, using the bounded Q8_0 matvec output
  storage already filled from the layer-3 single-token context.
- Verification evidence: the focused runtime/oracle diff was empty for the
  layer-2 post-FFN residual, layer-3 attention RMSNorm, layer-3 value, layer-3
  context, and new layer-3 output public labels. The new output words are
  `0x3ce80ee7`, `0x3da84154`, `0xbd1e4c02`, and `0xbd11752d`; the 24-byte empty
  valid GGUF kept the layer-3 context and output matvec statuses at `0` and
  emitted no guarded layer-3 context or output words.
- Planning note: the layer-3 attention chain now has public checks through the
  output projection. The next feature step would broaden scope into residual or
  FFN work, so the next iteration should start review gate pass 1.

## 2026-05-11T19:12:41+02:00

- Review gate pass 1 over the completed token-0 layer-3 attention chain found
  no blocking issue. The review specifically rechecked descriptor handoff,
  payload bounds gates, one-token context semantics, status-gated public slices,
  split discipline, and the focused output oracle comparison. One stale query
  runner contract phrase was corrected so it matches the guarded slice now
  emitted on success.
- Verification evidence: clean build and harnesses passed; the real-target
  runtime/oracle diff was empty for the reviewed layer-3 public labels; the
  temporary empty GGUF kept reviewed layer-3 descriptors/statuses at `0` and
  emitted no guarded layer-3 exact-hex labels; static-link, undefined-symbol,
  source-extension, include-dependency, line-count, tracked-artifact, and
  tracked large-file scans passed.

## 2026-05-11T19:19:37+02:00

- Review gate pass 2 over the completed token-0 layer-3 attention chain found
  no blocking issue and required no source change. The two-pass review gate is
  complete; the remaining documented risk is that context expansion is still a
  one-token grouped-query smoke and not a general attention implementation.
- Verification evidence: clean build and harnesses passed, with a
  post-documentation harness rerun; real-target runtime/oracle diff was empty
  for the reviewed layer-3 public labels; the empty valid GGUF kept reviewed
  layer-3 descriptors/statuses at `0` and emitted no guarded layer-3 exact-hex
  labels; static-link, undefined-symbol, source-extension, include-dependency,
  line-count, exported-symbol, tracked-artifact, and tracked large-file scans
  passed.

## 2026-05-11T19:30:29+02:00

- Added a focused layer-3 post-attention residual smoke. The runtime status is
  gated by the layer-2 post-FFN residual, the layer-3 attention output matvec,
  and the retained 3072-wide layer-3 output descriptor; the residual add reads
  only static handoff buffers and does not touch mapped tensor payload bytes.
- Verification evidence: the real target reported
  `token0_layer3_post_attn_residual: 1`; the focused runtime/oracle diff was
  empty for the layer-2 post-FFN residual, layer-3 attention output, and new
  layer-3 post-attention residual public labels. The new residual words are
  `0x440c1f18`, `0xc20054b6`, `0xc2a825d4`, and `0xc15e3502`.
- Guard-path evidence: after two malformed fixture attempts created 20-byte
  and 28-byte files, the corrected 24-byte header-only GGUF kept the layer-3
  output descriptor, output matvec status, and post-attention residual status
  at `0`, with no guarded layer-3 output or residual exact-hex labels.
- Build, harnesses, help, oracle py-compile, whitespace, runtime source
  extension, include dependency, static-link, undefined-symbol, symbol,
  line-count, tracked-artifact, and tracked large-file scans passed.

## 2026-05-11T19:42:43+02:00

- Added the layer-3 FFN RMSNorm smoke in a focused module. The path retains the
  `blk.3.ffn_norm.weight` descriptor, requires the layer-3 post-attention
  residual status, bounds the full f32 weight span against the live mapping,
  and publishes the guarded FFN-normalized activation slice.
- Verification evidence: the real target reported
  `layer3_ffn_norm_tensor_found: 1` and `token0_layer3_ffn_norm: 1`. The
  focused runtime/oracle diff was empty for the layer-3 attention output,
  post-attention residual, and FFN RMSNorm public labels; the new FFN RMSNorm
  words are `0x422e5251`, `0xc01a339f`, `0xbffb06aa`, and `0xbf19ba93`.
- Guard-path evidence: the corrected 24-byte header-only GGUF kept the new
  layer-3 FFN norm descriptor fields and dependent smoke status at `0`, and it
  emitted no guarded layer-3 attention output, post-attention residual, or FFN
  RMSNorm exact-hex labels. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, include dependency, static-link,
  undefined-symbol, symbol, line-count, tracked-artifact, and tracked
  large-file scans passed.

## 2026-05-11T19:50:25+02:00

- Added a status-only layer-3 FFN gate projection smoke. The runtime retains
  `blk.3.ffn_gate.weight`, requires the guarded layer-3 FFN RMSNorm activation,
  bounds the complete Q8_0 `[3072 x 9216]` payload, fills private gate output
  storage, and intentionally publishes no gate exact-hex output words yet.
- Verification evidence: the real target reported the gate descriptor as type
  `8`, dimensions `3072 x 9216`, relative offset `862420992`, and
  `token0_layer3_ffn_gate_matvec: 1`. An independent external parser check
  computed the same descriptor and a `30081024` byte payload span. The focused
  runtime/oracle diff for the already-published layer-3 attention output,
  post-attention residual, and FFN RMSNorm labels was empty; the 24-byte
  header-only GGUF kept the new descriptor and dependent status at `0`.

## 2026-05-11T19:58:43+02:00

- Published the first guarded layer-3 FFN gate projection slice. The runtime
  still computes the full 9216-word gate output after the existing payload
  bounds check, but now prints only the first four words when
  `token0_layer3_ffn_gate_matvec: 1`; the help text was updated from
  status-only to slice.
- Added an external layer-3 FFN gate oracle and note that reuse the full
  layer-3 FFN RMSNorm chain, then dot the first four rows of
  `blk.3.ffn_gate.weight` using the same scalar Q8_0 accumulation order as the
  runtime helper.
- Verification evidence: the real-target runtime/oracle diff was empty for the
  layer-3 attention output, post-attention residual, FFN RMSNorm, and new FFN
  gate public labels. The new gate words are `0xbfb2e5c3`, `0xbec7c2ba`,
  `0xbe4be710`, and `0x3d08c33e`; the 24-byte header-only GGUF kept the
  layer-3 FFN gate descriptor and dependent statuses at `0` and emitted no
  guarded gate output labels. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, include dependency, static-link,
  undefined-symbol, symbol, line-count, tracked-artifact, and tracked
  large-file scans passed.

## 2026-05-11T20:06:04+02:00

- Added the guarded layer-3 FFN up projection as a status-only smoke. The
  runtime now retains `blk.3.ffn_up.weight`, requires the layer-3 FFN RMSNorm
  activation, bounds the complete Q8_0 `[3072 x 9216]` payload, fills private
  9216-f32 up output storage, and intentionally emits no up exact-hex words
  yet.
- Verification evidence: the real target reported the up descriptor as type
  `8`, dimensions `3072 x 9216`, relative offset `892514304`, and
  `token0_layer3_ffn_up_matvec: 1`. The focused runtime/oracle diff for the
  already-published layer-3 attention output, post-attention residual, FFN
  RMSNorm, and FFN gate labels was empty; the 24-byte header-only GGUF kept the
  new descriptor and dependent status at `0` and emitted no guarded gate/up
  output labels.

## 2026-05-11T20:15:44+02:00

- Published the first guarded layer-3 FFN up projection slice. The existing
  bounded matvec still fills the full 9216-word private up buffer; stdout now
  prints only the first four words after `token0_layer3_ffn_up_matvec: 1`.
- Added an external layer-3 FFN up oracle and note. The oracle reuses the full
  layer-3 FFN RMSNorm chain, then dots the first four rows of
  `blk.3.ffn_up.weight` with the same scalar Q8_0 accumulation order used by
  the runtime helper.
- Verification evidence: the real-target runtime/oracle diff was empty for
  layer-3 attention output, post-attention residual, FFN RMSNorm, FFN gate, and
  new FFN up public labels. The new up words are `0x3fd71f53`, `0xbd86d8f4`,
  `0xbef486a9`, and `0xc026c494`; the 24-byte header-only GGUF kept the
  layer-3 FFN gate/up descriptors and dependent statuses at `0` and emitted no
  guarded gate/up output labels. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, include dependency, static-link,
  undefined-symbol, symbol, line-count, tracked-artifact, and tracked
  large-file scans passed.

## 2026-05-11T20:22:03+02:00

- Added the guarded layer-3 FFN SwiGLU activation as a status-only smoke. The
  runtime requires both retained gate/up projection statuses, combines only
  private 9216-f32 buffers through the shared scalar SwiGLU helper, and emits
  no activation exact-hex labels yet.
- Verification evidence: the real target reported
  `token0_layer3_ffn_swiglu: 1`; the focused `^token0_layer3_ffn_swiglu`
  output filter showed only that status line. Existing layer-3 FFN gate and up
  runtime/oracle diffs stayed empty, and the 24-byte header-only GGUF kept the
  new status at `0` with no guarded layer-3 FFN activation output labels.
  Build, harnesses, help, oracle py-compile, whitespace, runtime source
  extension, include dependency, static-link, undefined-symbol, symbol,
  line-count, tracked-artifact, and tracked large-file scans passed.

## 2026-05-11T20:29:25+02:00

- Published the first guarded layer-3 FFN SwiGLU activation slice. The runtime
  still requires both layer-3 FFN gate/up projection statuses before calling
  the shared scalar activation helper, and it now prints only the first four
  activation words after `token0_layer3_ffn_swiglu: 1`.
- Added an external layer-3 FFN SwiGLU oracle and note. The oracle reuses the
  full layer-3 FFN RMSNorm chain plus focused gate/up projection loaders, then
  applies the same scalar `silu(gate) * up` formula to the first four public
  gate/up pairs.
- Verification evidence: the real-target runtime/oracle diff was empty for
  layer-3 attention output, post-attention residual, FFN RMSNorm, FFN gate,
  FFN up, and new FFN SwiGLU public labels. The new SwiGLU words are
  `0xbeee5aef`, `0x3c29e800`, `0x3d2f6fb9`, and `0xbd3528b3`; the 24-byte
  header-only GGUF kept the layer-3 FFN statuses at `0` and emitted no guarded
  gate/up/SwiGLU output labels. Build, harnesses, help, oracle py-compile,
  whitespace, runtime source extension, include dependency, static-link,
  undefined-symbol, symbol, line-count, tracked-artifact, and tracked
  large-file scans passed.

## 2026-05-11T20:38:44+02:00

- Added retained `blk.3.ffn_down.weight` descriptor coverage and a focused
  status-only layer-3 FFN down projection module. The new smoke requires the
  guarded layer-3 FFN SwiGLU activation, validates the down descriptor as
  Q8_0 `[9216 x 3072]`, bounds the complete payload, fills private down output
  storage, and deliberately publishes no down exact-hex words yet.
- Verification evidence: the real target reported the down descriptor at
  relative offset `832339968` and `token0_layer3_ffn_down_matvec: 1`. The
  existing layer-3 FFN public slices still matched the external SwiGLU oracle
  exactly; the 24-byte header-only GGUF kept the down descriptor and dependent
  status at `0` with no guarded layer-3 FFN down output labels.

## 2026-05-11T20:48:36+02:00

- Published the first guarded layer-3 FFN down projection slice from the
  focused down module. The matvec still fills the private 3072-word output
  buffer after the existing descriptor and payload-span checks; stdout now
  emits only the first four exact-hex words when
  `token0_layer3_ffn_down_matvec: 1`.
- Added an external layer-3 FFN down oracle and note. The oracle recomputes the
  full layer-3 FFN RMSNorm chain, all 9216 gate/up rows, the complete SwiGLU
  activation, and the first four rows of `blk.3.ffn_down.weight`.
- Verification evidence: the real-target runtime/oracle diff was empty for
  layer-3 FFN RMSNorm, gate, up, SwiGLU, and new down public labels. The new
  down words are `0x3def4ab2`, `0x3e0b094a`, `0xbf222273`, and `0xbc2b9ed5`;
  the 24-byte header-only GGUF kept layer-3 FFN statuses at `0` and emitted no
  guarded layer-3 FFN output labels. Build, harnesses, help, oracle
  py-compile, whitespace, runtime source extension, include dependency,
  static-link, undefined-symbol, symbol, line-count, tracked-artifact, and
  tracked large-file scans passed.

## 2026-05-11T20:57:02+02:00

- Added status-only layer-3 post-FFN residual coverage in the focused down
  module. The smoke requires both the retained layer-3 post-attention residual
  and FFN-down matvec statuses, rechecks the down output width as 3072, fills
  retained 3072-f32 post-FFN residual storage, and emits only
  `token0_layer3_post_ffn_residual`.
- Verification evidence: the real target reported the retained down output
  width as `3072`, kept the published down words unchanged, and reported
  `token0_layer3_post_ffn_residual: 1` without any post-FFN residual exact-hex
  labels. The 24-byte header-only GGUF reported the new status as `0` and
  emitted no guarded residual labels. The focused layer-3 FFN runtime/oracle
  diff stayed empty for RMSNorm, gate, up, SwiGLU, and down public labels.
- The next residual slice oracle should expect the first four post-FFN residual
  words to be `0x440c2692`, `0xc1ff9359`, `0xc2a96a19`, and `0xc15e5fea`
  when computed as f32-rounded post-attention residual plus FFN-down output.

## 2026-05-11T21:03:38+02:00

- Published the first guarded layer-3 post-FFN residual slice from the focused
  down module. The runtime still requires the layer-3 post-attention residual
  and FFN-down statuses, then prints only the first four residual words when
  `token0_layer3_post_ffn_residual: 1`.
- Added an external layer-3 post-FFN residual oracle and note. The oracle
  reuses the full layer-3 FFN down path and performs the final scalar f32 add
  against the retained layer-3 post-attention residual.
- Verification evidence: the real-target runtime/oracle diff was empty for
  layer-3 post-attention residual, FFN RMSNorm, gate, up, SwiGLU, down, and
  new post-FFN residual public labels. The new residual words are
  `0x440c2692`, `0xc1ff9359`, `0xc2a96a19`, and `0xc15e5fea`; the 24-byte
  header-only GGUF kept layer-3 FFN/residual statuses at `0` and emitted no
  guarded layer-3 FFN or post-FFN residual exact-hex labels.

## 2026-05-11T21:10:06+02:00

- Completed review gate pass 1 for the token-0 layer-3 FFN/down/post-residual
  chain. No blocking issues were found and no source changes were required.
- Verification evidence: clean build and harnesses passed, followed by a
  post-documentation build/check rerun; the real-target runtime/oracle diff was
  empty across layer-3 post-attention residual, FFN RMSNorm, gate, up, SwiGLU,
  down, and post-FFN residual public labels; the empty-header GGUF kept the
  reviewed layer-3 FFN/residual statuses at `0` and emitted no guarded
  exact-hex labels from the reviewed chain. Static purity, include dependency,
  symbol, line-count, artifact, and large-file scans passed.
