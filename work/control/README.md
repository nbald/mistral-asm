# Operator Control

Committed documentation for the autonomous control channel lives here. Live
operator instructions do not.

Use the transient inbox for instructions:

```sh
scripts/control.sh instruction "prioritize parser readability"
```

Use interruption when the current Codex process should stop and pick up the new
instruction on the next run:

```sh
scripts/control.sh interrupt-instruction "pause feature work and review first"
```

The live inbox is `work/control/INBOX.md`. It is ignored by git to keep operator
chatter out of atomic commits. When an agent handles inbox entries, it should
record the durable result in `work/STATE.md` or `work/WORKLOG.md`, then clear the
transient inbox with:

```sh
scripts/control.sh clear-instructions
```

