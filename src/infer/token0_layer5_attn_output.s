.intel_syntax noprefix

.equ GGML_TYPE_Q8_0, 8
.equ Q8_0_BLOCK_BYTES, 34
.equ TOKEN0_LAYER5_ATTN_CONTEXT_VALUES, 4096
.equ TOKEN0_LAYER5_ATTN_OUTPUT_VALUES, 3072
.equ TOKEN0_LAYER5_ATTN_OUTPUT_BYTES, TOKEN0_LAYER5_ATTN_OUTPUT_VALUES * 4
.equ TOKEN0_LAYER5_POST_ATTN_RESIDUAL_VALUES, 3072
.equ TOKEN0_LAYER5_POST_ATTN_RESIDUAL_BYTES, TOKEN0_LAYER5_POST_ATTN_RESIDUAL_VALUES * 4

.section .rodata

token0_layer5_attn_output_matvec_text:
	.ascii "token0_layer5_attn_output_matvec: "
token0_layer5_attn_output_matvec_text_end:

token0_layer5_attn_output0_f32_text:
	.ascii "token0_layer5_attn_output0_f32_hex: "
token0_layer5_attn_output0_f32_text_end:

token0_layer5_attn_output1_f32_text:
	.ascii "token0_layer5_attn_output1_f32_hex: "
token0_layer5_attn_output1_f32_text_end:

token0_layer5_attn_output2_f32_text:
	.ascii "token0_layer5_attn_output2_f32_hex: "
token0_layer5_attn_output2_f32_text_end:

token0_layer5_attn_output3_f32_text:
	.ascii "token0_layer5_attn_output3_f32_hex: "
token0_layer5_attn_output3_f32_text_end:

token0_layer5_post_attn_residual_text:
	.ascii "token0_layer5_post_attn_residual: "
token0_layer5_post_attn_residual_text_end:

token0_layer5_post_attn_residual0_f32_text:
	.ascii "token0_layer5_post_attn_residual0_f32_hex: "
token0_layer5_post_attn_residual0_f32_text_end:

token0_layer5_post_attn_residual1_f32_text:
	.ascii "token0_layer5_post_attn_residual1_f32_hex: "
token0_layer5_post_attn_residual1_f32_text_end:

token0_layer5_post_attn_residual2_f32_text:
	.ascii "token0_layer5_post_attn_residual2_f32_hex: "
token0_layer5_post_attn_residual2_f32_text_end:

token0_layer5_post_attn_residual3_f32_text:
	.ascii "token0_layer5_post_attn_residual3_f32_hex: "
token0_layer5_post_attn_residual3_f32_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

.section .bss

.global token0_layer5_attn_output_matvec_status
.balign 8
token0_layer5_attn_output_matvec_status:
	.skip 8

.balign 4
token0_layer5_attn_output:
	.skip TOKEN0_LAYER5_ATTN_OUTPUT_BYTES

.global token0_layer5_post_attn_residual_status
.balign 8
token0_layer5_post_attn_residual_status:
	.skip 8

.global token0_layer5_post_attn_residual
.balign 4
token0_layer5_post_attn_residual:
	.skip TOKEN0_LAYER5_POST_ATTN_RESIDUAL_BYTES

.section .text

.global run_token0_layer5_attn_output_matvec_status
.type run_token0_layer5_attn_output_matvec_status, @function

# Contract: run the token-0 layer-5 attention output-projection matvec smoke
# and publish its status line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads the live mapping handoff slots, retained
# blk.5.attn_output.weight descriptor, token0_layer5_attn_context_status, and
# token0_layer5_attn_context.
# Outputs: writes token0_layer5_attn_output_matvec_status and, on success,
# fills the private token0_layer5_attn_output buffer. Always prints exactly one
# status label/value/newline sequence to stdout, then prints the first four
# exact-hex output-projection words only when the status is 1. The return
# register is unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags through the
# smoke helper and summary writers. The matvec helper preserves the
# callee-saved registers it uses internally.
# Ownership/lifetime: borrows the model mmap and exported layer-5 attention
# context only for this call; owns the output-projection status and private
# output storage for later focused layer-5 work. The mmap remains owned by
# _start and must be released separately.
# Error behavior: status is 1 only after a bounded Q8_0 matvec completes.
# Otherwise status is 0, no layer-5 output-projection matrix payload bytes are
# read, and no output-projection exact-hex words are printed. Output write
# failures are diagnostic-only in the current milestone.
run_token0_layer5_attn_output_matvec_status:
	call token0_layer5_attn_output_matvec_smoke
	mov qword ptr [rip + token0_layer5_attn_output_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer5_attn_output_matvec_text]
	mov rdx, token0_layer5_attn_output_matvec_text_end - token0_layer5_attn_output_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer5_attn_output_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer5_attn_output_slice
	ret

.size run_token0_layer5_attn_output_matvec_status, . - run_token0_layer5_attn_output_matvec_status

.global run_token0_layer5_post_attn_residual_status
.type run_token0_layer5_post_attn_residual_status, @function

# Contract: run the token-0 layer-5 post-attention residual smoke and publish
# its status line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads token0_layer4_post_ffn_residual_status,
# token0_layer5_attn_output_matvec_status, layer5_attn_output_tensor_dim1,
# token0_layer4_post_ffn_residual, and the private token0_layer5_attn_output
# buffer.
# Outputs: writes token0_layer5_post_attn_residual_status and, on success,
# fills the exported token0_layer5_post_attn_residual buffer with 3072 scalar
# f32 residual sums. Always prints exactly one status label/value/newline
# sequence to stdout and prints the first four exact-hex residual words only
# when the status is 1. The return register is unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1 and flags through the smoke
# helper and summary writers.
# Ownership/lifetime: borrows the retained layer-4 post-FFN residual and this
# module's private layer-5 output-projection buffer only during this call; owns
# the exported layer-5 post-attention residual handoff for later FFN work. This
# function does not read mapped tensor payload bytes.
# Error behavior: status is 1 only after both prerequisite statuses are present
# and the retained layer-5 attention output descriptor still proves a
# 3072-wide hidden row. Otherwise status is 0 and no residual bytes are written
# or printed. Output write failures remain diagnostic-only.
run_token0_layer5_post_attn_residual_status:
	call token0_layer5_post_attn_residual_smoke
	mov qword ptr [rip + token0_layer5_post_attn_residual_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer5_post_attn_residual_text]
	mov rdx, token0_layer5_post_attn_residual_text_end - token0_layer5_post_attn_residual_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer5_post_attn_residual_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer5_post_attn_residual_slice
	ret

.size run_token0_layer5_post_attn_residual_status, . - run_token0_layer5_post_attn_residual_status

.type token0_layer5_attn_output_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-5 single-token
# attention context through the retained blk.5.attn_output.weight matrix.
# Inputs: no register inputs. Reads the process-owned layer5_attn_output tensor
# slot, live mapping descriptor, token0_layer5_attn_context_status, and
# token0_layer5_attn_context.
# Outputs: rax = 1 when the layer-5 context is available and
# blk.5.attn_output.weight is exactly a two-dimensional Q8_0 [4096 x 3072]
# matrix whose complete payload span fits inside the mapping, after
# q8_0_matvec_f32 writes token0_layer5_attn_output; otherwise rax = 0 and no
# layer-5 output-projection matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the exported layer-5 context as the shared f32 input
# vector, and writes exactly TOKEN0_LAYER5_ATTN_OUTPUT_BYTES into private
# static output storage on success. The mmap remains owned by _start and must
# be released separately.
# Error behavior: this smoke gate returns status only; invalid prerequisites,
# non-target synthetic GGUF fixtures, shape mismatches, and bounds failures
# skip with status 0.
token0_layer5_attn_output_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer5_attn_context_status], 1
	jne .Llayer5_attn_output_smoke_done
	cmp qword ptr [rip + layer5_attn_output_tensor_found], 1
	jne .Llayer5_attn_output_smoke_done
	cmp qword ptr [rip + layer5_attn_output_tensor_n_dimensions], 2
	jne .Llayer5_attn_output_smoke_done
	cmp qword ptr [rip + layer5_attn_output_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer5_attn_output_smoke_done
	cmp qword ptr [rip + layer5_attn_output_tensor_dim0], TOKEN0_LAYER5_ATTN_CONTEXT_VALUES
	jne .Llayer5_attn_output_smoke_done
	cmp qword ptr [rip + layer5_attn_output_tensor_dim1], TOKEN0_LAYER5_ATTN_OUTPUT_VALUES
	jne .Llayer5_attn_output_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-5 output-projection matrix start and prove the full row-major Q8_0
	# payload fits inside the live mapping before passing any mmap pointer to
	# the shared matvec helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer5_attn_output_smoke_skip
	mov rdx, qword ptr [rip + layer5_attn_output_tensor_offset]
	test rdx, rdx
	js .Llayer5_attn_output_smoke_skip
	add rax, rdx
	jc .Llayer5_attn_output_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer5_attn_output_smoke_skip

	mov r8, TOKEN0_LAYER5_ATTN_CONTEXT_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer5_attn_output_smoke_skip
	mov rcx, TOKEN0_LAYER5_ATTN_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer5_attn_output_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer5_attn_output_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer5_attn_output_smoke_skip
	add rdi, rax
	jc .Llayer5_attn_output_smoke_skip

	lea rsi, [rip + token0_layer5_attn_context]
	lea rdx, [rip + token0_layer5_attn_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer5_attn_output_smoke_skip:
	xor eax, eax

.Llayer5_attn_output_smoke_done:
	ret

.size token0_layer5_attn_output_matvec_smoke, . - token0_layer5_attn_output_matvec_smoke

.type token0_layer5_post_attn_residual_smoke, @function

# Contract: derive the token-0 layer-5 post-attention residual activation.
# Inputs: no register inputs. Reads token0_layer4_post_ffn_residual_status,
# token0_layer5_attn_output_matvec_status, layer5_attn_output_tensor_dim1,
# token0_layer4_post_ffn_residual, and token0_layer5_attn_output.
# Outputs: rax = 1 after writing 3072 f32 sums to the exported
# token0_layer5_post_attn_residual buffer; otherwise rax = 0 and no layer-5
# residual bytes are written.
# Clobbers: caller-saved registers, xmm0, xmm1 and flags.
# Ownership/lifetime: reads only static layer-4 residual and private layer-5
# output-projection storage, writes only module-owned static post-attention
# residual storage, and does not read any mapped tensor payload bytes.
# Error behavior: this is a status-only smoke gate for the layer-5 residual,
# not final layer execution. Missing prerequisites or a non-target hidden width
# are skipped with status 0.
token0_layer5_post_attn_residual_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer4_post_ffn_residual_status], 1
	jne .Llayer5_post_attn_residual_done
	cmp qword ptr [rip + token0_layer5_attn_output_matvec_status], 1
	jne .Llayer5_post_attn_residual_done

	# The output-projection matvec status proves the private output buffer was
	# written. Repeat the descriptor-width guard locally so this handoff stays
	# tied to the target 3072-wide hidden size.
	cmp qword ptr [rip + layer5_attn_output_tensor_dim1], TOKEN0_LAYER5_POST_ATTN_RESIDUAL_VALUES
	jne .Llayer5_post_attn_residual_done

	lea rsi, [rip + token0_layer4_post_ffn_residual]
	lea rdx, [rip + token0_layer5_attn_output]
	lea rdi, [rip + token0_layer5_post_attn_residual]
	mov rcx, TOKEN0_LAYER5_POST_ATTN_RESIDUAL_VALUES

.Llayer5_post_attn_residual_loop:
	vmovss xmm0, dword ptr [rsi]
	vmovss xmm1, dword ptr [rdx]
	vaddss xmm0, xmm0, xmm1
	vmovss dword ptr [rdi], xmm0
	add rsi, 4
	add rdx, 4
	add rdi, 4
	dec rcx
	jnz .Llayer5_post_attn_residual_loop

	mov eax, 1

.Llayer5_post_attn_residual_done:
	ret

.size token0_layer5_post_attn_residual_smoke, . - token0_layer5_post_attn_residual_smoke

.type print_token0_layer5_attn_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-5 attention
# output projection when that matvec smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer5_attn_output_matvec_status and
# the first four f32 words of token0_layer5_attn_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer5_attn_output_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads private module-owned layer-5 output-projection
# storage only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer5_attn_output_slice:
	cmp qword ptr [rip + token0_layer5_attn_output_matvec_status], 1
	jne .Lprint_layer5_attn_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer5_attn_output0_f32_text]
	mov rdx, token0_layer5_attn_output0_f32_text_end - token0_layer5_attn_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer5_attn_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer5_attn_output1_f32_text]
	mov rdx, token0_layer5_attn_output1_f32_text_end - token0_layer5_attn_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer5_attn_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer5_attn_output2_f32_text]
	mov rdx, token0_layer5_attn_output2_f32_text_end - token0_layer5_attn_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer5_attn_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer5_attn_output3_f32_text]
	mov rdx, token0_layer5_attn_output3_f32_text_end - token0_layer5_attn_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer5_attn_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer5_attn_output_slice_done:
	ret

.size print_token0_layer5_attn_output_slice, . - print_token0_layer5_attn_output_slice

.type print_token0_layer5_post_attn_residual_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-5
# post-attention residual when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer5_post_attn_residual_status
# and the first four f32 words of token0_layer5_post_attn_residual.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer5_post_attn_residual_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads module-owned layer-5 post-attention residual
# storage only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer5_post_attn_residual_slice:
	cmp qword ptr [rip + token0_layer5_post_attn_residual_status], 1
	jne .Lprint_layer5_post_attn_residual_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer5_post_attn_residual0_f32_text]
	mov rdx, token0_layer5_post_attn_residual0_f32_text_end - token0_layer5_post_attn_residual0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer5_post_attn_residual]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer5_post_attn_residual1_f32_text]
	mov rdx, token0_layer5_post_attn_residual1_f32_text_end - token0_layer5_post_attn_residual1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer5_post_attn_residual + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer5_post_attn_residual2_f32_text]
	mov rdx, token0_layer5_post_attn_residual2_f32_text_end - token0_layer5_post_attn_residual2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer5_post_attn_residual + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer5_post_attn_residual3_f32_text]
	mov rdx, token0_layer5_post_attn_residual3_f32_text_end - token0_layer5_post_attn_residual3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer5_post_attn_residual + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer5_post_attn_residual_slice_done:
	ret

.size print_token0_layer5_post_attn_residual_slice, . - print_token0_layer5_post_attn_residual_slice

.section .note.GNU-stack,"",@progbits
