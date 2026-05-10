.intel_syntax noprefix

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
	.ascii "Current milestone: GGUF tensor directory validation.\n"
help_text_end:

usage_error_text:
	.ascii "mistral-asm: use --help or provide a GGUF file\n"
usage_error_text_end:

gguf_ok_text:
	.ascii "GGUF tensor directory ok\n"
gguf_ok_text_end:

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
# model mapping is owned and released inside gguf_validate_file.
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
	# tensor-info directory bounds. Later parser milestones will replace this
	# with metadata and inference output.
	mov rdi, 1
	lea rsi, [rip + gguf_ok_text]
	mov rdx, gguf_ok_text_end - gguf_ok_text
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

.section .note.GNU-stack,"",@progbits
