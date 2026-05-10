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

## 2026-05-10T12:18:46Z

- First GGUF loader smoke path maps the input file read-only and validates only
  the fixed 24-byte header fields before unmapping.
- Decision: the early count-field guard rejects counts with the high bit set so
  later parser arithmetic can stay in a conservative signed range.
- Verification evidence: a synthetic `/tmp` GGUF v3 header fixture passed and a
  high-count fixture failed with the intended loader error; loader `strace`
  showed direct file, map, unmap, close, write, and exit syscalls.
