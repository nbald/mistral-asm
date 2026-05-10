# Autonomous Workflow

This file explains how to operate the autonomous project loop. It does not
replace `work/STATE.md`; the state file remains the compact continuation source
for the agent.

## Source Of Truth

- `git log` is authoritative for completed commits.
- `work/STATE.md` is authoritative for the current milestone and next exact step.
- `work/PLAN.md` is authoritative for project policy and milestone order.
- `work/WORKLOG.md` keeps durable context only. It is not a second git log.
- `work/control/INBOX.md` is transient operator input and is ignored by git.

## Running

Start one autonomous iteration:

```sh
scripts/autonomous-loop.sh 1
```

Start several iterations:

```sh
scripts/autonomous-loop.sh 5
```

The loop uses `gpt-5.5` and xhigh reasoning by default:

```sh
CODEX_MODEL=gpt-5.5 CODEX_REASONING_EFFORT=xhigh scripts/autonomous-loop.sh 1
```

Use only one autonomous loop per worktree. Multi-run locking is out of scope.

## Monitoring

Show current status once:

```sh
scripts/status.sh
```

Refresh status every five seconds:

```sh
scripts/watch-status.sh 5
```

Status includes git state, recent commits, `work/STATE.md`, recent worklog tail,
operator control files, current Codex PID metadata, and the latest final message
from `work/runs/`.

## Operator Control

Inject instructions for the next iteration without interrupting current work:

```sh
scripts/control.sh instruction "prioritize readable comments in ASM files"
```

Inject instructions and interrupt the current Codex process group:

```sh
scripts/control.sh interrupt-instruction "pause implementation and run review"
```

Pause before the next iteration starts:

```sh
scripts/control.sh pause
```

Resume after a pause:

```sh
scripts/control.sh resume
```

Stop the loop and interrupt the current Codex process group:

```sh
scripts/control.sh stop
```

Clear a stop request:

```sh
scripts/control.sh clear-stop
```

Clear handled transient instructions:

```sh
scripts/control.sh clear-instructions
```

## Review Discipline

The agent must run review passes after major subsystems and whenever
`work/STATE.md` makes review the next exact step. Review notes go under
`work/reviews/` when they contain actionable findings or a useful explicit clean
result.

Near final acceptance, the agent must repeatedly ask itself `are you happy?`.
If the answer is not yes, it must record why, fix or document the issue, verify,
commit, and ask again later. The final loop stops only when the committed answer
is yes with supporting verification.

