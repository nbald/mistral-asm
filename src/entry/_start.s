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
	.ascii "  mistral-asm <model.gguf> <prompt> --max-tokens <n>\n"
	.ascii "\n"
	.ascii "Current milestone: pure assembly syscall proof.\n"
help_text_end:

usage_error_text:
	.ascii "mistral-asm: use --help\n"
usage_error_text_end:

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
	jz .Lusage_error

	mov rdi, 1
	lea rsi, [rip + help_text]
	mov rdx, help_text_end - help_text
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
