# Repository-Wide Review 1 - 2026-05-11

## Scope

- First consecutive repository-wide review pass for the operator instruction
  dated 2026-05-10T22:24:01Z.
- Reviewed the project contract, continuation state, operator control channel,
  source layout, build path, runtime source purity, and the current layer-1
  token-0 forward path shape.
- Paid specific attention to whether `src/entry/_start.s` should be
  reorganized before the next feature step.

## Findings

- Important: `src/entry/_start.s` has crossed the point where continuing to add
  feature work inside the file is a maintainability blocker. It is now 8,176
  lines and owns unrelated responsibilities: process entry and CLI dispatch,
  static GGUF summary and activation storage, reusable layer-1 descriptor lookup
  sequencing, descriptor summary printing, exact f32 slice printing, and all
  token-0 smoke orchestration. The next queued feature step would add more
  descriptor slots and summary printing for layer-1 FFN gate/up tensors, which
  would deepen that coupling instead of reducing risk.

## Recommendation

- Keep feature work stopped through the required second review pass. If pass 2
  confirms this finding, the next non-review step should be a mechanical
  reorganization that preserves behavior while moving at least one separable
  responsibility out of `_start.s`, such as descriptor lookup/printing helpers or
  token-0 smoke helpers, into focused `.s` modules listed in the `Makefile`.

## Clean Checks

- Runtime source files remain `.s` only under `src/`.
- `Makefile` builds runtime objects with `as` and links the executable with
  `ld`; it does not introduce libc or a C/Rust/Python runtime dependency.
- Exported assembly functions and the non-trivial internal helpers sampled in
  `src/entry/_start.s`, `src/gguf/load_header.s`, and `src/math/*.s` carry
  contract comments.
- No tracked model file, GGUF, binary dump, long log, trace, or perf output was
  found in the repository scan.

## Verification

- `make clean && make && make check` passed with `q8_0_dot: ok`,
  `rmsnorm: ok`, `swiglu: ok`, and `gguf_lookup: ok`.
- `./mistral-asm --help`
- Real target smoke:
  `./mistral-asm models/unsloth-Ministral-3-3B-Instruct-2512-GGUF/Ministral-3-3B-Instruct-2512-Q8_0.gguf`
  filtered to the current layer-1 handoff labels. It still reported
  `layer1_ffn_norm_tensor_found: 1`, `token0_layer1_attn_output_matvec: 1`,
  `token0_layer1_post_attn_residual: 1`, and `token0_layer1_ffn_norm: 1` with
  the published FFN norm words `0xbec8ddb4`, `0xc11f7d85`, `0x40d46234`, and
  `0xbfe2ec8e`.
- `python3 -m py_compile work/oracle/*.py`
- `find src -type f ! -name '*.s' -print` produced no output.
- `readelf -d ./mistral-asm` reported no dynamic section, and `file
  ./mistral-asm` reported a statically linked x86-64 ELF.
- `git ls-files | rg '(^models/|\.gguf$|\.(bin|log|trace|perf|out)$)'`
  produced no tracked-artifact matches.
- `git ls-files | xargs -r du -h | awk '$1 ~ /[0-9]+M/ { print }'` produced no
  large tracked-file matches.
- `git diff --check`
