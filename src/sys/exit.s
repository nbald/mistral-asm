.intel_syntax noprefix

.section .text

.global sys_exit
.type sys_exit, @function

sys_exit:
	mov rax, 60
	syscall

.Lexit_hang:
	jmp .Lexit_hang

.size sys_exit, . - sys_exit

.section .note.GNU-stack,"",@progbits
