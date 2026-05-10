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
