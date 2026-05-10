# STATE

## Current Milestone

Milestone 2: pure ASM proof.

## Current Exact Task

Add the first pure assembly build skeleton: `Makefile`, `_start`, direct
`write`/`exit` syscalls, and `--help` output.

## Known Blockers

None.

## Relevant Files

- `Makefile`
- `src/entry/_start.s`
- `src/sys/`
- `scripts/status.sh`
- `scripts/watch-status.sh`
- `scripts/control.sh`
- `scripts/autonomous-loop.sh`
- `work/control/INSTRUCTIONS.md`
- `work/STATE.md`
- `work/WORKLOG.md`
- `work/reviews/2026-05-10-bootstrap-review.md`

## Verification Status

Bootstrap verification passed:

- `bash -n scripts/autonomous-loop.sh`
- `scripts/autonomous-loop.sh` is executable.

Monitoring helper verification passed:

- `bash -n scripts/status.sh`
- `bash -n scripts/watch-status.sh`
- both scripts are executable.

Operator control verification passed:

- `bash -n scripts/autonomous-loop.sh`
- `bash -n scripts/control.sh`
- `bash -n scripts/status.sh`
- `bash -n scripts/watch-status.sh`
- `git diff --check`

Bootstrap review result:

- Avoid using `work/WORKLOG.md` as a second git log.
- Avoid keeping stale commit pointers in `work/STATE.md`.
- Keep only current verification status in state; move durable findings to
  reviews or concise worklog entries.

## Next Exact Step

Implement the minimal pure ASM binary for Milestone 2.
