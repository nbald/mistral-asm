# PLAN

## Contract

- Runtime source is only `.s`.
- Syntax is GNU `as` Intel.
- Build uses `as` and `ld` through `Makefile`.
- Autonomous runs use `gpt-5.5` with `model_reasoning_effort = "xhigh"` unless
  explicitly overridden by environment variables.
- Run only one autonomous loop per worktree. Multi-run locking is out of scope.
- CPU target is AMD Zen 2 x86-64 with AVX2/FMA available.
- No NUMA or dual-socket logic in the first milestones.
- Model target is Unsloth Ministral 3 3B Instruct Q8_0 GGUF.
- GGUF support starts narrow: v3, little-endian, `mistral3`, Q8_0 tensors.
- Initial generation path accepts token IDs first, then adds tokenizer decode,
  then tokenizer encode.

## Milestones

1. Repository method: docs, prompt loop, ignore rules, working state.
2. Pure ASM proof: minimal `_start`, `write`, `exit`, `--help`, no libc.
3. GGUF loader: `openat`, `fstat`, `mmap`, header, counts, alignment.
4. Review pass: inspect the generated code and docs before expanding parser
   scope.
5. Metadata dump: architecture, context, vocab, layers, tensor count.
6. Tensor directory: names, dimensions, types, offsets.
7. Review pass: inspect GGUF parsing, error handling, and purity proof.
8. Q8_0 matvec: scalar first, AVX2 later.
9. One-token forward from token IDs, verified against `llama.cpp`.
10. Review pass: inspect math correctness and oracle comparison quality.
11. Multi-token greedy generation from token IDs.
12. Tokenizer decode in ASM.
13. Tokenizer encode in ASM.
14. Prompt text CLI and first useful text output.
15. Final review loop: repeatedly ask "are you happy?" and fix issues until
    the documented answer is yes.
16. Zen 2 optimization pass.

## Documentation Policy

- `work/STATE.md` is the compact source of truth for continuation.
- `work/WORKLOG.md` is durable context, not a second git log. It is normally
  append-only, but explicit review commits may compact redundant entries.
- Agents must not read the whole worklog once it grows; read only its tail.
- `work/control/README.md` documents operator control. Live instructions go to
  ignored `work/control/INBOX.md`.
- `work/oracle/` stores small oracle notes, hashes, commands, and excerpts.
- Large model files, binaries, traces, dumps, logs, and perf output are ignored.
- Do not duplicate commit hashes, commit messages, changed-file lists, or routine
  next-step text across `work/` files; git and `work/STATE.md` are authoritative
  for those.

## Operator Control Policy

- Use `scripts/control.sh instruction "..."` to inject instructions for the
  next iteration without interrupting the current run.
- Use `scripts/control.sh interrupt-instruction "..."` to inject instructions
  and interrupt the current Codex process group.
- Use `scripts/control.sh clear-instructions` after handled transient inbox
  entries have been recorded durably.
- Use `scripts/control.sh pause` to prevent the next iteration from starting,
  then `scripts/control.sh resume` to continue.
- Use `scripts/control.sh interrupt` to send SIGINT to the current Codex process.
- Use `scripts/control.sh stop` to request loop stop and interrupt the current
  Codex process.
- `interrupt-instruction` may end the current iteration with a non-zero Codex
  status; if more iterations remain and the inbox is non-empty, the loop
  continues and the next iteration reads the inbox.
- `work/runs/current.pid`, `work/runs/current.start`, `work/control/PAUSE`,
  `work/control/STOP`, and `work/control/INBOX.md` are transient control files
  and are not committed.

## Review Policy

- Run a code-review pass after major subsystems and before increasing scope.
- Reviews prioritize correctness, auditability, purity, failure modes, and
  missing verification.
- Commit review notes under `work/reviews/` when they contain actionable
  findings or an explicit clean result.
- At final acceptance, run an "are you happy?" loop: answer honestly, list why
  not if the answer is no, fix or document the issue, and repeat until the
  committed answer is yes.
