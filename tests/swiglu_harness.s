.intel_syntax noprefix

.section .rodata

ok_text:
	.ascii "swiglu: ok\n"
ok_text_end:

fail1_text:
	.ascii "swiglu: fixture 1 failed\n"
fail1_text_end:

fail2_text:
	.ascii "swiglu: fixture 2 failed\n"
fail2_text_end:

.balign 16
abs_mask:
	.long 0x7fffffff
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000

.balign 4
tolerance:
	.long 0x3727c5ac

.balign 4
fixture_gate:
	.long 0x00000000
	.long 0x3f800000
	.long 0xbf800000
	.long 0x40000000
	.long 0xc0000000

.balign 4
fixture_up:
	.long 0x41100000
	.long 0x40000000
	.long 0x40000000
	.long 0xbf000000
	.long 0xbf000000

.balign 4
fixture_expected:
	# Reference values from y = (x / (1 + exp(-x))) * up, rounded to f32.
	.long 0x00000000
	.long 0x3fbb26a8
	.long 0xbf09b2b1
	.long 0xbf617beb
	.long 0x3df420a9

.section .bss

.balign 4
swiglu_out:
	.skip 20

.balign 4
swiglu_zero_out:
	.skip 4

.section .text

.global _start
.type _start, @function

# Contract: standalone no-libc verification entry for the scalar f32 SwiGLU
# primitive.
# Inputs: Linux process entry state is ignored.
# Outputs: does not return. Writes a short status line and exits 0 when all
# fixtures stay within a tight absolute f32 tolerance; exits with the first
# failed fixture number when a mismatch is detected.
# Clobbers: all general-purpose, vector, and x87 registers may be clobbered; no
# caller exists.
# Ownership/lifetime: reads and writes static fixture storage only. The SwiGLU
# routine retains no fixture pointers after each call.
# Error behavior: fixture mismatches are reported to stderr with the fixture
# number; sys_write errors are ignored because the exit status is the verifier.
_start:
	mov dword ptr [rip + swiglu_zero_out], 0x5a5a5a5a
	lea rdi, [rip + fixture_gate]
	lea rsi, [rip + fixture_up]
	lea rdx, [rip + swiglu_zero_out]
	xor ecx, ecx
	call swiglu_f32
	mov eax, dword ptr [rip + swiglu_zero_out]
	mov edx, 0x5a5a5a5a
	cmp eax, edx
	jne .Lfail1

	lea rdi, [rip + fixture_gate]
	lea rsi, [rip + fixture_up]
	lea rdx, [rip + swiglu_out]
	mov ecx, 5
	call swiglu_f32

	lea rsi, [rip + swiglu_out]
	lea rdi, [rip + fixture_expected]
	mov ecx, 5

.Lcheck_fixture2:
	vmovss xmm0, dword ptr [rsi]
	vsubss xmm0, xmm0, dword ptr [rdi]
	vandps xmm0, xmm0, xmmword ptr [rip + abs_mask]
	vcomiss xmm0, dword ptr [rip + tolerance]
	jp .Lfail2
	ja .Lfail2
	add rsi, 4
	add rdi, 4
	dec ecx
	jne .Lcheck_fixture2

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

.size _start, . - _start

.section .note.GNU-stack,"",@progbits
