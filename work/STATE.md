# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Publish the first guarded token-0 layer-3 attention value output exact-hex
slice, keeping slice labels and printer code in
`src/infer/token0_layer3_attn_slices.inc` and preserving the existing guard
that no value words print unless `token0_layer3_attn_v_matvec: 1`.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- GGUF support remains narrow and guarded: v3 little-endian target parsing,
  metadata summaries, tensor directory walking, retained descriptor lookups, and
  bounded tensor payload reads.
- Token-0 smoke coverage reaches the complete layer-2 FFN branch through the
  post-FFN residual. The layer-2 post-FFN residual words remain `0x440c1d48`,
  `0xc200a8d7`, `0xc2a8120a`, and `0xc15da38d`.
- Layer-3 attention coverage now includes descriptor lookup and guarded output
  slices for `blk.3.attn_norm.weight`, `blk.3.attn_q.weight`, and
  `blk.3.attn_k.weight`.
- On the real target, the layer-3 attention key projection now publishes
  `token0_layer3_attn_k_output*_f32_hex` only after
  `token0_layer3_attn_k_matvec: 1`. The first four words are `0xbaf936b2`,
  `0xbcf1bab9`, `0x3c7af998`, and `0x3c825ee2`, matching the focused external
  oracle.
- Descriptor-only retained lookup coverage now includes `blk.3.attn_v.weight`
  and the runtime now has status-only token-0 layer-3 attention value matvec
  coverage. On the real target the descriptor reports found `1`, dimensions
  `2`, dim0 `3072`, dim1 `1024`, type `8`, and relative offset `828997632`;
  `token0_layer3_attn_v_matvec: 1` prints after a bounded Q8_0 matvec writes
  private storage, with no value output slice labels yet.
- The existing layer-3 attention exact-hex rodata labels and printer helpers
  for the RMSNorm, query, and key public slices now live in the Makefile-tracked
  `src/infer/token0_layer3_attn_slices.inc` include. This was a
  behavior-preserving split; `src/infer/token0_layer3_attn.s` is now 618 lines
  and the include is 288 lines.
- Operator guidance to keep new feature work out of catch-all entry files is
  durable. New runtime logic should continue to use focused modules or
  Makefile-tracked include fragments.

## Known Blockers

- No functional blocker to the layer-3 attention value output slice.
- Keep layer-3 attention slice labels and printer code in
  `src/infer/token0_layer3_attn_slices.inc`; it is tracked in `Makefile` so
  edits rebuild `build/infer/token0_layer3_attn.o`.
- `src/infer/token0_layer2_attn.s` is 997 lines. Do not add substantial new code
  to it before splitting or moving work into a focused module.
- `src/infer/token0_layer2_ffn.s` is 943 lines. Do not add substantial new code
  there before splitting or moving work into a focused module.
- `src/gguf/load_header/tensor_infos.inc` remains over 1000 lines, but it is a
  coherent tensor-directory walker. Reduce it only when changing that logic.

## Relevant Files

- `Makefile`
- `src/entry/start/constants.inc`
- `src/entry/start/rodata/cli_requests.inc`
- `src/entry/start/rodata/layer3_cli_requests.inc`
- `src/entry/start/rodata/layer3_summary_labels.inc`
- `src/entry/start/state/layer3_globals.inc`
- `src/entry/start/state/layer3_bss.inc`
- `src/entry/start/main/bootstrap.inc`
- `src/entry/start/main/bootstrap/layer3.inc`
- `src/entry/start/main/summary_header.inc`
- `src/entry/start/lookup_summary/layer3.inc`
- `src/entry/start/main/smoke_orchestration.inc`
- `src/infer/token0_layer3_attn.s`
- `src/infer/token0_layer3_attn_slices.inc`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

Layer-3 attention exact-hex slice split verification passed:

- `make`
- `make check`
- `./mistral-asm --help`
- real-target runtime/oracle diff was empty for the moved public exact-hex
  labels: layer-2 post-FFN residual, layer-3 attention RMSNorm, layer-3 query
  output, and layer-3 key output
- real-target run printed layer-3 attention norm/query/key/value descriptors as
  found with the expected dimensions, types, and offsets; the value descriptor
  remained dim0 `3072`, dim1 `1024`, type `8`, and offset `828997632`
- real-target run preserved `token0_layer3_attn_norm: 1`,
  `token0_layer3_attn_q_matvec: 1`, `token0_layer3_attn_k_matvec: 1`, and
  `token0_layer3_attn_v_matvec: 1`, with no
  `token0_layer3_attn_v_output*_f32_hex` labels emitted
- temporary 24-byte empty valid GGUF kept all layer-3 descriptor fields and
  dependent statuses at `0`, including `token0_layer3_attn_v_matvec: 0`, and
  emitted no guarded layer-3 norm/query/key/value output labels
- `python3 -m py_compile work/oracle/*.py`
- `git diff --check`
- runtime source extension scan allowing `.s` and `.inc`
- corrected include dependency scan covering `.include` fragments in
  `Makefile`
- touching `src/infer/token0_layer3_attn_slices.inc` made
  `make -n build/infer/token0_layer3_attn.o` schedule the assembler, followed
  by a normal rebuild and `make check`
- static-link/no-dynamic-section/file check
- undefined-symbol check
- local/exported symbol inspection for the layer-3 public runners/statuses,
  private output storage, and local slice printer helpers
- tracked artifact and tracked large-file scans

## Next Exact Step

Publish the first guarded token-0 layer-3 attention value output exact-hex
slice in `src/infer/token0_layer3_attn_slices.inc`, verified against a focused
external oracle and still silent on the 24-byte empty GGUF failure path.
