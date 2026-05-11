Continue the mistral-asm autonomous project.

Do not rely on prior conversation history. Treat the repository as the source of
truth.

First inspect, in this order:

1. `git status --short --branch`
2. `git log --oneline -5` if commits exist
3. `work/GOAL.md`
4. `work/PLAN.md`
5. `work/STATE.md`
6. `work/control/README.md` if it exists
7. `work/control/INBOX.md` if it exists
8. `tail -120 work/WORKLOG.md` if the file exists

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
- Honor ignored `work/control/INBOX.md`; newer operator instructions override
  older conflicting instructions.
- Do not let runtime source files become catch-all monoliths. Before adding
  substantial code to a file near or above 1000 lines, split it by clear
  responsibility or move the work into a focused module. If `.include`
  fragments are introduced, list every fragment in the Makefile dependencies so
  incremental rebuilds notice edits.

Assembly comment policy:

- Every exported assembly function must start with a human-readable contract:
  purpose, inputs, outputs, clobbers, ownership/lifetime rules, and error
  behavior when relevant.
- Non-trivial internal functions must also have a short contract comment.
- Comment logical blocks and non-obvious instructions inside functions.
- Prefer explaining Linux ABI details, file-format offsets, register ownership,
  cleanup paths, and why a branch exists.
- Avoid comments that merely restate the mnemonic, such as "move rax into rbx".
- Assembly should be readable by a human auditor following the repo history.

Work loop:

1. Continue from `work/STATE.md`, not from memory.
2. Do exactly one atomic, commit-sized step toward the next incomplete
   milestone.
3. Before editing, briefly state what files you are about to change and why.
4. After editing, run the relevant verification for that step.
5. Update `work/STATE.md` with current milestone, completed work, verification
   status, blockers, relevant files, and the next exact step.
6. Normally append a short entry to `work/WORKLOG.md` with durable context that
   is not already in git: decisions, verification evidence, blockers, or review
   notes. Do not duplicate commit hashes, commit messages, changed-file lists, or
   the next exact step unless that detail is needed to understand a decision.
   Explicit review commits may compact redundant worklog entries.
7. If operator inbox entries were handled, record the durable result in
   `work/STATE.md` or `work/WORKLOG.md`, then clear the transient inbox with
   `scripts/control.sh clear-instructions`. If an instruction is meant to be
   persistent, encode it into a tracked work file before clearing the inbox.
8. Before any commit, ask yourself exactly: "are you happy?" If the answer is
   negative, mixed, or anything other than a clear yes, fix or document the
   reason, verify again, and repeat the question. Commit only after the answer
   is clearly yes.
9. Commit the completed step with a short narrative commit message.

Review loop:

- If `work/STATE.md` says the next step is a review pass, or if the next feature
  step would increase scope after a major subsystem, run a review gate before
  feature work resumes.
- A review gate is exactly two consecutive atomic review passes. Do not satisfy
  both passes with one review note.
- Commit each review pass under `work/reviews/` when there are findings or a
  useful explicit clean result.
- If review finds issues, update `work/STATE.md` so the next exact step fixes the
  highest-impact issue instead of continuing feature work.

Final happiness loop:

- Near final acceptance, ask yourself exactly: "are you happy?"
- If the honest answer is not yes, write the reason in `work/STATE.md`, fix or
  document the highest-impact reason, verify, commit, and ask again in a later
  iteration.
- Stop the final loop only after `work/STATE.md` and `work/WORKLOG.md` record a
  yes answer with the verification that justifies it.

If blocked:

- Stop after updating `work/STATE.md` with the blocker and the next proposed
  recovery step.
- Commit useful documentation or proof only if it is coherent and valuable.
- Report the blocker concisely.

Report at the end:

- Commit hash, if a commit was made.
- Verification result.
- Next exact step from `work/STATE.md`.
