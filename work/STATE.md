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
- `work/STATE.md`
- `work/WORKLOG.md`

## Required Verification

- `make`
- `readelf` proves no dynamic dependencies/libc.
- `strace` shows direct expected syscalls for `--help`.
- `git diff --check`

## Next Exact Step

Implement the minimal pure ASM binary for Milestone 2.
