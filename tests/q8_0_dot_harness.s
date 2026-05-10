.intel_syntax noprefix

.section .rodata

ok_text:
	.ascii "q8_0_dot: ok\n"
ok_text_end:

fail1_text:
	.ascii "q8_0_dot: fixture 1 failed\n"
fail1_text_end:

fail2_text:
	.ascii "q8_0_dot: fixture 2 failed\n"
fail2_text_end:

fail3_text:
	.ascii "q8_0_dot: fixture 3 failed\n"
fail3_text_end:

fail4_text:
	.ascii "q8_0_dot: fixture 4 failed\n"
fail4_text_end:

fail5_text:
	.ascii "q8_0_dot: fixture 5 failed\n"
fail5_text_end:

fail6_text:
	.ascii "q8_0_dot: fixture 6 failed\n"
fail6_text_end:

fail7_text:
	.ascii "q8_0_dot: fixture 7 failed\n"
fail7_text_end:

fail8_text:
	.ascii "q8_0_dot: fixture 8 failed\n"
fail8_text_end:

fail9_text:
	.ascii "q8_0_dot: fixture 9 failed\n"
fail9_text_end:

.balign 4
fixture1_block:
	# scale = 1.0, qs = 1..32, x = all 1.0.
	# Expected scalar calculation: 1.0 * (1 + ... + 32) = 528.0.
	.word 0x3c00
	.byte 1, 2, 3, 4, 5, 6, 7, 8
	.byte 9, 10, 11, 12, 13, 14, 15, 16
	.byte 17, 18, 19, 20, 21, 22, 23, 24
	.byte 25, 26, 27, 28, 29, 30, 31, 32

.balign 4
fixture1_x:
	.rept 32
	.long 0x3f800000
	.endr

.balign 4
fixture2_block:
	# scale = 0.5, qs = all -1, x = all 1.0.
	# Expected scalar calculation: 0.5 * (-32) = -16.0.
	.word 0x3800
	.rept 32
	.byte -1
	.endr

.balign 4
fixture2_x:
	.rept 32
	.long 0x3f800000
	.endr

.balign 4
fixture3_block:
	# scale = 2.0, first four qs = 3, -4, 5, -6, remaining qs = 0.
	# x = 0.5, 2.0, -1.0, -0.25, then zeros.
	# Expected scalar calculation:
	# 2.0 * ((3 * 0.5) + (-4 * 2.0) + (5 * -1.0) + (-6 * -0.25)) = -20.0.
	.word 0x4000
	.byte 3, -4, 5, -6
	.rept 28
	.byte 0
	.endr

.balign 4
fixture3_x:
	.long 0x3f000000
	.long 0x40000000
	.long 0xbf800000
	.long 0xbe800000
	.rept 28
	.long 0
	.endr

.balign 4
fixture4_blocks:
	# Two-block row. Block 0 matches fixture 1 and contributes 528.0.
	.word 0x3c00
	.byte 1, 2, 3, 4, 5, 6, 7, 8
	.byte 9, 10, 11, 12, 13, 14, 15, 16
	.byte 17, 18, 19, 20, 21, 22, 23, 24
	.byte 25, 26, 27, 28, 29, 30, 31, 32
	# Block 1 matches fixture 2 and contributes -16.0.
	.word 0x3800
	.rept 32
	.byte -1
	.endr

.balign 4
fixture4_x:
	.rept 64
	.long 0x3f800000
	.endr

.balign 4
fixture5_blocks:
	# Two-block row with a zero first block and a non-zero second block. This
	# catches missing pointer advancement on either the Q8_0 or f32 side.
	.word 0x3c00
	.rept 32
	.byte 0
	.endr
	.word 0x4000
	.byte 3, -4, 5, -6
	.rept 28
	.byte 0
	.endr

.balign 4
fixture5_x:
	.rept 32
	.long 0x3f800000
	.endr
	.long 0x3f000000
	.long 0x40000000
	.long 0xbf800000
	.long 0xbe800000
	.rept 28
	.long 0
	.endr

.balign 4
fixture7_matrix:
	# Two-row, two-block matrix for the scalar matvec routine. Row 0 matches
	# fixture 4 and contributes 512.0 with an all-ones activation vector.
	.word 0x3c00
	.byte 1, 2, 3, 4, 5, 6, 7, 8
	.byte 9, 10, 11, 12, 13, 14, 15, 16
	.byte 17, 18, 19, 20, 21, 22, 23, 24
	.byte 25, 26, 27, 28, 29, 30, 31, 32
	.word 0x3800
	.rept 32
	.byte -1
	.endr
	# Row 1 uses different scales and quant values to catch missing row
	# advancement: block 0 contributes -4.0, block 1 contributes 32.0.
	.word 0x4000
	.byte 3, -4, 5, -6
	.rept 28
	.byte 0
	.endr
	.word 0x3800
	.rept 32
	.byte 2
	.endr

.balign 4
fixture7_x:
	.rept 64
	.long 0x3f800000
	.endr

.section .bss

.balign 4
matvec_out:
	.skip 8

.balign 4
matvec_zero_out:
	.skip 4

.section .text

.global _start
.type _start, @function

# Contract: standalone no-libc verification entry for the scalar Q8_0 dot and
# matvec routines.
# Inputs: Linux process entry state is ignored.
# Outputs: does not return. Writes a short status line and exits 0 when all
# fixtures match their expected f32 bit patterns; exits with the first failed
# fixture number when a mismatch is detected.
# Clobbers: all general-purpose and vector registers may be clobbered; no caller
# exists.
# Ownership/lifetime: reads static fixture storage only. The Q8_0 routines retain
# no fixture pointers after each call.
# Error behavior: exact-bit mismatches are reported to stderr with the fixture
# number; sys_write errors are ignored because the exit status is the verifier.
_start:
	lea rdi, [rip + fixture1_block]
	lea rsi, [rip + fixture1_x]
	call q8_0_dot_f32_block
	movd eax, xmm0
	mov edx, 0x44040000
	cmp eax, edx
	jne .Lfail1

	lea rdi, [rip + fixture2_block]
	lea rsi, [rip + fixture2_x]
	call q8_0_dot_f32_block
	movd eax, xmm0
	mov edx, 0xc1800000
	cmp eax, edx
	jne .Lfail2

	lea rdi, [rip + fixture3_block]
	lea rsi, [rip + fixture3_x]
	call q8_0_dot_f32_block
	movd eax, xmm0
	mov edx, 0xc1a00000
	cmp eax, edx
	jne .Lfail3

	lea rdi, [rip + fixture4_blocks]
	lea rsi, [rip + fixture4_x]
	mov edx, 2
	call q8_0_dot_f32_row
	movd eax, xmm0
	mov edx, 0x44000000
	cmp eax, edx
	jne .Lfail4

	lea rdi, [rip + fixture5_blocks]
	lea rsi, [rip + fixture5_x]
	mov edx, 2
	call q8_0_dot_f32_row
	movd eax, xmm0
	mov edx, 0xc1a00000
	cmp eax, edx
	jne .Lfail5

	lea rdi, [rip + fixture4_blocks]
	lea rsi, [rip + fixture4_x]
	xor edx, edx
	call q8_0_dot_f32_row
	movd eax, xmm0
	test eax, eax
	jne .Lfail6

	lea rdi, [rip + fixture7_matrix]
	lea rsi, [rip + fixture7_x]
	lea rdx, [rip + matvec_out]
	mov ecx, 2
	mov r8d, 2
	call q8_0_matvec_f32
	mov eax, dword ptr [rip + matvec_out]
	mov edx, 0x44000000
	cmp eax, edx
	jne .Lfail7
	mov eax, dword ptr [rip + matvec_out + 4]
	mov edx, 0x41e00000
	cmp eax, edx
	jne .Lfail8

	mov dword ptr [rip + matvec_zero_out], 0x5a5a5a5a
	lea rdi, [rip + fixture7_matrix]
	lea rsi, [rip + fixture7_x]
	lea rdx, [rip + matvec_zero_out]
	xor ecx, ecx
	mov r8d, 2
	call q8_0_matvec_f32
	mov eax, dword ptr [rip + matvec_zero_out]
	mov edx, 0x5a5a5a5a
	cmp eax, edx
	jne .Lfail9

	mov rdi, 1
	lea rsi, [rip + ok_text]
	mov rdx, ok_text_end - ok_text
	call sys_write

	xor edi, edi
	call sys_exit

.Lfail1:
	mov rdi, 2
	lea rsi, [rip + fail1_text]
	mov rdx, fail1_text_end - fail1_text
	call sys_write
	mov edi, 1
	call sys_exit

.Lfail2:
	mov rdi, 2
	lea rsi, [rip + fail2_text]
	mov rdx, fail2_text_end - fail2_text
	call sys_write
	mov edi, 2
	call sys_exit

.Lfail3:
	mov rdi, 2
	lea rsi, [rip + fail3_text]
	mov rdx, fail3_text_end - fail3_text
	call sys_write
	mov edi, 3
	call sys_exit

.Lfail4:
	mov rdi, 2
	lea rsi, [rip + fail4_text]
	mov rdx, fail4_text_end - fail4_text
	call sys_write
	mov edi, 4
	call sys_exit

.Lfail5:
	mov rdi, 2
	lea rsi, [rip + fail5_text]
	mov rdx, fail5_text_end - fail5_text
	call sys_write
	mov edi, 5
	call sys_exit

.Lfail6:
	mov rdi, 2
	lea rsi, [rip + fail6_text]
	mov rdx, fail6_text_end - fail6_text
	call sys_write
	mov edi, 6
	call sys_exit

.Lfail7:
	mov rdi, 2
	lea rsi, [rip + fail7_text]
	mov rdx, fail7_text_end - fail7_text
	call sys_write
	mov edi, 7
	call sys_exit

.Lfail8:
	mov rdi, 2
	lea rsi, [rip + fail8_text]
	mov rdx, fail8_text_end - fail8_text
	call sys_write
	mov edi, 8
	call sys_exit

.Lfail9:
	mov rdi, 2
	lea rsi, [rip + fail9_text]
	mov rdx, fail9_text_end - fail9_text
	call sys_write
	mov edi, 9
	call sys_exit

.size _start, . - _start

.section .note.GNU-stack,"",@progbits
