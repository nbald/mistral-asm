.intel_syntax noprefix

.section .rodata

ok_text:
	.ascii "rmsnorm: ok\n"
ok_text_end:

fail1_text:
	.ascii "rmsnorm: fixture 1 failed\n"
fail1_text_end:

fail2_text:
	.ascii "rmsnorm: fixture 2 failed\n"
fail2_text_end:

fail3_text:
	.ascii "rmsnorm: fixture 3 failed\n"
fail3_text_end:

fail4_text:
	.ascii "rmsnorm: fixture 4 failed\n"
fail4_text_end:

.balign 4
eps_zero:
	.long 0x00000000

.balign 4
eps_three:
	.long 0x40400000

.balign 4
fixture1_input:
	# mean(square(input)) = 4.0, epsilon = 0.0, so rsqrt = 0.5 exactly.
	.long 0x40000000
	.long 0xc0000000
	.long 0x40000000
	.long 0xc0000000

.balign 4
fixture1_weight:
	.long 0x3f800000
	.long 0x3f800000
	.long 0x3f000000
	.long 0xbf000000

.balign 4
fixture1_expected:
	.long 0x3f800000
	.long 0xbf800000
	.long 0x3f000000
	.long 0x3f000000

.balign 4
fixture2_input:
	# mean(square(input)) = 1.0, epsilon = 3.0, so rsqrt = 0.5 exactly.
	.rept 4
	.long 0x3f800000
	.endr

.balign 4
fixture2_weight:
	.long 0x40000000
	.long 0xc0000000
	.long 0x40800000
	.long 0xc0800000

.balign 4
fixture2_expected:
	.long 0x3f800000
	.long 0xbf800000
	.long 0x40000000
	.long 0xc0000000

.balign 4
fixture3_input:
	# One-element row catches count conversion and signed output behavior.
	.long 0xc0800000

.balign 4
fixture3_weight:
	.long 0xbe800000

.balign 4
fixture3_expected:
	.long 0x3e800000

.section .bss

.balign 4
rmsnorm_out:
	.skip 16

.balign 4
rmsnorm_zero_out:
	.skip 4

.section .text

.global _start
.type _start, @function

# Contract: standalone no-libc verification entry for the scalar f32 RMSNorm
# primitive.
# Inputs: Linux process entry state is ignored.
# Outputs: does not return. Writes a short status line and exits 0 when all
# fixtures match their expected f32 bit patterns; exits with the first failed
# fixture number when a mismatch is detected.
# Clobbers: all general-purpose and vector registers may be clobbered; no caller
# exists.
# Ownership/lifetime: reads and writes static fixture storage only. The RMSNorm
# routine retains no fixture pointers after each call.
# Error behavior: exact-bit mismatches are reported to stderr with the fixture
# number; sys_write errors are ignored because the exit status is the verifier.
_start:
	lea rdi, [rip + fixture1_input]
	lea rsi, [rip + fixture1_weight]
	lea rdx, [rip + rmsnorm_out]
	mov ecx, 4
	vmovss xmm0, dword ptr [rip + eps_zero]
	call rmsnorm_f32
	lea rsi, [rip + rmsnorm_out]
	lea rdi, [rip + fixture1_expected]
	mov ecx, 4
.Lcheck_fixture1:
	mov eax, dword ptr [rsi]
	cmp eax, dword ptr [rdi]
	jne .Lfail1
	add rsi, 4
	add rdi, 4
	dec ecx
	jne .Lcheck_fixture1

	lea rdi, [rip + fixture2_input]
	lea rsi, [rip + fixture2_weight]
	lea rdx, [rip + rmsnorm_out]
	mov ecx, 4
	vmovss xmm0, dword ptr [rip + eps_three]
	call rmsnorm_f32
	lea rsi, [rip + rmsnorm_out]
	lea rdi, [rip + fixture2_expected]
	mov ecx, 4
.Lcheck_fixture2:
	mov eax, dword ptr [rsi]
	cmp eax, dword ptr [rdi]
	jne .Lfail2
	add rsi, 4
	add rdi, 4
	dec ecx
	jne .Lcheck_fixture2

	lea rdi, [rip + fixture3_input]
	lea rsi, [rip + fixture3_weight]
	lea rdx, [rip + rmsnorm_out]
	mov ecx, 1
	vmovss xmm0, dword ptr [rip + eps_zero]
	call rmsnorm_f32
	mov eax, dword ptr [rip + rmsnorm_out]
	mov edx, dword ptr [rip + fixture3_expected]
	cmp eax, edx
	jne .Lfail3

	mov dword ptr [rip + rmsnorm_zero_out], 0x5a5a5a5a
	lea rdi, [rip + fixture1_input]
	lea rsi, [rip + fixture1_weight]
	lea rdx, [rip + rmsnorm_zero_out]
	xor ecx, ecx
	vmovss xmm0, dword ptr [rip + eps_zero]
	call rmsnorm_f32
	mov eax, dword ptr [rip + rmsnorm_zero_out]
	mov edx, 0x5a5a5a5a
	cmp eax, edx
	jne .Lfail4

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

.size _start, . - _start

.section .note.GNU-stack,"",@progbits
