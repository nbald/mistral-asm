.intel_syntax noprefix

.equ DECIMAL_SCRATCH_SIZE, 32
.equ GGUF_SUMMARY_ARCHITECTURE_CAP, 32
.equ GGUF_SUMMARY_FIRST_TENSOR_NAME_CAP, 96

.section .rodata

help_arg:
	.ascii "--help"
help_arg_end:

help_text:
	.ascii "mistral-asm\n"
	.ascii "\n"
	.ascii "Usage:\n"
	.ascii "  mistral-asm --help\n"
	.ascii "  mistral-asm <model.gguf>\n"
	.ascii "\n"
	.ascii "Current milestone: GGUF tensor directory summary.\n"
help_text_end:

usage_error_text:
	.ascii "mistral-asm: use --help or provide a GGUF file\n"
usage_error_text_end:

gguf_ok_text:
	.ascii "GGUF summary\n"
gguf_ok_text_end:

tensor_count_text:
	.ascii "tensor_count: "
tensor_count_text_end:

metadata_count_text:
	.ascii "metadata_kv_count: "
metadata_count_text_end:

architecture_text:
	.ascii "architecture: "
architecture_text_end:

context_length_text:
	.ascii "context_length: "
context_length_text_end:

block_count_text:
	.ascii "block_count: "
block_count_text_end:

vocab_size_text:
	.ascii "vocab_size: "
vocab_size_text_end:

first_tensor_name_text:
	.ascii "first_tensor_name: "
first_tensor_name_text_end:

first_tensor_n_dimensions_text:
	.ascii "first_tensor_n_dimensions: "
first_tensor_n_dimensions_text_end:

first_tensor_dim0_text:
	.ascii "first_tensor_dim0: "
first_tensor_dim0_text_end:

first_tensor_dim1_text:
	.ascii "first_tensor_dim1: "
first_tensor_dim1_text_end:

first_tensor_dim2_text:
	.ascii "first_tensor_dim2: "
first_tensor_dim2_text_end:

first_tensor_dim3_text:
	.ascii "first_tensor_dim3: "
first_tensor_dim3_text_end:

first_tensor_ggml_type_text:
	.ascii "first_tensor_ggml_type: "
first_tensor_ggml_type_text_end:

first_tensor_offset_text:
	.ascii "first_tensor_offset: "
first_tensor_offset_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

gguf_open_error_text:
	.ascii "mistral-asm: could not open model\n"
gguf_open_error_text_end:

gguf_fstat_error_text:
	.ascii "mistral-asm: could not stat model\n"
gguf_fstat_error_text_end:

gguf_too_small_error_text:
	.ascii "mistral-asm: file is too small for GGUF header\n"
gguf_too_small_error_text_end:

gguf_mmap_error_text:
	.ascii "mistral-asm: could not map model\n"
gguf_mmap_error_text_end:

gguf_magic_error_text:
	.ascii "mistral-asm: bad GGUF magic\n"
gguf_magic_error_text_end:

gguf_version_error_text:
	.ascii "mistral-asm: unsupported GGUF version\n"
gguf_version_error_text_end:

gguf_munmap_error_text:
	.ascii "mistral-asm: could not unmap model\n"
gguf_munmap_error_text_end:

gguf_count_error_text:
	.ascii "mistral-asm: unsupported GGUF count field\n"
gguf_count_error_text_end:

gguf_metadata_bounds_error_text:
	.ascii "mistral-asm: malformed GGUF metadata\n"
gguf_metadata_bounds_error_text_end:

gguf_metadata_type_error_text:
	.ascii "mistral-asm: unsupported GGUF metadata type\n"
gguf_metadata_type_error_text_end:

gguf_tensor_bounds_error_text:
	.ascii "mistral-asm: malformed GGUF tensor directory\n"
gguf_tensor_bounds_error_text_end:

gguf_tensor_alignment_error_text:
	.ascii "mistral-asm: misaligned GGUF tensor data\n"
gguf_tensor_alignment_error_text_end:

gguf_unknown_error_text:
	.ascii "mistral-asm: GGUF validation failed\n"
gguf_unknown_error_text_end:

.section .bss

.balign 8
gguf_summary:
gguf_summary_tensor_count:
	.skip 8
gguf_summary_metadata_count:
	.skip 8
gguf_summary_architecture:
	.skip GGUF_SUMMARY_ARCHITECTURE_CAP
gguf_summary_context_length:
	.skip 8
gguf_summary_block_count:
	.skip 8
gguf_summary_vocab_size:
	.skip 8
gguf_summary_first_tensor_name:
	.skip GGUF_SUMMARY_FIRST_TENSOR_NAME_CAP
gguf_summary_first_tensor_n_dimensions:
	.skip 8
gguf_summary_first_tensor_dim0:
	.skip 8
gguf_summary_first_tensor_dim1:
	.skip 8
gguf_summary_first_tensor_dim2:
	.skip 8
gguf_summary_first_tensor_dim3:
	.skip 8
gguf_summary_first_tensor_ggml_type:
	.skip 8
gguf_summary_first_tensor_offset:
	.skip 8

.section .text

.global _start
.type _start, @function

# Contract: process entry point for the current runtime milestone.
# Inputs: initial Linux process stack at rsp; argv[0..argc-1] and envp follow
# the System V AMD64 process-start layout. This function currently accepts
# either "--help" or one GGUF model path.
# Outputs: does not return. Writes help, success, or diagnostic text, then exits
# with status 0 for help/valid header, 2 for CLI usage errors, or 3 for GGUF
# validation errors.
# Clobbers: all general-purpose registers may be clobbered; no caller exists.
# Ownership/lifetime: argv strings remain kernel-provided process memory. Any
# model mapping is owned and released inside gguf_validate_file. The GGUF
# summary buffer is process-owned static storage passed to the loader for scalar
# header counts, a bounded copy of selected metadata strings, and selected
# scalar and array-length metadata values, plus a bounded snapshot of the first
# tensor descriptor, including up to four dimension sizes.
# Error behavior: maps gguf_validate_file status codes to stderr diagnostics.
_start:
	# argc is the first word on the initial process stack. The milestone CLI
	# accepts exactly one user argument: either "--help" or a model path.
	mov rax, qword ptr [rsp]
	cmp rax, 2
	jne .Lusage_error

	# Compare argv[1] against the literal help flag before treating it as a
	# filesystem path. str_eq_exact also rejects longer strings with this prefix.
	mov rdi, qword ptr [rsp + 16]
	lea rsi, [rip + help_arg]
	mov rdx, help_arg_end - help_arg
	call str_eq_exact
	test rax, rax
	jz .Lvalidate_model

	# Help output goes to stdout. sys_exit never returns, so no cleanup follows.
	mov rdi, 1
	lea rsi, [rip + help_text]
	mov rdx, help_text_end - help_text
	call sys_write

	xor rdi, rdi
	call sys_exit

.Lvalidate_model:
	# The loader owns all file descriptors and mappings it creates. _start only
	# translates its small status-code enum into user-visible process behavior.
	mov rdi, qword ptr [rsp + 16]
	lea rsi, [rip + gguf_summary]
	call gguf_validate_file
	test rax, rax
	jz .Lgguf_ok

	# Keep this dispatch explicit while the status enum is still small; it makes
	# audit of each user-visible failure path straightforward.
	cmp rax, 1
	je .Lgguf_open_error
	cmp rax, 2
	je .Lgguf_fstat_error
	cmp rax, 3
	je .Lgguf_too_small_error
	cmp rax, 4
	je .Lgguf_mmap_error
	cmp rax, 5
	je .Lgguf_magic_error
	cmp rax, 6
	je .Lgguf_version_error
	cmp rax, 7
	je .Lgguf_munmap_error
	cmp rax, 8
	je .Lgguf_count_error
	cmp rax, 9
	je .Lgguf_metadata_bounds_error
	cmp rax, 10
	je .Lgguf_metadata_type_error
	cmp rax, 11
	je .Lgguf_tensor_bounds_error
	cmp rax, 12
	je .Lgguf_tensor_alignment_error

	lea rsi, [rip + gguf_unknown_error_text]
	mov rdx, gguf_unknown_error_text_end - gguf_unknown_error_text
	jmp .Lwrite_model_error

.Lgguf_open_error:
	lea rsi, [rip + gguf_open_error_text]
	mov rdx, gguf_open_error_text_end - gguf_open_error_text
	jmp .Lwrite_model_error

.Lgguf_fstat_error:
	lea rsi, [rip + gguf_fstat_error_text]
	mov rdx, gguf_fstat_error_text_end - gguf_fstat_error_text
	jmp .Lwrite_model_error

.Lgguf_too_small_error:
	lea rsi, [rip + gguf_too_small_error_text]
	mov rdx, gguf_too_small_error_text_end - gguf_too_small_error_text
	jmp .Lwrite_model_error

.Lgguf_mmap_error:
	lea rsi, [rip + gguf_mmap_error_text]
	mov rdx, gguf_mmap_error_text_end - gguf_mmap_error_text
	jmp .Lwrite_model_error

.Lgguf_magic_error:
	lea rsi, [rip + gguf_magic_error_text]
	mov rdx, gguf_magic_error_text_end - gguf_magic_error_text
	jmp .Lwrite_model_error

.Lgguf_version_error:
	lea rsi, [rip + gguf_version_error_text]
	mov rdx, gguf_version_error_text_end - gguf_version_error_text
	jmp .Lwrite_model_error

.Lgguf_munmap_error:
	lea rsi, [rip + gguf_munmap_error_text]
	mov rdx, gguf_munmap_error_text_end - gguf_munmap_error_text
	jmp .Lwrite_model_error

.Lgguf_count_error:
	lea rsi, [rip + gguf_count_error_text]
	mov rdx, gguf_count_error_text_end - gguf_count_error_text
	jmp .Lwrite_model_error

.Lgguf_metadata_bounds_error:
	lea rsi, [rip + gguf_metadata_bounds_error_text]
	mov rdx, gguf_metadata_bounds_error_text_end - gguf_metadata_bounds_error_text
	jmp .Lwrite_model_error

.Lgguf_metadata_type_error:
	lea rsi, [rip + gguf_metadata_type_error_text]
	mov rdx, gguf_metadata_type_error_text_end - gguf_metadata_type_error_text
	jmp .Lwrite_model_error

.Lgguf_tensor_bounds_error:
	lea rsi, [rip + gguf_tensor_bounds_error_text]
	mov rdx, gguf_tensor_bounds_error_text_end - gguf_tensor_bounds_error_text
	jmp .Lwrite_model_error

.Lgguf_tensor_alignment_error:
	lea rsi, [rip + gguf_tensor_alignment_error_text]
	mov rdx, gguf_tensor_alignment_error_text_end - gguf_tensor_alignment_error_text

.Lwrite_model_error:
	# Header validation failures are runtime errors, distinct from CLI misuse.
	mov rdi, 2
	call sys_write

	mov rdi, 3
	call sys_exit

.Lgguf_ok:
	# This milestone validates the fixed GGUF header, metadata shapes, and
	# tensor-info directory bounds, then exposes header counts, selected metadata,
	# and the first tensor descriptor retained in caller-owned storage.
	mov rdi, 1
	lea rsi, [rip + gguf_ok_text]
	mov rdx, gguf_ok_text_end - gguf_ok_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + tensor_count_text]
	mov rdx, tensor_count_text_end - tensor_count_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_tensor_count]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + metadata_count_text]
	mov rdx, metadata_count_text_end - metadata_count_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_metadata_count]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + architecture_text]
	mov rdx, architecture_text_end - architecture_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_architecture]
	mov rdx, GGUF_SUMMARY_ARCHITECTURE_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + context_length_text]
	mov rdx, context_length_text_end - context_length_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_context_length]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + block_count_text]
	mov rdx, block_count_text_end - block_count_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_block_count]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + vocab_size_text]
	mov rdx, vocab_size_text_end - vocab_size_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_vocab_size]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_name_text]
	mov rdx, first_tensor_name_text_end - first_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_first_tensor_name]
	mov rdx, GGUF_SUMMARY_FIRST_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_n_dimensions_text]
	mov rdx, first_tensor_n_dimensions_text_end - first_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_dim0_text]
	mov rdx, first_tensor_dim0_text_end - first_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_dim1_text]
	mov rdx, first_tensor_dim1_text_end - first_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_dim2_text]
	mov rdx, first_tensor_dim2_text_end - first_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_dim3_text]
	mov rdx, first_tensor_dim3_text_end - first_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_ggml_type_text]
	mov rdx, first_tensor_ggml_type_text_end - first_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_offset_text]
	mov rdx, first_tensor_offset_text_end - first_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	xor rdi, rdi
	call sys_exit

.Lusage_error:
	# Usage errors are intentionally handled before any file syscall.
	mov rdi, 2
	lea rsi, [rip + usage_error_text]
	mov rdx, usage_error_text_end - usage_error_text
	call sys_write

	mov rdi, 2
	call sys_exit

.size _start, . - _start

.type str_eq_exact, @function

# Contract: compare a NUL-terminated process string against an exact byte
# literal with known length.
# Inputs: rdi = candidate C string, rsi = literal bytes, rdx = literal length.
# Outputs: rax = 1 when the first rdx bytes match and candidate[rdx] is NUL;
# otherwise rax = 0.
# Clobbers: rax, rcx, r8 and flags.
# Ownership/lifetime: reads both buffers only; does not retain pointers.
# Error behavior: a NULL candidate pointer is treated as no match.
str_eq_exact:
	# Default to "not equal" so all mismatch exits share one return path.
	xor eax, eax
	test rdi, rdi
	jz .Lstr_done

	xor rcx, rcx
.Lstr_loop:
	# After the fixed literal length matches, require the candidate to end there;
	# this prevents "--help-extra" from being accepted.
	cmp rcx, rdx
	je .Lstr_check_nul
	mov r8b, byte ptr [rdi + rcx]
	cmp r8b, byte ptr [rsi + rcx]
	jne .Lstr_done
	inc rcx
	jmp .Lstr_loop

.Lstr_check_nul:
	cmp byte ptr [rdi + rdx], 0
	jne .Lstr_done
	mov eax, 1

.Lstr_done:
	ret

.size str_eq_exact, . - str_eq_exact

.type write_u64_decimal, @function

# Contract: write an unsigned 64-bit integer as base-10 ASCII.
# Inputs: rdi = output file descriptor; rsi = value to print.
# Outputs: returns after one write(2) attempt for the generated digit span; the
# raw sys_write result is intentionally ignored by this milestone caller.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: uses a fixed scratch area on its own stack frame and does
# not retain pointers after sys_write returns.
# Error behavior: write errors are not reported separately; later CLI output
# plumbing can centralize short-write handling if it becomes useful.
write_u64_decimal:
	push rbp
	mov rbp, rsp
	sub rsp, DECIMAL_SCRATCH_SIZE

	# Fill digits backward from the end of the scratch space. Twenty bytes would
	# hold any u64 value, but the larger round size keeps the frame simple.
	lea r8, [rsp + DECIMAL_SCRATCH_SIZE]
	mov r9, r8
	mov rax, rsi
	test rax, rax
	jnz .Ldecimal_loop

	dec r9
	mov byte ptr [r9], '0'
	jmp .Ldecimal_write

.Ldecimal_loop:
	xor edx, edx
	mov r10d, 10
	div r10
	add dl, '0'
	dec r9
	mov byte ptr [r9], dl
	test rax, rax
	jnz .Ldecimal_loop

.Ldecimal_write:
	# r9 points at the first digit and r8 one byte past the last digit.
	mov rsi, r9
	mov rdx, r8
	sub rdx, r9
	call sys_write

	add rsp, DECIMAL_SCRATCH_SIZE
	pop rbp
	ret

.size write_u64_decimal, . - write_u64_decimal

.type write_bounded_c_string, @function

# Contract: write a NUL-terminated string whose storage has a fixed maximum
# capacity.
# Inputs: rdi = output file descriptor; rsi = string buffer; rdx = maximum bytes
# available in the buffer, including any NUL terminator.
# Outputs: returns after at most one write(2) attempt for the bytes before the
# first NUL or the maximum bound. The raw sys_write result is intentionally
# ignored by this milestone caller.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: reads the caller-owned buffer only during this call and
# does not retain pointers.
# Error behavior: write errors are not reported separately; an empty string
# simply produces no payload write.
write_bounded_c_string:
	push rbx
	push r12
	push r13

	mov rbx, rdi
	mov r12, rsi
	mov r13, rdx
	xor eax, eax

.Lbounded_scan:
	cmp rax, r13
	je .Lbounded_have_len
	cmp byte ptr [r12 + rax], 0
	je .Lbounded_have_len
	inc rax
	jmp .Lbounded_scan

.Lbounded_have_len:
	test rax, rax
	jz .Lbounded_done
	mov rdi, rbx
	mov rsi, r12
	mov rdx, rax
	call sys_write

.Lbounded_done:
	pop r13
	pop r12
	pop rbx
	ret

.size write_bounded_c_string, . - write_bounded_c_string

.section .note.GNU-stack,"",@progbits
