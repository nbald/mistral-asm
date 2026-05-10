.intel_syntax noprefix

.section .text

.global sys_fstat
.type sys_fstat, @function

sys_fstat:
	mov rax, 5
	syscall
	ret

.size sys_fstat, . - sys_fstat

.section .note.GNU-stack,"",@progbits
