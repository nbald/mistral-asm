.intel_syntax noprefix

.section .text

.global sys_mmap
.type sys_mmap, @function

# Contract: invoke Linux mmap(2).
# Inputs: rdi = addr, rsi = length, rdx = prot, r10 = flags, r8 = fd,
# r9 = offset. This follows the Linux syscall ABI, not the C function ABI,
# where the fourth argument would otherwise be in rcx.
# Outputs: rax = mapping address on success or negative errno on failure.
# Clobbers: rax, rcx, r11 and flags per the syscall ABI.
# Ownership/lifetime: on success the returned mapping is owned by the caller
# until released with munmap.
# Error behavior: returns the raw kernel result; callers decide how to report it.
sys_mmap:
	# Linux x86-64 syscall number for mmap is 9.
	mov rax, 9
	syscall
	ret

.size sys_mmap, . - sys_mmap

.section .note.GNU-stack,"",@progbits
