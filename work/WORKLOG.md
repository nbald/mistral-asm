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
