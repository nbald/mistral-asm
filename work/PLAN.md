# PLAN

## Contract

- Runtime source is only `.s`.
- Syntax is GNU `as` Intel.
- Build uses `as` and `ld` through `Makefile`.
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
4. Metadata dump: architecture, context, vocab, layers, tensor count.
5. Tensor directory: names, dimensions, types, offsets.
6. Q8_0 matvec: scalar first, AVX2 later.
7. One-token forward from token IDs, verified against `llama.cpp`.
8. Multi-token greedy generation from token IDs.
9. Tokenizer decode in ASM.
10. Tokenizer encode in ASM.
11. Prompt text CLI and first useful text output.
12. Zen 2 optimization pass.

## Documentation Policy

- `work/STATE.md` is the compact source of truth for continuation.
- `work/WORKLOG.md` is append-only history and may become large.
- Agents must not read the whole worklog once it grows; read only its tail.
- `work/oracle/` stores small oracle notes, hashes, commands, and excerpts.
- Large model files, binaries, traces, dumps, logs, and perf output are ignored.

