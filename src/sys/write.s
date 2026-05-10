.intel_syntax noprefix

.section .text

.global sys_write
.type sys_write, @function

# Contract: invoke Linux write(2).
# Inputs: rdi = file descriptor, rsi = buffer pointer, rdx = byte count.
# Outputs: rax = bytes written on success or negative errno on failure.
# Clobbers: rax, rcx, r11 and flags per the syscall ABI.
# Ownership/lifetime: reads the caller-owned buffer only for the duration of the
# syscall.
# Error behavior: returns the raw kernel result; callers decide how to report it.
sys_write:
	# Linux x86-64 syscall number for write is 1.
	mov rax, 1
	syscall
	ret

.size sys_write, . - sys_write

.section .note.GNU-stack,"",@progbits
