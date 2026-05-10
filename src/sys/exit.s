.intel_syntax noprefix

.section .text

.global sys_exit
.type sys_exit, @function

# Contract: terminate the current process with Linux exit(2).
# Inputs: rdi = process exit status.
# Outputs: does not return on success.
# Clobbers: no observable caller state; syscall may clobber rcx, r11 and flags.
# Ownership/lifetime: kernel tears down process resources.
# Error behavior: if the impossible happens and the syscall returns, spin forever
# rather than falling into adjacent code.
sys_exit:
	# Linux x86-64 syscall number for exit is 60.
	mov rax, 60
	syscall

.Lexit_hang:
	jmp .Lexit_hang

.size sys_exit, . - sys_exit

.section .note.GNU-stack,"",@progbits
