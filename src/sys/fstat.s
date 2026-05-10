.intel_syntax noprefix

.section .text

.global sys_fstat
.type sys_fstat, @function

# Contract: invoke Linux fstat(2).
# Inputs: rdi = file descriptor, rsi = pointer to caller-owned struct stat
# storage large enough for the kernel ABI.
# Outputs: rax = 0 on success or negative errno on failure.
# Clobbers: rax, rcx, r11 and flags per the syscall ABI.
# Ownership/lifetime: writes only to the caller-provided stat buffer.
# Error behavior: returns the raw kernel result; callers decide how to report it.
sys_fstat:
	# Linux x86-64 syscall number for fstat is 5.
	mov rax, 5
	syscall
	ret

.size sys_fstat, . - sys_fstat

.section .note.GNU-stack,"",@progbits
