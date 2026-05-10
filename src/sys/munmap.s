.intel_syntax noprefix

.section .text

.global sys_munmap
.type sys_munmap, @function

sys_munmap:
	mov rax, 11
	syscall
	ret

.size sys_munmap, . - sys_munmap

.section .note.GNU-stack,"",@progbits
