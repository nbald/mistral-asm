# Bootstrap Review - 2026-05-10

## Findings

1. `work/WORKLOG.md` was acting as a second git log by recording commit messages
   and routine next-step text. This would grow quickly and drift from real git
   history.
2. `work/STATE.md` stored a stale "last completed commit" pointer. The prompt
   already reads `git log`, so this state duplicated an authoritative source and
   became wrong after the next commit.
3. `scripts/autonomous-loop.sh` wrote `work/runs/current.pid` but had no trap for
   shell exit. Normal child failures removed the file, but process-level
   interruption could leave stale status.

## Actions Taken

- `WORKLOG.md` now keeps durable context only: decisions, evidence, blockers, and
  review notes.
- `STATE.md` no longer carries a last-commit field.
- `autonomous-loop.sh` now has an EXIT trap to remove `current.pid`.

## Residual Risk

- `work/control/INSTRUCTIONS.md` can grow if used heavily. If it becomes noisy,
  split it later into active instructions and an archive.

