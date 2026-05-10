.intel_syntax noprefix

.section .text

.global sys_munmap
.type sys_munmap, @function

# Contract: invoke Linux munmap(2).
# Inputs: rdi = mapping base, rsi = mapping length.
# Outputs: rax = 0 on success or negative errno on failure.
# Clobbers: rax, rcx, r11 and flags per the syscall ABI.
# Ownership/lifetime: releases the caller-owned mapping range on success.
# Error behavior: returns the raw kernel result; callers decide how to report it.
sys_munmap:
	# Linux x86-64 syscall number for munmap is 11.
	mov rax, 11
	syscall
	ret

.size sys_munmap, . - sys_munmap

.section .note.GNU-stack,"",@progbits
