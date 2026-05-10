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

.section .note.GNU-stack,"",@progbits
