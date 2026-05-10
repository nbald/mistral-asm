.intel_syntax noprefix

.section .text

.global sys_mmap
.type sys_mmap, @function

sys_mmap:
	mov rax, 9
	syscall
	ret

.size sys_mmap, . - sys_mmap

.section .note.GNU-stack,"",@progbits
