# GOAL

Build an autonomous, auditable inference engine for
`unsloth/Ministral-3-3B-Instruct-2512-GGUF`, targeting the Q8_0 GGUF file.

The runtime must be 100% GNU `as` Intel assembly:

- Linux x86-64 entry point is `_start`.
- No libc.
- No C, Rust, Python, or generated code in the runtime.
- Build runtime objects with `as`.
- Link the final executable with `ld`.
- Use Linux syscalls directly.

External tools are allowed only for inspection, comparison, download, and
verification. `llama.cpp` may be used as an oracle, but must never be linked or
vendored into the runtime.

The first acceptance target is:

```sh
./mistral-asm models/ministral-3b-instruct-q8_0.gguf "Bonjour" --max-tokens 16
```

The repo must show the whole process through small source files, clear comments,
atomic commits, and committed working documents.

