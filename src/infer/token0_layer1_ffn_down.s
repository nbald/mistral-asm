.intel_syntax noprefix

.equ GGML_TYPE_Q8_0, 8
.equ Q8_0_BLOCK_BYTES, 34
.equ TOKEN0_LAYER1_FFN_SWIGLU_VALUES, 9216
.equ TOKEN0_LAYER1_FFN_DOWN_OUTPUT_VALUES, 3072
.equ TOKEN0_LAYER1_FFN_DOWN_OUTPUT_BYTES, TOKEN0_LAYER1_FFN_DOWN_OUTPUT_VALUES * 4

.section .rodata

token0_layer1_ffn_down_matvec_text:
	.ascii "token0_layer1_ffn_down_matvec: "
token0_layer1_ffn_down_matvec_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

.section .bss

.global token0_layer1_ffn_down_matvec_status
.balign 8
token0_layer1_ffn_down_matvec_status:
	.skip 8

.global token0_layer1_ffn_down_output
.balign 4
token0_layer1_ffn_down_output:
	.skip TOKEN0_LAYER1_FFN_DOWN_OUTPUT_BYTES

.section .text

.global run_token0_layer1_ffn_down_matvec_status
.type run_token0_layer1_ffn_down_matvec_status, @function

# Contract: run the token-0 layer-1 FFN down matvec smoke and publish its
# status line.
# Inputs: no register inputs. Reads the live mapping handoff slots, the retained
# blk.1.ffn_down.weight descriptor, token0_layer1_ffn_swiglu_status, and the
# token0_layer1_ffn_swiglu_output buffer owned by the layer-1 FFN module.
# Outputs: writes token0_layer1_ffn_down_matvec_status and, on success, fills
# token0_layer1_ffn_down_output. Always prints exactly one status
# label/value/newline sequence to stdout. The return register is unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: borrows the model mmap and the retained SwiGLU activation
# only for the duration of this call; owns the status and down output storage in
# this module. The mmap remains owned by _start and must be released separately.
# Error behavior: status is 1 only after a bounded Q8_0 matvec completes;
# otherwise status is 0. Output write errors are not reported separately because
# current milestone output is diagnostic summary text.
run_token0_layer1_ffn_down_matvec_status:
	call token0_layer1_ffn_down_matvec_smoke
	mov qword ptr [rip + token0_layer1_ffn_down_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_ffn_down_matvec_text]
	mov rdx, token0_layer1_ffn_down_matvec_text_end - token0_layer1_ffn_down_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_ffn_down_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size run_token0_layer1_ffn_down_matvec_status, . - run_token0_layer1_ffn_down_matvec_status

.type token0_layer1_ffn_down_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-1 FFN SwiGLU activation
# through the reusable blk.1.ffn_down.weight matrix.
# Inputs: no register inputs. Reads the process-owned layer1_ffn_down tensor
# slot, live mapping descriptor, token0_layer1_ffn_swiglu_status, and
# token0_layer1_ffn_swiglu_output.
# Outputs: rax = 1 when the layer-1 FFN SwiGLU activation is available and
# blk.1.ffn_down.weight is exactly a two-dimensional Q8_0 [9216 x 3072] matrix
# whose complete payload span fits inside the mapping, after q8_0_matvec_f32
# writes token0_layer1_ffn_down_output; otherwise rax = 0 and no layer-1 FFN
# down matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the retained layer-1 FFN SwiGLU activation as the
# shared f32 input vector, and writes exactly
# TOKEN0_LAYER1_FFN_DOWN_OUTPUT_BYTES into private module storage on success.
# Error behavior: this is a status-only smoke gate for the layer-1 FFN down
# projection, not final graph setup. Non-target synthetic GGUF fixtures and
# shape or bounds mismatches are skipped with status 0.
token0_layer1_ffn_down_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer1_ffn_swiglu_status], 1
	jne .Llayer1_ffn_down_smoke_done
	cmp qword ptr [rip + layer1_ffn_down_tensor_found], 1
	jne .Llayer1_ffn_down_smoke_done
	cmp qword ptr [rip + layer1_ffn_down_tensor_n_dimensions], 2
	jne .Llayer1_ffn_down_smoke_done
	cmp qword ptr [rip + layer1_ffn_down_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer1_ffn_down_smoke_done
	cmp qword ptr [rip + layer1_ffn_down_tensor_dim0], TOKEN0_LAYER1_FFN_SWIGLU_VALUES
	jne .Llayer1_ffn_down_smoke_done
	cmp qword ptr [rip + layer1_ffn_down_tensor_dim1], TOKEN0_LAYER1_FFN_DOWN_OUTPUT_VALUES
	jne .Llayer1_ffn_down_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-1 FFN down matrix start and prove the complete row-major Q8_0 payload
	# fits inside the live mapping before passing any mmap pointer to math code.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer1_ffn_down_smoke_skip
	mov rdx, qword ptr [rip + layer1_ffn_down_tensor_offset]
	test rdx, rdx
	js .Llayer1_ffn_down_smoke_skip
	add rax, rdx
	jc .Llayer1_ffn_down_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer1_ffn_down_smoke_skip

	mov r8, TOKEN0_LAYER1_FFN_SWIGLU_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer1_ffn_down_smoke_skip
	mov rcx, TOKEN0_LAYER1_FFN_DOWN_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer1_ffn_down_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer1_ffn_down_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer1_ffn_down_smoke_skip
	add rdi, rax
	jc .Llayer1_ffn_down_smoke_skip

	lea rsi, [rip + token0_layer1_ffn_swiglu_output]
	lea rdx, [rip + token0_layer1_ffn_down_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer1_ffn_down_smoke_skip:
	xor eax, eax

.Llayer1_ffn_down_smoke_done:
	ret

.size token0_layer1_ffn_down_matvec_smoke, . - token0_layer1_ffn_down_matvec_smoke

.section .note.GNU-stack,"",@progbits
