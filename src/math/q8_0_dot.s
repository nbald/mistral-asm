.intel_syntax noprefix

.equ Q8_0_BLOCK_QS_OFFSET, 2
.equ Q8_0_BLOCK_SIZE, 32
.equ Q8_0_BLOCK_BYTES, 34
.equ Q8_0_F32_SPAN_BYTES, 128

.section .text

.global q8_0_dot_f32_block
.type q8_0_dot_f32_block, @function
.global q8_0_dot_f32_row
.type q8_0_dot_f32_row, @function
.global q8_0_matvec_f32
.type q8_0_matvec_f32, @function

# Contract: compute one scalar dot product between a GGML Q8_0 weight block and
# a 32-element f32 activation span.
# Inputs: rdi = pointer to one Q8_0 block encoded as a 16-bit IEEE-754 binary16
# scale followed by 32 signed quant bytes; rsi = pointer to 32 little-endian f32
# activation values.
# Outputs: xmm0.low = f32 result of sum((scale * qs[i]) * x[i]) for i in 0..31.
# Clobbers: rax, rcx, xmm0, xmm1, xmm2 and flags.
# Ownership/lifetime: reads exactly the 34-byte Q8_0 block and 128-byte f32 span
# during the call and retains no pointers. Callers own all storage.
# Error behavior: none; this low-level kernel assumes both input pointers are
# valid for the required spans. Malformed tensor bounds are handled before tensor
# payloads reach math code.
q8_0_dot_f32_block:
	# Q8_0 stores the block scale as GGML half precision. Zen 2 provides F16C,
	# so this scalar first version uses the hardware half-to-f32 conversion for
	# the scale and keeps the rest of the computation in scalar f32 operations.
	vxorps xmm0, xmm0, xmm0
	vpxor xmm1, xmm1, xmm1
	vpinsrw xmm1, xmm1, word ptr [rdi], 0
	vcvtph2ps xmm1, xmm1

	xor ecx, ecx

.Ldot_loop:
	# Each quant byte is signed. Convert it through a 32-bit integer so the
	# scalar f32 multiply sees the same value a straightforward C oracle would.
	movsx eax, byte ptr [rdi + Q8_0_BLOCK_QS_OFFSET + rcx]
	vcvtsi2ss xmm2, xmm0, eax
	vmulss xmm2, xmm2, xmm1
	vmulss xmm2, xmm2, dword ptr [rsi + rcx * 4]
	vaddss xmm0, xmm0, xmm2

	inc ecx
	cmp ecx, Q8_0_BLOCK_SIZE
	jne .Ldot_loop

	ret

.size q8_0_dot_f32_block, . - q8_0_dot_f32_block

# Contract: compute one scalar dot product between a contiguous GGML Q8_0 row
# and a matching contiguous f32 activation span.
# Inputs: rdi = pointer to the first Q8_0 block; rsi = pointer to the first f32
# activation value; rdx = number of 32-value Q8_0 blocks to consume.
# Outputs: xmm0.low = f32 result accumulated in block order over
# `32 * block_count` values. A zero block count returns +0.0.
# Clobbers: rax, rcx, r8, r9, r10, xmm0, xmm1, xmm2 and flags.
# Ownership/lifetime: reads `34 * block_count` bytes from the Q8_0 row and
# `128 * block_count` bytes from the activation span during the call and retains
# no pointers. Callers own all storage.
# Error behavior: none; this low-level kernel assumes both spans are valid for
# the requested block count. Tensor bounds and type checks belong to loader and
# graph setup code before math kernels run.
q8_0_dot_f32_row:
	# Keep the public input registers available to future callers by moving the
	# streaming pointers and block countdown into scratch registers owned by this
	# kernel. The scalar loop intentionally matches q8_0_dot_f32_block's
	# dequantize-then-accumulate order so exact-bit tests can compare both paths.
	vxorps xmm0, xmm0, xmm0
	mov r8, rdi
	mov r9, rsi
	mov r10, rdx
	test r10, r10
	je .Lrow_done

.Lrow_block_loop:
	vpxor xmm1, xmm1, xmm1
	vpinsrw xmm1, xmm1, word ptr [r8], 0
	vcvtph2ps xmm1, xmm1

	xor ecx, ecx

.Lrow_value_loop:
	movsx eax, byte ptr [r8 + Q8_0_BLOCK_QS_OFFSET + rcx]
	vcvtsi2ss xmm2, xmm0, eax
	vmulss xmm2, xmm2, xmm1
	vmulss xmm2, xmm2, dword ptr [r9 + rcx * 4]
	vaddss xmm0, xmm0, xmm2

	inc ecx
	cmp ecx, Q8_0_BLOCK_SIZE
	jne .Lrow_value_loop

	# GGML Q8_0 blocks are tightly packed as one binary16 scale plus 32 signed
	# quant bytes. The f32 activation side advances by the matching 32 values.
	add r8, Q8_0_BLOCK_BYTES
	add r9, Q8_0_F32_SPAN_BYTES
	dec r10
	jne .Lrow_block_loop

.Lrow_done:
	ret

.size q8_0_dot_f32_row, . - q8_0_dot_f32_row

# Contract: compute a scalar matrix-vector product for a row-major GGML Q8_0
# weight matrix and one contiguous f32 activation vector.
# Inputs: rdi = pointer to row 0 of the Q8_0 matrix; rsi = pointer to the f32
# activation span shared by every output row; rdx = pointer to caller-owned f32
# output storage; rcx = number of output rows; r8 = number of Q8_0 blocks per
# row, where each block covers 32 activation values.
# Outputs: writes `row_count` f32 results to `output[i]` in row order. A zero
# row count writes nothing.
# Clobbers: rax, rcx, rdi, rsi, rdx, r8, r9, r10, xmm0, xmm1, xmm2 and flags.
# The callee-saved registers used to hold loop state are restored before return.
# Ownership/lifetime: reads `row_count * block_count * 34` bytes from the Q8_0
# matrix and `block_count * 128` bytes from the activation span during the call;
# writes `row_count * 4` bytes to the output span; retains no pointers. Output
# storage must not overlap unread matrix or activation data because rows are
# written immediately after their dot product is computed.
# Error behavior: none; callers must provide valid, non-overflowing spans after
# loader and graph setup have checked tensor bounds, types, and shapes.
q8_0_matvec_f32:
	# Keep matvec loop state in callee-saved registers because each row dot owns
	# the usual caller-saved registers while it streams over Q8_0 blocks.
	push rbx
	push r12
	push r13
	push r14
	push r15

	mov r12, rdi
	mov r13, rsi
	mov r14, rdx
	mov r15, rcx
	mov rbx, r8
	test r15, r15
	je .Lmatvec_done

.Lmatvec_row_loop:
	mov rdi, r12
	mov rsi, r13
	mov rdx, rbx
	call q8_0_dot_f32_row
	vmovss dword ptr [r14], xmm0

	# Each row is a tight sequence of Q8_0 blocks. Recompute the byte stride
	# after the call so the matvec loop does not depend on caller-saved state
	# surviving across the row-dot helper.
	mov rax, rbx
	shl rax, 5
	lea rax, [rax + rbx * 2]
	add r12, rax
	add r14, 4
	dec r15
	jne .Lmatvec_row_loop

.Lmatvec_done:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	ret

.size q8_0_matvec_f32, . - q8_0_matvec_f32

.section .note.GNU-stack,"",@progbits
