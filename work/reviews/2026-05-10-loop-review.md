# Loop Review - 2026-05-10

## Findings

1. A repo-local lock would prevent two autonomous loop runners from operating on
   the same worktree. This is intentionally out of scope; run one loop per
   worktree.
2. `interrupt-instruction` previously interrupted the active Codex process but a
   multi-iteration loop would exit on the resulting non-zero status.
3. Run output filenames used second-resolution timestamps and could collide on
   fast failures.
4. Capturing non-zero Codex exits by toggling `set -e` inside `start_codex`
   could terminate the loop before the status was handled.

## Actions Taken

- Documented the single-loop convention.
- Let multi-iteration loops continue after a non-stop Codex failure, so an
  interrupted iteration can be followed by a fresh one that reads the inbox.
  This continuation is limited to the case where the inbox is non-empty.
- Added nanoseconds and iteration number to run output filenames.
- Added PID start metadata checks before signaling the current Codex process.
- Replaced `errexit` toggling with `if wait` / `if start_codex` status capture.

## Residual Risk

- Stale PID reuse is mitigated by checking `/proc/$pid/stat` start time before
  signaling. Running multiple loops remains unsupported.
