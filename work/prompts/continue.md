Continue the mistral-asm autonomous project.

Do not rely on prior conversation history. Treat the repository as the source of
truth.

First inspect, in this order:

1. `git status --short --branch`
2. `git log --oneline -5` if commits exist
3. `work/GOAL.md`
4. `work/PLAN.md`
5. `work/STATE.md`
6. `tail -120 work/WORKLOG.md` if the file exists

Do not read the whole worklog unless `work/STATE.md` explicitly says it is
needed. `work/STATE.md` is the compact continuation state; keep it current and
short.

Project contract:

- Runtime source must stay 100% GNU `as` Intel assembly.
- Runtime source files must be `.s`.
- No libc, no C, no Rust, no Python, and no generated code in the runtime.
- Build runtime objects with `as` and link with `ld`.
- Use Linux syscalls directly from `_start`.
- Target AMD Zen 2 x86-64. AVX2/FMA are available, but correctness comes before
  optimization.
- Do not add NUMA or dual-socket logic in early milestones.
- Model files, binaries, large dumps, long logs, traces, and perf outputs must
  not be committed.
- `llama.cpp` may be used only as an external oracle. Never link or vendor it
  into the runtime.
- Do not rewrite git history.
- Do not revert user changes unless explicitly instructed.

Work loop:

1. Continue from `work/STATE.md`, not from memory.
2. Do exactly one atomic, commit-sized step toward the next incomplete
   milestone.
3. Before editing, briefly state what files you are about to change and why.
4. After editing, run the relevant verification for that step.
5. Update `work/STATE.md` with current milestone, completed work, verification
   status, blockers, relevant files, and the next exact step.
6. Append a short entry to `work/WORKLOG.md` with date, change, verification,
   commit message, and next step. Keep entries concise.
7. Commit the completed step with a short narrative commit message.

If blocked:

- Stop after updating `work/STATE.md` with the blocker and the next proposed
  recovery step.
- Commit useful documentation or proof only if it is coherent and valuable.
- Report the blocker concisely.

Report at the end:

- Commit hash, if a commit was made.
- Verification result.
- Next exact step from `work/STATE.md`.

