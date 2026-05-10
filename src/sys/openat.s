.intel_syntax noprefix

.section .text

.global sys_openat
.type sys_openat, @function

sys_openat:
	mov rax, 257
	syscall
	ret

.size sys_openat, . - sys_openat

.section .note.GNU-stack,"",@progbits
