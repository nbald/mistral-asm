.intel_syntax noprefix

.section .text

.global sys_write
.type sys_write, @function

sys_write:
	mov rax, 1
	syscall
	ret

.size sys_write, . - sys_write

.section .note.GNU-stack,"",@progbits
