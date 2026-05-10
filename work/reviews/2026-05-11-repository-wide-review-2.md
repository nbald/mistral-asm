# Repository-Wide Review 2 - 2026-05-11

## Scope

- Second consecutive repository-wide review pass for the operator instruction
  dated 2026-05-10T22:24:01Z.
- Rechecked the project contract, build path, ignored artifact policy, runtime
  source layout, syscall wrappers, GGUF loader contracts, math kernels, no-libc
  harnesses, oracle notes/scripts, and the current token-0 layer-1 forward
  smoke path.
- Independently revisited the pass-1 finding that `src/entry/_start.s` should
  be reorganized before feature work resumes.

## Findings

- Important: pass 2 confirms the pass-1 maintainability blocker. `_start.s` is
  still 8,176 lines and combines process entry, CLI dispatch, GGUF summary
  storage, reusable layer-1 descriptor lookup sequencing, descriptor summary
  printing, exact-hex slice printing, static activation buffers, and all
  token-0 smoke orchestration. The next feature step would add more layer-1 FFN
  descriptor plumbing and summary output, which would extend the same repeated
  responsibilities in the largest file.

## Recommendation

- Treat the two-pass review gate as complete, but keep feature work stopped
  until a behavior-preserving `_start.s` split lands.
- The lowest-risk first split is to move generic entry/output helpers such as
  `str_eq_exact`, `write_u64_decimal`, `write_u32_hex`, and
  `write_bounded_c_string` into a focused runtime `.s` module and update the
  `Makefile` with no output changes. After that, continue moving descriptor
  lookup/printing or token-0 smoke helpers out of `_start.s` before adding new
  feature descriptors.

## Clean Checks

- Runtime source remains limited to `.s` files under `src/`.
- The `Makefile` assembles runtime objects with `as` and links the executable
  with `ld`.
- The syscall wrappers, math kernels, GGUF loader exports, `_start`, and the
  sampled non-trivial internal helpers still carry human-readable contract
  comments.
- No tracked model file, GGUF, binary dump, long log, trace, perf output, or
  large tracked artifact was found in the repository scans.
- No operator inbox was present during this pass.

## Verification

- `make clean && make && make check` passed with `q8_0_dot: ok`,
  `rmsnorm: ok`, `swiglu: ok`, and `gguf_lookup: ok`.
- `./mistral-asm --help` printed the current usage and milestone text.
- Real target smoke:
  `./mistral-asm models/unsloth-Ministral-3-3B-Instruct-2512-GGUF/Ministral-3-3B-Instruct-2512-Q8_0.gguf`
  filtered to the current layer-1 handoff labels. It reported
  `layer1_ffn_norm_tensor_found: 1`, `token0_layer1_attn_output_matvec: 1`,
  `token0_layer1_post_attn_residual: 1`, and `token0_layer1_ffn_norm: 1` with
  layer-1 FFN norm words `0xbec8ddb4`, `0xc11f7d85`, `0x40d46234`, and
  `0xbfe2ec8e`.
- `python3 -m py_compile work/oracle/*.py`
- `find src -type f ! -name '*.s' -print` produced no output.
- `file ./mistral-asm` reported a statically linked x86-64 ELF, and
  `readelf -d ./mistral-asm` reported no dynamic section.
- `git ls-files | rg '(^models/|\.gguf$|\.(bin|log|trace|perf|out)$)'`
  produced no tracked-artifact matches.
- `git ls-files | xargs -r du -h | awk '$1 ~ /[0-9]+M/ { print }'` produced no
  large tracked-file matches.
- `git diff --check`
