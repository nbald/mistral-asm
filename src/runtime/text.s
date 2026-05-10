.intel_syntax noprefix

.equ DECIMAL_SCRATCH_SIZE, 32
.equ HEX_SCRATCH_SIZE, 16

.section .rodata

hex_digits:
	.ascii "0123456789abcdef"

.section .text

.global str_eq_exact
.type str_eq_exact, @function
.global write_u64_decimal
.type write_u64_decimal, @function
.global write_u32_hex
.type write_u32_hex, @function
.global write_bounded_c_string
.type write_bounded_c_string, @function

# Contract: compare a NUL-terminated process string against an exact byte
# literal with known length.
# Inputs: rdi = candidate C string, rsi = literal bytes, rdx = literal length.
# Outputs: rax = 1 when the first rdx bytes match and candidate[rdx] is NUL;
# otherwise rax = 0.
# Clobbers: rax, rcx, r8 and flags.
# Ownership/lifetime: reads both buffers only; does not retain pointers.
# Error behavior: a NULL candidate pointer is treated as no match.
str_eq_exact:
	# Default to "not equal" so all mismatch exits share one return path.
	xor eax, eax
	test rdi, rdi
	jz .Lstr_done

	xor rcx, rcx
.Lstr_loop:
	# After the fixed literal length matches, require the candidate to end there;
	# this prevents "--help-extra" from being accepted.
	cmp rcx, rdx
	je .Lstr_check_nul
	mov r8b, byte ptr [rdi + rcx]
	cmp r8b, byte ptr [rsi + rcx]
	jne .Lstr_done
	inc rcx
	jmp .Lstr_loop

.Lstr_check_nul:
	cmp byte ptr [rdi + rdx], 0
	jne .Lstr_done
	mov eax, 1

.Lstr_done:
	ret

.size str_eq_exact, . - str_eq_exact

# Contract: write an unsigned 64-bit integer as base-10 ASCII.
# Inputs: rdi = output file descriptor; rsi = value to print.
# Outputs: returns after one write(2) attempt for the generated digit span; the
# raw sys_write result is intentionally ignored by this milestone caller.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: uses a fixed scratch area on its own stack frame and does
# not retain pointers after sys_write returns.
# Error behavior: write errors are not reported separately; later CLI output
# plumbing can centralize short-write handling if it becomes useful.
write_u64_decimal:
	push rbp
	mov rbp, rsp
	sub rsp, DECIMAL_SCRATCH_SIZE

	# Fill digits backward from the end of the scratch space. Twenty bytes would
	# hold any u64 value, but the larger round size keeps the frame simple.
	lea r8, [rsp + DECIMAL_SCRATCH_SIZE]
	mov r9, r8
	mov rax, rsi
	test rax, rax
	jnz .Ldecimal_loop

	dec r9
	mov byte ptr [r9], '0'
	jmp .Ldecimal_write

.Ldecimal_loop:
	xor edx, edx
	mov r10d, 10
	div r10
	add dl, '0'
	dec r9
	mov byte ptr [r9], dl
	test rax, rax
	jnz .Ldecimal_loop

.Ldecimal_write:
	# r9 points at the first digit and r8 one byte past the last digit.
	mov rsi, r9
	mov rdx, r8
	sub rdx, r9
	call sys_write

	add rsp, DECIMAL_SCRATCH_SIZE
	pop rbp
	ret

.size write_u64_decimal, . - write_u64_decimal

# Contract: write a 32-bit value as exact lowercase hexadecimal ASCII.
# Inputs: rdi = output file descriptor; esi = value to print.
# Outputs: returns after one write(2) attempt for a fixed `0x` plus 8-digit
# span. The raw sys_write result is intentionally ignored by this milestone
# caller.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: uses a fixed scratch area on its own stack frame and does
# not retain pointers after sys_write returns.
# Error behavior: write errors are not reported separately; this is summary
# output only.
write_u32_hex:
	push rbp
	mov rbp, rsp
	sub rsp, HEX_SCRATCH_SIZE

	mov byte ptr [rsp], '0'
	mov byte ptr [rsp + 1], 'x'
	lea r9, [rip + hex_digits]
	lea r10, [rsp + 10]
	mov r8d, esi
	mov ecx, 8

.Lhex_loop:
	mov eax, r8d
	and eax, 0xf
	mov al, byte ptr [r9 + rax]
	dec r10
	mov byte ptr [r10], al
	shr r8d, 4
	dec ecx
	jnz .Lhex_loop

	mov rsi, rsp
	mov rdx, 10
	call sys_write

	add rsp, HEX_SCRATCH_SIZE
	pop rbp
	ret

.size write_u32_hex, . - write_u32_hex

# Contract: write a NUL-terminated string whose storage has a fixed maximum
# capacity.
# Inputs: rdi = output file descriptor; rsi = string buffer; rdx = maximum bytes
# available in the buffer, including any NUL terminator.
# Outputs: returns after at most one write(2) attempt for the bytes before the
# first NUL or the maximum bound. The raw sys_write result is intentionally
# ignored by this milestone caller.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: reads the caller-owned buffer only during this call and
# does not retain pointers.
# Error behavior: write errors are not reported separately; an empty string
# simply produces no payload write.
write_bounded_c_string:
	push rbx
	push r12
	push r13

	mov rbx, rdi
	mov r12, rsi
	mov r13, rdx
	xor eax, eax

.Lbounded_scan:
	cmp rax, r13
	je .Lbounded_have_len
	cmp byte ptr [r12 + rax], 0
	je .Lbounded_have_len
	inc rax
	jmp .Lbounded_scan

.Lbounded_have_len:
	test rax, rax
	jz .Lbounded_done
	mov rdi, rbx
	mov rsi, r12
	mov rdx, rax
	call sys_write

.Lbounded_done:
	pop r13
	pop r12
	pop rbx
	ret

.size write_bounded_c_string, . - write_bounded_c_string

.section .note.GNU-stack,"",@progbits
