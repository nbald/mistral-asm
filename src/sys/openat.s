.intel_syntax noprefix

.section .text

.global sys_openat
.type sys_openat, @function

# Contract: invoke Linux openat(2).
# Inputs: rdi = dirfd, rsi = path pointer, rdx = flags, r10 = mode. This follows
# the Linux syscall ABI, not the C function ABI, where the fourth argument would
# otherwise be in rcx.
# Outputs: rax = non-negative file descriptor on success or negative errno on
# failure.
# Clobbers: rax, rcx, r11 and flags per the syscall ABI.
# Ownership/lifetime: on success the returned descriptor is owned by the caller
# until closed.
# Error behavior: returns the raw kernel result; callers decide how to report it.
sys_openat:
	# Linux x86-64 syscall number for openat is 257.
	mov rax, 257
	syscall
	ret

.size sys_openat, . - sys_openat

.section .note.GNU-stack,"",@progbits
