.intel_syntax noprefix

.equ Q8_0_BLOCK_QS_OFFSET, 2
.equ Q8_0_BLOCK_SIZE, 32

.section .text

.global q8_0_dot_f32_block
.type q8_0_dot_f32_block, @function

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

.section .note.GNU-stack,"",@progbits
