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
	.ascii "  mistral-asm <model.gguf> <prompt> --max-tokens <n>\n"
	.ascii "\n"
	.ascii "Current milestone: GGUF header validation.\n"
help_text_end:

usage_error_text:
	.ascii "mistral-asm: use --help or provide a GGUF file\n"
usage_error_text_end:

gguf_ok_text:
	.ascii "GGUF header ok\n"
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

gguf_unknown_error_text:
	.ascii "mistral-asm: GGUF validation failed\n"
gguf_unknown_error_text_end:

.section .text

.global _start
.type _start, @function

_start:
	mov rax, qword ptr [rsp]
	cmp rax, 2
	jne .Lusage_error

	mov rdi, qword ptr [rsp + 16]
	lea rsi, [rip + help_arg]
	mov rdx, help_arg_end - help_arg
	call str_eq_exact
	test rax, rax
	jz .Lvalidate_model

	mov rdi, 1
	lea rsi, [rip + help_text]
	mov rdx, help_text_end - help_text
	call sys_write

	xor rdi, rdi
	call sys_exit

.Lvalidate_model:
	mov rdi, qword ptr [rsp + 16]
	call gguf_validate_file
	test rax, rax
	jz .Lgguf_ok

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

.Lwrite_model_error:
	mov rdi, 2
	call sys_write

	mov rdi, 3
	call sys_exit

.Lgguf_ok:
	mov rdi, 1
	lea rsi, [rip + gguf_ok_text]
	mov rdx, gguf_ok_text_end - gguf_ok_text
	call sys_write

	xor rdi, rdi
	call sys_exit

.Lusage_error:
	mov rdi, 2
	lea rsi, [rip + usage_error_text]
	mov rdx, usage_error_text_end - usage_error_text
	call sys_write

	mov rdi, 2
	call sys_exit

.size _start, . - _start

.type str_eq_exact, @function

str_eq_exact:
	xor eax, eax
	test rdi, rdi
	jz .Lstr_done

	xor rcx, rcx
.Lstr_loop:
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
