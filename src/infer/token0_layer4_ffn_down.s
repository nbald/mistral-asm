.intel_syntax noprefix

.equ GGML_TYPE_Q8_0, 8
.equ Q8_0_BLOCK_BYTES, 34
.equ TOKEN0_LAYER4_FFN_SWIGLU_VALUES, 9216
.equ TOKEN0_LAYER4_FFN_DOWN_OUTPUT_VALUES, 3072
.equ TOKEN0_LAYER4_FFN_DOWN_OUTPUT_BYTES, TOKEN0_LAYER4_FFN_DOWN_OUTPUT_VALUES * 4
.equ TOKEN0_LAYER4_POST_FFN_RESIDUAL_VALUES, 3072
.equ TOKEN0_LAYER4_POST_FFN_RESIDUAL_BYTES, TOKEN0_LAYER4_POST_FFN_RESIDUAL_VALUES * 4

.section .rodata

token0_layer4_ffn_down_matvec_text:
	.ascii "token0_layer4_ffn_down_matvec: "
token0_layer4_ffn_down_matvec_text_end:

token0_layer4_ffn_down_output0_f32_text:
	.ascii "token0_layer4_ffn_down_output0_f32_hex: "
token0_layer4_ffn_down_output0_f32_text_end:

token0_layer4_ffn_down_output1_f32_text:
	.ascii "token0_layer4_ffn_down_output1_f32_hex: "
token0_layer4_ffn_down_output1_f32_text_end:

token0_layer4_ffn_down_output2_f32_text:
	.ascii "token0_layer4_ffn_down_output2_f32_hex: "
token0_layer4_ffn_down_output2_f32_text_end:

token0_layer4_ffn_down_output3_f32_text:
	.ascii "token0_layer4_ffn_down_output3_f32_hex: "
token0_layer4_ffn_down_output3_f32_text_end:

token0_layer4_post_ffn_residual_text:
	.ascii "token0_layer4_post_ffn_residual: "
token0_layer4_post_ffn_residual_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

.section .bss

.global token0_layer4_ffn_down_matvec_status
.balign 8
token0_layer4_ffn_down_matvec_status:
	.skip 8

.balign 4
token0_layer4_ffn_down_output:
	.skip TOKEN0_LAYER4_FFN_DOWN_OUTPUT_BYTES

.global token0_layer4_post_ffn_residual_status
.balign 8
token0_layer4_post_ffn_residual_status:
	.skip 8

.balign 4
token0_layer4_post_ffn_residual:
	.skip TOKEN0_LAYER4_POST_FFN_RESIDUAL_BYTES

.section .text

.global run_token0_layer4_ffn_down_matvec_status
.type run_token0_layer4_ffn_down_matvec_status, @function

# Contract: run the token-0 layer-4 FFN down matvec smoke and publish its
# status line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads the live mapping handoff slots, the retained
# blk.4.ffn_down.weight descriptor, token0_layer4_ffn_swiglu_status, and the
# token0_layer4_ffn_swiglu_output buffer owned by the layer-4 FFN module.
# Outputs: writes token0_layer4_ffn_down_matvec_status and, on success, fills
# private token0_layer4_ffn_down_output storage with 3072 f32 values. Always
# prints exactly one status label/value/newline sequence to stdout and prints
# the first four exact-hex output words only when the status is 1. The return
# register is unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: borrows the model mmap and the retained layer-4 SwiGLU
# activation only during this call; owns the status and private down output
# storage in this module. The mmap remains owned by _start.
# Error behavior: status is 1 only after a bounded Q8_0 matvec completes;
# otherwise status is 0, no layer-4 FFN down payload bytes are read, and no
# exact-hex output words are printed. Output write errors are diagnostic-only
# and are not surfaced separately.
run_token0_layer4_ffn_down_matvec_status:
	call token0_layer4_ffn_down_matvec_smoke
	mov qword ptr [rip + token0_layer4_ffn_down_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_down_matvec_text]
	mov rdx, token0_layer4_ffn_down_matvec_text_end - token0_layer4_ffn_down_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer4_ffn_down_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer4_ffn_down_output_slice
	ret

.size run_token0_layer4_ffn_down_matvec_status, . - run_token0_layer4_ffn_down_matvec_status

.global run_token0_layer4_post_ffn_residual_status
.type run_token0_layer4_post_ffn_residual_status, @function

# Contract: run the token-0 layer-4 post-FFN residual smoke and publish only
# its status line.
# Inputs: no register inputs. Reads token0_layer4_post_attn_residual_status,
# token0_layer4_ffn_down_matvec_status, layer4_ffn_down_tensor_dim1,
# token0_layer4_post_attn_residual, and token0_layer4_ffn_down_output.
# Outputs: writes token0_layer4_post_ffn_residual_status and, on success, fills
# private token0_layer4_post_ffn_residual storage with 3072 f32 residual sums.
# Always prints exactly one status label/value/newline sequence to stdout and
# does not publish residual exact-hex labels in this status-only step. The
# return register is unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1 and flags through the smoke
# helper and summary writers.
# Ownership/lifetime: borrows the retained layer-4 post-attention residual
# owned by its focused module and this module's retained FFN down output only
# during this call; owns the post-FFN residual status and private buffer. This
# function does not read mapped tensor payload bytes.
# Error behavior: status is 1 only after both prerequisite statuses are present
# and the retained down descriptor still proves a 3072-wide output row.
# Otherwise status is 0 and no residual bytes are written. Output write errors
# remain diagnostic-only.
run_token0_layer4_post_ffn_residual_status:
	call token0_layer4_post_ffn_residual_smoke
	mov qword ptr [rip + token0_layer4_post_ffn_residual_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer4_post_ffn_residual_text]
	mov rdx, token0_layer4_post_ffn_residual_text_end - token0_layer4_post_ffn_residual_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer4_post_ffn_residual_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size run_token0_layer4_post_ffn_residual_status, . - run_token0_layer4_post_ffn_residual_status

.type print_token0_layer4_ffn_down_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-4 FFN down
# projection output when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer4_ffn_down_matvec_status and
# the first four f32 words of token0_layer4_ffn_down_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer4_ffn_down_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads private module-owned layer-4 FFN down output
# storage only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer4_ffn_down_output_slice:
	cmp qword ptr [rip + token0_layer4_ffn_down_matvec_status], 1
	jne .Lprint_layer4_ffn_down_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_down_output0_f32_text]
	mov rdx, token0_layer4_ffn_down_output0_f32_text_end - token0_layer4_ffn_down_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_down_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_down_output1_f32_text]
	mov rdx, token0_layer4_ffn_down_output1_f32_text_end - token0_layer4_ffn_down_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_down_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_down_output2_f32_text]
	mov rdx, token0_layer4_ffn_down_output2_f32_text_end - token0_layer4_ffn_down_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_down_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_down_output3_f32_text]
	mov rdx, token0_layer4_ffn_down_output3_f32_text_end - token0_layer4_ffn_down_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_down_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer4_ffn_down_output_slice_done:
	ret

.size print_token0_layer4_ffn_down_output_slice, . - print_token0_layer4_ffn_down_output_slice

.type token0_layer4_post_ffn_residual_smoke, @function

# Contract: derive the token-0 layer-4 post-FFN residual activation.
# Inputs: no register inputs. Reads token0_layer4_post_attn_residual_status,
# token0_layer4_ffn_down_matvec_status, layer4_ffn_down_tensor_dim1,
# token0_layer4_post_attn_residual, and token0_layer4_ffn_down_output.
# Outputs: rax = 1 after writing 3072 f32 sums to private
# token0_layer4_post_ffn_residual storage; otherwise rax = 0 and no layer-4
# post-FFN residual bytes are written.
# Clobbers: caller-saved registers, xmm0, xmm1 and flags.
# Ownership/lifetime: reads only static residual and FFN-down output storage,
# writes only module-owned static post-FFN residual storage, and does not read
# any mapped tensor payload bytes.
# Error behavior: this is a status-only smoke gate for the layer-4 residual,
# not final layer execution. Missing prerequisites or a non-target output width
# are skipped with status 0.
token0_layer4_post_ffn_residual_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer4_post_attn_residual_status], 1
	jne .Llayer4_post_ffn_residual_done
	cmp qword ptr [rip + token0_layer4_ffn_down_matvec_status], 1
	jne .Llayer4_post_ffn_residual_done

	# The down matvec status proves the output row was written. Repeat the
	# descriptor-width guard locally so this residual add stays tied to the
	# target 3072-wide hidden size.
	cmp qword ptr [rip + layer4_ffn_down_tensor_dim1], TOKEN0_LAYER4_POST_FFN_RESIDUAL_VALUES
	jne .Llayer4_post_ffn_residual_done

	lea rsi, [rip + token0_layer4_post_attn_residual]
	lea rdx, [rip + token0_layer4_ffn_down_output]
	lea rdi, [rip + token0_layer4_post_ffn_residual]
	mov rcx, TOKEN0_LAYER4_POST_FFN_RESIDUAL_VALUES

.Llayer4_post_ffn_residual_loop:
	vmovss xmm0, dword ptr [rsi]
	vmovss xmm1, dword ptr [rdx]
	vaddss xmm0, xmm0, xmm1
	vmovss dword ptr [rdi], xmm0
	add rsi, 4
	add rdx, 4
	add rdi, 4
	dec rcx
	jnz .Llayer4_post_ffn_residual_loop

	mov eax, 1

.Llayer4_post_ffn_residual_done:
	ret

.size token0_layer4_post_ffn_residual_smoke, . - token0_layer4_post_ffn_residual_smoke

.type token0_layer4_ffn_down_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-4 FFN SwiGLU activation
# through blk.4.ffn_down.weight.
# Inputs: no register inputs. Reads the process-owned layer4_ffn_down tensor
# slot, live mapping descriptor, token0_layer4_ffn_swiglu_status, and
# token0_layer4_ffn_swiglu_output.
# Outputs: rax = 1 when the layer-4 FFN SwiGLU activation is available and
# blk.4.ffn_down.weight is exactly a two-dimensional Q8_0 [9216 x 3072] matrix
# whose complete payload span fits inside the mapping, after q8_0_matvec_f32
# writes token0_layer4_ffn_down_output; otherwise rax = 0 and no layer-4 FFN
# down matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the retained layer-4 FFN SwiGLU activation as the
# shared f32 input vector, and writes exactly
# TOKEN0_LAYER4_FFN_DOWN_OUTPUT_BYTES into private module storage on success.
# Error behavior: this is a status-only smoke gate for the layer-4 FFN down
# projection, not final graph setup. Non-target synthetic GGUF fixtures and
# shape or bounds mismatches are skipped with status 0.
token0_layer4_ffn_down_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer4_ffn_swiglu_status], 1
	jne .Llayer4_ffn_down_smoke_done
	cmp qword ptr [rip + layer4_ffn_down_tensor_found], 1
	jne .Llayer4_ffn_down_smoke_done
	cmp qword ptr [rip + layer4_ffn_down_tensor_n_dimensions], 2
	jne .Llayer4_ffn_down_smoke_done
	cmp qword ptr [rip + layer4_ffn_down_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer4_ffn_down_smoke_done
	cmp qword ptr [rip + layer4_ffn_down_tensor_dim0], TOKEN0_LAYER4_FFN_SWIGLU_VALUES
	jne .Llayer4_ffn_down_smoke_done
	cmp qword ptr [rip + layer4_ffn_down_tensor_dim1], TOKEN0_LAYER4_FFN_DOWN_OUTPUT_VALUES
	jne .Llayer4_ffn_down_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-4 FFN down matrix start and prove the complete row-major Q8_0
	# payload fits inside the live mapping before passing any mmap pointer to
	# math code.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer4_ffn_down_smoke_skip
	mov rdx, qword ptr [rip + layer4_ffn_down_tensor_offset]
	test rdx, rdx
	js .Llayer4_ffn_down_smoke_skip
	add rax, rdx
	jc .Llayer4_ffn_down_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer4_ffn_down_smoke_skip

	mov r8, TOKEN0_LAYER4_FFN_SWIGLU_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer4_ffn_down_smoke_skip
	mov rcx, TOKEN0_LAYER4_FFN_DOWN_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer4_ffn_down_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer4_ffn_down_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer4_ffn_down_smoke_skip
	add rdi, rax
	jc .Llayer4_ffn_down_smoke_skip

	lea rsi, [rip + token0_layer4_ffn_swiglu_output]
	lea rdx, [rip + token0_layer4_ffn_down_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer4_ffn_down_smoke_skip:
	xor eax, eax

.Llayer4_ffn_down_smoke_done:
	ret

.size token0_layer4_ffn_down_matvec_smoke, . - token0_layer4_ffn_down_matvec_smoke

.section .note.GNU-stack,"",@progbits
