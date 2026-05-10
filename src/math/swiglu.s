.intel_syntax noprefix

.section .text

.global swiglu_f32
.type swiglu_f32, @function

# Contract: compute scalar f32 SwiGLU activation over two contiguous rows.
# Inputs: rdi = pointer to gate f32 values; rsi = pointer to up f32 values;
# rdx = pointer to caller-owned f32 output storage; rcx = element count.
# Outputs: writes `element_count` f32 values in row order, each equal to
# `silu(gate[i]) * up[i]`, where `silu(x) = x / (1 + exp(-x))`. A zero element
# count writes nothing.
# Clobbers: rax, r8, x87 stack registers, x87 status, and flags.
# Ownership/lifetime: reads `element_count * 4` bytes from gate and up; writes
# `element_count * 4` bytes to output; retains no pointers. Output storage must
# not overlap unread input because the output is streamed forward.
# Error behavior: none; callers must provide valid spans, a count representable
# as a non-negative signed 64-bit integer, and finite inputs when finite outputs
# are expected.
swiglu_f32:
	test rcx, rcx
	je .Lswiglu_done

	xor eax, eax
	mov r8, rcx

.Lswiglu_loop:
	mov ecx, dword ptr [rdi + rax * 4]
	fld dword ptr [rdi + rax * 4]
	test ecx, 0x80000000
	jnz .Lswiglu_negative

	# Non-negative gate values use the stable form x / (1 + exp(-x)); the
	# exponent is never larger than one for finite x >= 0.
	fld st(0)
	fchs
	call exp_x87_st0
	fld1
	faddp st(1), st(0)
	fdivp st(1), st(0)
	jmp .Lswiglu_multiply_up

.Lswiglu_negative:
	# Negative gate values use x * exp(x) / (1 + exp(x)) to avoid overflow from
	# exp(-x) on very negative activations.
	fld st(0)
	call exp_x87_st0
	fld st(0)
	fld1
	faddp st(1), st(0)
	fdivp st(1), st(0)
	fmulp st(1), st(0)

.Lswiglu_multiply_up:
	fld dword ptr [rsi + rax * 4]
	fmulp st(1), st(0)
	fstp dword ptr [rdx + rax * 4]

	inc rax
	cmp rax, r8
	jne .Lswiglu_loop

.Lswiglu_done:
	ret

.size swiglu_f32, . - swiglu_f32

.type exp_x87_st0, @function

# Contract: replace x87 st(0) with exp(st(0)).
# Inputs: st(0) = finite exponent input.
# Outputs: st(0) = exp(input), computed as 2^(input * log2(e)).
# Clobbers: temporary x87 stack slots and x87 status; no general-purpose
# registers are modified.
# Ownership/lifetime: reads no memory and retains no state.
# Error behavior: callers are responsible for finite inputs in the supported
# range. Hardware overflow/underflow follows the process x87 control word.
exp_x87_st0:
	fldl2e
	fmulp st(1), st(0)
	fld st(0)
	frndint
	fxch st(1)
	fsub st(0), st(1)
	f2xm1
	fld1
	faddp st(1), st(0)
	fscale
	fstp st(1)
	ret

.size exp_x87_st0, . - exp_x87_st0

.section .note.GNU-stack,"",@progbits
