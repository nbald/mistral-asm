.intel_syntax noprefix

.equ TOKEN0_LAYER3_POST_ATTN_RESIDUAL_VALUES, 3072
.equ TOKEN0_LAYER3_POST_ATTN_RESIDUAL_BYTES, TOKEN0_LAYER3_POST_ATTN_RESIDUAL_VALUES * 4

.section .rodata

token0_layer3_post_attn_residual_text:
	.ascii "token0_layer3_post_attn_residual: "
token0_layer3_post_attn_residual_text_end:

token0_layer3_post_attn_residual0_f32_text:
	.ascii "token0_layer3_post_attn_residual0_f32_hex: "
token0_layer3_post_attn_residual0_f32_text_end:

token0_layer3_post_attn_residual1_f32_text:
	.ascii "token0_layer3_post_attn_residual1_f32_hex: "
token0_layer3_post_attn_residual1_f32_text_end:

token0_layer3_post_attn_residual2_f32_text:
	.ascii "token0_layer3_post_attn_residual2_f32_hex: "
token0_layer3_post_attn_residual2_f32_text_end:

token0_layer3_post_attn_residual3_f32_text:
	.ascii "token0_layer3_post_attn_residual3_f32_hex: "
token0_layer3_post_attn_residual3_f32_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

.section .bss

.global token0_layer3_post_attn_residual_status
.balign 8
token0_layer3_post_attn_residual_status:
	.skip 8

.global token0_layer3_post_attn_residual
.balign 4
token0_layer3_post_attn_residual:
	.skip TOKEN0_LAYER3_POST_ATTN_RESIDUAL_BYTES

.section .text

.global run_token0_layer3_post_attn_residual_status
.type run_token0_layer3_post_attn_residual_status, @function

# Contract: run the token-0 layer-3 post-attention residual smoke and publish
# its status line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads token0_layer2_post_ffn_residual_status,
# token0_layer3_attn_output_matvec_status, layer3_attn_output_tensor_dim1,
# token0_layer2_post_ffn_residual, and token0_layer3_attn_output.
# Outputs: writes token0_layer3_post_attn_residual_status and, on success,
# fills token0_layer3_post_attn_residual with 3072 scalar f32 residual sums.
# Always prints exactly one status label/value/newline sequence to stdout and
# prints the first four exact-hex residual words only when the status is 1. The
# return register is unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1 and flags through the smoke
# helper and summary writers.
# Ownership/lifetime: borrows the retained layer-2 post-FFN residual and
# layer-3 attention output only during this call; owns the layer-3
# post-attention residual status and buffer for later focused layer-3 work.
# This function does not read mapped tensor payload bytes.
# Error behavior: status is 1 only after both prerequisite statuses are 1 and
# the retained layer-3 attention output descriptor still proves a 3072-wide
# output row. Otherwise status is 0 and no residual bytes are written or
# printed. Output write failures are diagnostic-only in the current milestone.
run_token0_layer3_post_attn_residual_status:
	call token0_layer3_post_attn_residual_smoke
	mov qword ptr [rip + token0_layer3_post_attn_residual_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer3_post_attn_residual_text]
	mov rdx, token0_layer3_post_attn_residual_text_end - token0_layer3_post_attn_residual_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer3_post_attn_residual_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer3_post_attn_residual_slice
	ret

.size run_token0_layer3_post_attn_residual_status, . - run_token0_layer3_post_attn_residual_status

.type token0_layer3_post_attn_residual_smoke, @function

# Contract: derive the token-0 layer-3 post-attention residual activation.
# Inputs: no register inputs. Reads token0_layer2_post_ffn_residual_status,
# token0_layer3_attn_output_matvec_status, layer3_attn_output_tensor_dim1,
# token0_layer2_post_ffn_residual, and token0_layer3_attn_output.
# Outputs: rax = 1 after writing 3072 f32 sums to
# token0_layer3_post_attn_residual; otherwise rax = 0 and no layer-3 residual
# bytes are written.
# Clobbers: caller-saved registers, xmm0, xmm1 and flags.
# Ownership/lifetime: reads only process-owned static residual and attention
# output storage, writes only module-owned static post-attention residual
# storage, and does not read any mapped tensor payload bytes.
# Error behavior: this is a status-only smoke gate for the layer-3 residual,
# not final layer execution. Missing prerequisites or a non-target hidden width
# are skipped with status 0.
token0_layer3_post_attn_residual_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer2_post_ffn_residual_status], 1
	jne .Llayer3_post_attn_residual_done
	cmp qword ptr [rip + token0_layer3_attn_output_matvec_status], 1
	jne .Llayer3_post_attn_residual_done

	# The output-projection matvec status proves its static row was written.
	# Repeat the descriptor-width guard locally so this residual add remains
	# tied to the target 3072-wide hidden size.
	cmp qword ptr [rip + layer3_attn_output_tensor_dim1], TOKEN0_LAYER3_POST_ATTN_RESIDUAL_VALUES
	jne .Llayer3_post_attn_residual_done

	lea rsi, [rip + token0_layer2_post_ffn_residual]
	lea rdx, [rip + token0_layer3_attn_output]
	lea rdi, [rip + token0_layer3_post_attn_residual]
	mov rcx, TOKEN0_LAYER3_POST_ATTN_RESIDUAL_VALUES

.Llayer3_post_attn_residual_loop:
	vmovss xmm0, dword ptr [rsi]
	vmovss xmm1, dword ptr [rdx]
	vaddss xmm0, xmm0, xmm1
	vmovss dword ptr [rdi], xmm0
	add rsi, 4
	add rdx, 4
	add rdi, 4
	dec rcx
	jnz .Llayer3_post_attn_residual_loop

	mov eax, 1

.Llayer3_post_attn_residual_done:
	ret

.size token0_layer3_post_attn_residual_smoke, . - token0_layer3_post_attn_residual_smoke

.type print_token0_layer3_post_attn_residual_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-3
# post-attention residual when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer3_post_attn_residual_status
# and the first four f32 words of token0_layer3_post_attn_residual.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer3_post_attn_residual_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads private module-owned layer-3 post-attention
# residual storage only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer3_post_attn_residual_slice:
	cmp qword ptr [rip + token0_layer3_post_attn_residual_status], 1
	jne .Lprint_layer3_post_attn_residual_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer3_post_attn_residual0_f32_text]
	mov rdx, token0_layer3_post_attn_residual0_f32_text_end - token0_layer3_post_attn_residual0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer3_post_attn_residual]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer3_post_attn_residual1_f32_text]
	mov rdx, token0_layer3_post_attn_residual1_f32_text_end - token0_layer3_post_attn_residual1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer3_post_attn_residual + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer3_post_attn_residual2_f32_text]
	mov rdx, token0_layer3_post_attn_residual2_f32_text_end - token0_layer3_post_attn_residual2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer3_post_attn_residual + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer3_post_attn_residual3_f32_text]
	mov rdx, token0_layer3_post_attn_residual3_f32_text_end - token0_layer3_post_attn_residual3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer3_post_attn_residual + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer3_post_attn_residual_slice_done:
	ret

.size print_token0_layer3_post_attn_residual_slice, . - print_token0_layer3_post_attn_residual_slice

.section .note.GNU-stack,"",@progbits
