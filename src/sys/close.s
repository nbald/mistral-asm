.intel_syntax noprefix

.section .text

.global sys_close
.type sys_close, @function

# Contract: invoke Linux close(2).
# Inputs: rdi = file descriptor.
# Outputs: rax = 0 on success or negative errno on failure.
# Clobbers: rax, rcx, r11 and flags per the syscall ABI.
# Ownership/lifetime: releases the kernel descriptor named by rdi on success.
# Error behavior: returns the raw kernel result; callers decide how to report it.
sys_close:
	# Linux x86-64 syscall number for close is 3.
	mov rax, 3
	syscall
	ret

.size sys_close, . - sys_close

.section .note.GNU-stack,"",@progbits
