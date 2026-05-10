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
