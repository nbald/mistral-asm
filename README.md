# mistral-asm

`mistral-asm` is an experiment in building a Ministral 3 3B inference engine
from scratch in GNU `as` Intel assembly.

The purpose is not to beat existing runtimes first. The purpose is to produce an
auditable repository where a language model builds a working inference engine
step by step, with no hidden runtime dependency on C, libc, Python, Rust, or
llama.cpp.

The runtime target is deliberately strict:

- Linux x86-64.
- AMD Zen 2 class CPUs.
- Runtime source only in `.s`.
- No libc.
- Direct Linux syscalls from `_start`.
- Build with `as` and `ld`.
- Model input: Unsloth Ministral 3 3B Instruct Q8_0 GGUF.

The repository is meant to be auditable. The git history should show the engine
being built step by step, with working notes and reviews committed alongside the
code.

## Model Target

Initial model:

```text
unsloth/Ministral-3-3B-Instruct-2512-GGUF
Ministral-3-3B-Instruct-2512-Q8_0.gguf
```

The first implementation supports a narrow GGUF subset:

- GGUF v3.
- little-endian.
- `general.architecture = mistral3`.
- Q8_0 tensors.
- text-only runtime.

Other quantization formats, multimodal `mmproj`, NUMA tuning, and broad GGUF
compatibility are later work.

## Implementation Direction

The engine will grow in small, reviewable milestones:

1. Pure ASM executable proof: `_start`, `write`, `exit`, `--help`.
2. GGUF file loading with `openat`, `fstat`, and `mmap`.
3. Header, metadata, alignment, and tensor directory parsing.
4. Q8_0 matvec with f32 activations.
5. One-token forward pass from token IDs.
6. Greedy multi-token generation from token IDs.
7. Tokenizer decode, then tokenizer encode.
8. Prompt text CLI.
9. Zen 2 optimization pass.

Correctness comes before performance. The first math kernels may be scalar if
that gets the inference path working and auditable sooner.

## Verification Strategy

The runtime must prove it is pure ASM:

- Runtime source files are `.s`.
- Objects are produced by `as`.
- The executable is linked by `ld`.
- `readelf` shows no dynamic libc dependency.
- `strace` shows expected direct Linux syscalls.

`llama.cpp` may be used as an external oracle for metadata, token IDs, logits, or
greedy output comparisons. It must not be linked, vendored, or called by the
runtime.

## Assembly Style

Assembly files should be written for audit. Exported functions carry a contract
comment describing purpose, inputs, outputs, clobbers, and ownership rules.
Non-trivial internal helpers get the same treatment. Inside functions, comments
explain logical blocks, ABI assumptions, register ownership, file-format offsets,
and cleanup/error paths. Comments should explain intent rather than repeat the
mnemonic.

## Current State

The pure ASM executable proof is implemented, and the first narrow GGUF loader
path accepts a model path, opens it, stats it, maps it read-only, validates the
magic, version, and count header fields, walks metadata key/value records with
bounded offset checks, then unmaps it. `make` assembles the runtime with `as` and
links it with `ld`.

Read these first:

- `work/GOAL.md` for the project contract.
- `work/PLAN.md` for milestones and policies.
- `work/STATE.md` for the exact next step.
- `work/AUTONOMOUS.md` for operating the autonomous loop.

## Repository Layout

Current committed layout:

```text
Makefile              as/ld runtime build
src/entry/            _start and process entry
src/sys/              Linux syscall wrappers
scripts/              autonomous loop, status, and control helpers
work/                 project goal, plan, state, worklog, prompts, reviews
work/control/         committed docs for operator controls
work/reviews/         review notes and findings
```

Planned runtime layout:

```text
src/cli/              argument parsing and usage output
src/util/             small reusable helpers
src/gguf/             GGUF parser
src/model/            model config and tensor lookup
src/math/             numeric kernels
src/infer/            forward pass and generation loop
src/tokenizer/        encode/decode
```

## Quick Commands

Build and run the current ASM proof:

```sh
make
./mistral-asm --help
```

Inspect status from another terminal:

```sh
scripts/status.sh
```

Watch status:

```sh
scripts/watch-status.sh 5
```

Run one autonomous iteration:

```sh
scripts/autonomous-loop.sh 1
```

Inject an instruction for the next iteration:

```sh
scripts/control.sh instruction "review before expanding the GGUF parser"
```

Interrupt current work and inject an instruction:

```sh
scripts/control.sh interrupt-instruction "stop feature work and review first"
```
