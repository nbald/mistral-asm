# STATE

## Current Milestone

Milestone 9: one-token forward from token IDs.

## Current Exact Task

Resume feature work by adding a guarded first-four exact-hex slice printer for
`token0_layer1_ffn_up_output` in `src/infer/token0_layer1_ffn.s`,
preserving the existing output order.

## Completed Work

- Runtime source remains pure GNU `as` Intel assembly built with `as` and linked
  with `ld`; `_start` uses Linux syscalls directly and no libc.
- The narrow GGUF v3 little-endian loader records metadata, tensor directory
  offsets, fixed layer-0 descriptors, and reusable named descriptor lookups.
- Token-0 layer-0 forward smoke coverage reaches post-FFN residual and is
  covered by external oracle notes/scripts.
- Token-0 layer-1 coverage reaches FFN RMSNorm slice publication. The external
  oracle recomputes the full layer-1 attention output and residual before
  checking the first four FFN norm words, and it matches the runtime.
- A newer operator inbox entry stopped feature work and requested two
  consecutive repository-wide review passes before any new feature work. Pass 1
  is recorded in `work/reviews/2026-05-11-repository-wide-review-1.md`.
- Repository-wide review pass 2 is recorded in
  `work/reviews/2026-05-11-repository-wide-review-2.md`. The required
  two-pass review gate is complete.
- The first behavior-preserving `_start.s` responsibility split is complete:
  generic text/output helpers now live in `src/runtime/text.s`, and the
  runtime link includes that module.
- Descriptor-only reusable lookup coverage now includes
  `blk.1.ffn_gate.weight` and `blk.1.ffn_up.weight`. Each descriptor is stored
  in a separate layer-1 scratch slot and printed as found/dimension/type/offset
  summary lines without reading payload bytes.
- A newer operator inbox instruction to stop adding subsystem-specific runtime
  logic, buffers, or printers to `_start.s` has been made durable. New feature
  work should prefer focused modules such as `src/infer/` when feasible.
- Status-only layer-1 FFN gate matvec coverage now lives in
  `src/infer/token0_layer1_ffn.s`. It consumes the existing private
  `token0_layer1_ffn_norm_activation`, reads `blk.1.ffn_gate.weight` only after
  descriptor/type/shape/bounds checks, writes a private layer-1 FFN gate output
  buffer, stores a private status word, and prints only
  `token0_layer1_ffn_gate_matvec`.
- The un-cleared transient operator instruction to split `_start.s` before new
  feature work was treated as active, encoded durably here, and handled for this
  iteration by moving the existing token-0 layer-1 FFN RMSNorm smoke routine
  into `src/infer/token0_layer1_ffn.s`. `_start.s` now exports the handoff slots
  that the focused inference code already consumed logically.
- The layer-1 FFN norm status printer and four-word exact-hex slice printer now
  live beside the FFN norm smoke in `src/infer/token0_layer1_ffn.s`. `_start.s`
  preserves the same output position through a single focused wrapper call, and
  all public diagnostic labels and values are unchanged.
- Status-only layer-1 FFN up matvec coverage now lives beside the gate path in
  `src/infer/token0_layer1_ffn.s`. `_start.s` exports only the needed
  `blk.1.ffn_up.weight` descriptor handoff fields and calls the focused up
  status wrapper immediately after the existing gate status line.
- The layer-1 FFN gate matvec wrapper now also prints a guarded first-four
  exact-hex slice from the private `token0_layer1_ffn_gate_output` buffer when
  its status is 1. The new gate output words appear after
  `token0_layer1_ffn_gate_matvec: 1` and before the existing up status line,
  matching the layer-0 FFN diagnostic order.
- The oversized entry source has been split without behavior changes:
  `src/entry/_start.s` is now an 8-line include driver, and the former contents
  live under `src/entry/start/` as responsibility-named fragments. The fragments
  are still assembled as one translation unit, so local labels and diagnostic
  ordering are preserved.

## Known Blockers

- No current blocker for the next focused layer-1 FFN up output slice step.
- Residual maintainability risk remains in the entry fragments:
  `src/entry/start/main.inc`, `token0_smokes.inc`, `output_slices.inc`, and
  `rodata.inc` are still large and should be reduced before large graph
  expansions. `src/gguf/load_header.s` is also a good next structural split
  candidate.

## Relevant Files

- `src/entry/_start.s`
- `src/entry/start/*.inc`
- `src/gguf/load_header.s`
- `src/infer/token0_layer1_ffn.s`
- `src/math/q8_0_dot.s`
- `src/math/rmsnorm.s`
- `src/math/swiglu.s`
- `src/runtime/text.s`
- `src/sys/*.s`
- `tests/*.s`
- `Makefile`
- `work/oracle/`
- `work/reviews/2026-05-11-repository-wide-review-1.md`
- `work/reviews/2026-05-11-repository-wide-review-2.md`
- `work/STATE.md`
- `work/WORKLOG.md`

## Last Verification

- Entry split verification passed: `make`; `make check`; exact reconstruction
  comparison between the pre-split `src/entry/_start.s` and the concatenated
  `src/entry/start/*.inc` fragments reported `reconstruction matches`.

## Next Exact Step

Add a guarded first-four exact-hex slice printer for
`token0_layer1_ffn_up_output` in `src/infer/token0_layer1_ffn.s`,
preserving the existing output order.
