.intel_syntax noprefix

.section .rodata

.balign 4
rmsnorm_one_f32:
	.long 0x3f800000

.section .text

.global rmsnorm_f32
.type rmsnorm_f32, @function

# Contract: compute scalar f32 RMSNorm over one contiguous activation row.
# Inputs: rdi = pointer to input f32 values; rsi = pointer to f32 weight values;
# rdx = pointer to caller-owned f32 output storage; rcx = element count;
# xmm0.low = epsilon to add after the mean square.
# Outputs: writes `element_count` f32 values in row order, each equal to
# `input[i] * weight[i] / sqrt((sum(input[j]^2) / element_count) + epsilon)`.
# A zero element count writes nothing.
# Clobbers: rax, r8, xmm1, xmm2, xmm3 and flags.
# Ownership/lifetime: reads `element_count * 4` bytes from input twice and
# `element_count * 4` bytes from weights once; writes `element_count * 4` bytes
# to output; retains no pointers. Output storage must not overlap unread input
# or weight storage because the normalized row is streamed after the scale is
# computed.
# Error behavior: none; callers must provide valid spans, a positive count when
# output is expected, a count representable as a positive signed 64-bit integer,
# and an epsilon that keeps the square-root input non-negative.
rmsnorm_f32:
	test rcx, rcx
	je .Lrmsnorm_done

	# First pass: accumulate sum(input[i] * input[i]) in scalar f32. This keeps
	# the primitive auditable before introducing vectorized reductions.
	xor eax, eax
	mov r8, rcx
	vxorps xmm1, xmm1, xmm1

.Lrmsnorm_sum_loop:
	vmovss xmm2, dword ptr [rdi + rax * 4]
	vmulss xmm2, xmm2, xmm2
	vaddss xmm1, xmm1, xmm2

	inc rax
	cmp rax, r8
	jne .Lrmsnorm_sum_loop

	# Convert the row length to f32, compute rsqrt(mean_square + epsilon) with
	# precise scalar sqrt/div instructions, then stream the weighted output.
	vxorps xmm2, xmm2, xmm2
	vcvtsi2ss xmm2, xmm2, r8
	vdivss xmm1, xmm1, xmm2
	vaddss xmm1, xmm1, xmm0
	vsqrtss xmm1, xmm1, xmm1
	vmovss xmm3, dword ptr [rip + rmsnorm_one_f32]
	vdivss xmm1, xmm3, xmm1

	xor eax, eax

.Lrmsnorm_write_loop:
	vmovss xmm2, dword ptr [rdi + rax * 4]
	vmulss xmm2, xmm2, xmm1
	vmulss xmm2, xmm2, dword ptr [rsi + rax * 4]
	vmovss dword ptr [rdx + rax * 4], xmm2

	inc rax
	cmp rax, r8
	jne .Lrmsnorm_write_loop

.Lrmsnorm_done:
	ret

.size rmsnorm_f32, . - rmsnorm_f32

.section .note.GNU-stack,"",@progbits
