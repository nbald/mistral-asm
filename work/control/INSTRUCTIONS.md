# Operator Instructions

This file is the operator channel for the autonomous loop.

Use it for instructions that should be read by the next Codex iteration without
resuming the previous conversation. Newer instructions override older
conflicting instructions.

Append one-off or persistent instructions with:

```sh
scripts/control.sh instruction "your instruction here"
```

The agent must read this file near the start of every iteration. When an
instruction has been handled, the agent records that in `work/STATE.md` and
`work/WORKLOG.md`. The agent must not delete operator text unless explicitly
asked.

