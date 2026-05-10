# STATE

## Current Milestone

Milestone 3: GGUF loader.

## Current Exact Task

Add a bounds-checked GGUF tensor-info directory walker that advances over tensor
descriptors and validates tensor-data alignment, without dumping tensor names
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
- `./mistral-asm --help` printed usage with the GGUF metadata validation
  milestone text.
- `readelf -d mistral-asm` reported no dynamic section.
- `readelf -l mistral-asm` showed no program interpreter.
- `strace -e trace=write,exit,exit_group ./mistral-asm --help` showed direct
  `write(1, ..., 167)` and `exit(0)`.
- A zero-metadata `/tmp` GGUF v3 fixture returned `GGUF metadata ok`.
- A mixed metadata `/tmp` fixture with a string scalar, fixed scalar, and string
  array returned `GGUF metadata ok`.
- Truncated metadata failed with `mistral-asm: malformed GGUF metadata` and exit
  status 3.
- An unknown metadata type failed with
  `mistral-asm: unsupported GGUF metadata type` and exit status 3.
- Loader syscall trace on the mixed metadata fixture showed direct `openat`,
  `fstat`, `mmap`, `munmap`, `close`, `write`, and `exit`.
- `git diff --check` passed.

## Next Exact Step

Add the tensor-info directory walker described above, keeping all descriptor
reads bounded by the mapped file length.
