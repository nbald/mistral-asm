# STATE

## Current Milestone

Milestone 3: GGUF loader.

## Current Exact Task

Add a bounds-checked GGUF metadata walker that advances over metadata key/value
records and validates the aligned tensor-directory start, without dumping values
yet.

## Known Blockers

None.

## Relevant Files

- `README.md`
- `Makefile`
- `src/entry/_start.s`
- `src/sys/*.s`
- `src/gguf/load_header.s`
- `work/AUTONOMOUS.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Required Verification

- `make`
- `./mistral-asm --help`
- `readelf` proves no dynamic dependencies/libc
- `strace` shows direct expected syscalls for `--help`
- loader smoke tests against tiny synthetic GGUF fixtures outside git
- `git diff --check`

## Last Verification

- `make clean` then `make` passed.
- `./mistral-asm --help` printed usage with the model-path loader form.
- `readelf -d mistral-asm` reported no dynamic section.
- `readelf -l mistral-asm` showed no program interpreter.
- `strace -e trace=write,exit,exit_group ./mistral-asm --help` showed direct
  `write(1, ..., 165)` and `exit(0)`.
- A 24-byte `/tmp` GGUF v3 header fixture returned `GGUF header ok`.
- Loader syscall trace on that fixture showed direct `openat`, `fstat`, `mmap`,
  `munmap`, `close`, `write`, and `exit`.
- A `/tmp` fixture with a count field above the supported signed range failed
  with `mistral-asm: unsupported GGUF count field` and exit status 3.
- `git diff --check` passed.

## Next Exact Step

Add the metadata walker described above, keeping all parser reads bounded by the
mapped file length.
