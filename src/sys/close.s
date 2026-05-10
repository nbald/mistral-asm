.intel_syntax noprefix

.section .text

.global sys_close
.type sys_close, @function

sys_close:
	mov rax, 3
	syscall
	ret

.size sys_close, . - sys_close

.section .note.GNU-stack,"",@progbits
