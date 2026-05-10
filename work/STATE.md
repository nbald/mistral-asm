# STATE

## Current Milestone

Milestone 3: GGUF loader.

## Current Exact Task

Implement the first narrow GGUF loader path: accept a model path argument, add
direct `openat`, `fstat`, `mmap`, and `munmap` syscalls, then validate the GGUF
magic/version/count fields without parsing metadata values yet.

## Known Blockers

None.

## Relevant Files

- `README.md`
- `Makefile`
- `src/entry/_start.s`
- `src/sys/`
- `src/gguf/`
- `work/AUTONOMOUS.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Required Verification

- `make`
- `./mistral-asm --help`
- `readelf` proves no dynamic dependencies/libc
- `strace` shows direct expected syscalls for `--help`
- loader smoke test against a tiny synthetic GGUF header fixture outside git
- `git diff --check`

## Last Verification

- `make` passed.
- `./mistral-asm --help` printed usage.
- `readelf -d mistral-asm` reported no dynamic section.
- `readelf -l mistral-asm` showed no program interpreter.
- `strace -e trace=write,exit,exit_group ./mistral-asm --help` showed one
  `write(1, ..., 143)` and `exit(0)`.
- `git diff --check` passed.

## Next Exact Step

Implement GGUF file open/map/header validation from a model path argument.
