# Control Review - 2026-05-10

## Findings

1. Tracked operator instructions would dirty the worktree and could be swept into
   unrelated atomic commits.
2. `STATE.md` still contained historical verification details and files not
   relevant to the next task.
3. Resume-mode interruption could target a wrapper process instead of the full
   Codex process tree.
4. `watch-status.sh` accepted invalid intervals and deferred the error to
   `watch` or `sleep`.

## Actions Taken

- Replaced tracked live instructions with committed `work/control/README.md` and
  ignored `work/control/INBOX.md`.
- Added `interrupt-instruction` and `clear-instructions` control commands.
- `interrupt-instruction` appends the instruction even if no Codex process is
  currently running.
- Started Codex under `setsid` when available and made interruption target the
  process group first.
- Compacted `STATE.md` to current task, blockers, relevant files, required
  verification, and next action.
- Validated watch interval input.

## Residual Risk

- Instructions injected without interruption are still picked up only on the
  next iteration. This is intentional; use `interrupt-instruction` for urgent
  operator changes.
- Running multiple autonomous loops in the same worktree is unsupported by
  project decision. There is no locking.
