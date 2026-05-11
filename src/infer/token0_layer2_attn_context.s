.intel_syntax noprefix

.equ GGML_TYPE_Q8_0, 8
.equ TOKEN0_LAYER2_ATTN_NORM_VALUES, 3072
.equ TOKEN0_LAYER2_ATTN_V_OUTPUT_VALUES, 1024
.equ TOKEN0_LAYER2_ATTN_HEAD_DIM_VALUES, 128
.equ TOKEN0_LAYER2_ATTN_QUERY_HEADS_PER_KV_HEAD, 4
.equ TOKEN0_LAYER2_ATTN_KV_HEADS, TOKEN0_LAYER2_ATTN_V_OUTPUT_VALUES / TOKEN0_LAYER2_ATTN_HEAD_DIM_VALUES
.equ TOKEN0_LAYER2_ATTN_CONTEXT_VALUES, 4096
.equ TOKEN0_LAYER2_ATTN_CONTEXT_BYTES, TOKEN0_LAYER2_ATTN_CONTEXT_VALUES * 4

.section .rodata

token0_layer2_attn_context_text:
	.ascii "token0_layer2_attn_context: "
token0_layer2_attn_context_text_end:

token0_layer2_attn_context0_f32_text:
	.ascii "token0_layer2_attn_context0_f32_hex: "
token0_layer2_attn_context0_f32_text_end:

token0_layer2_attn_context1_f32_text:
	.ascii "token0_layer2_attn_context1_f32_hex: "
token0_layer2_attn_context1_f32_text_end:

token0_layer2_attn_context2_f32_text:
	.ascii "token0_layer2_attn_context2_f32_hex: "
token0_layer2_attn_context2_f32_text_end:

token0_layer2_attn_context3_f32_text:
	.ascii "token0_layer2_attn_context3_f32_hex: "
token0_layer2_attn_context3_f32_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

.section .bss

.global token0_layer2_attn_context_status
.balign 8
token0_layer2_attn_context_status:
	.skip 8

.global token0_layer2_attn_context
.balign 4
token0_layer2_attn_context:
	.skip TOKEN0_LAYER2_ATTN_CONTEXT_BYTES

.section .text

.global run_token0_layer2_attn_context_status
.type run_token0_layer2_attn_context_status, @function

# Contract: run the token-0 layer-2 single-token attention context smoke and
# publish its status line.
# Inputs: no register inputs. Reads token0_layer2_attn_v_matvec_status,
# token0_layer2_attn_v_output, and the retained blk.2.attn_v.weight and
# blk.2.attn_output.weight descriptors.
# Outputs: writes token0_layer2_attn_context_status and, on success, fills the
# private token0_layer2_attn_context buffer. Always prints exactly one status
# label/value/newline sequence to stdout and prints the first four exact-hex
# context words only when the status is 1. The return register is unspecified.
# Clobbers: caller-saved registers and flags through the smoke helper and
# summary writers.
# Ownership/lifetime: borrows the layer-2 value projection output owned by the
# layer-2 attention module only for this call and owns the context storage for
# later layer-2 output-projection work. Descriptor slots remain process-owned
# static parser summaries. This function does not read model payload bytes.
# Error behavior: status is 1 only after all prerequisite statuses and tensor
# shapes match the narrow target GGUF. Otherwise status is 0 and no context
# exact-hex words are printed. Output write failures are diagnostic-only in the
# current milestone.
run_token0_layer2_attn_context_status:
	call token0_layer2_attn_context_smoke
	mov qword ptr [rip + token0_layer2_attn_context_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer2_attn_context_text]
	mov rdx, token0_layer2_attn_context_text_end - token0_layer2_attn_context_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer2_attn_context_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer2_attn_context_slice
	ret

.size run_token0_layer2_attn_context_status, . - run_token0_layer2_attn_context_status

.type token0_layer2_attn_context_smoke, @function

# Contract: derive the token-0 layer-2 single-token attention context from the
# retained layer-2 value projection output.
# Inputs: no register inputs. Reads token0_layer2_attn_v_matvec_status,
# token0_layer2_attn_v_output, and the retained layer-2 value and output
# projection tensor descriptors.
# Outputs: rax = 1 after writing a 4096-f32 token0_layer2_attn_context by
# repeating each 128-f32 KV-head value block four times for the associated query
# heads; otherwise rax = 0 and no context bytes are written.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: reads only process-owned static layer-2 value-output
# storage and writes only process-owned static layer-2 context storage. The
# blk.2.attn_output.weight descriptor is used as a shape guard, but this
# function does not read any output-projection payload bytes.
# Error behavior: this smoke gate returns status only; invalid inputs and shape
# mismatches are skipped with status 0.
token0_layer2_attn_context_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer2_attn_v_matvec_status], 1
	jne .Llayer2_attn_context_done
	cmp qword ptr [rip + layer2_attn_v_tensor_found], 1
	jne .Llayer2_attn_context_done
	cmp qword ptr [rip + layer2_attn_v_tensor_n_dimensions], 2
	jne .Llayer2_attn_context_done
	cmp qword ptr [rip + layer2_attn_v_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer2_attn_context_done
	cmp qword ptr [rip + layer2_attn_v_tensor_dim0], TOKEN0_LAYER2_ATTN_NORM_VALUES
	jne .Llayer2_attn_context_done
	cmp qword ptr [rip + layer2_attn_v_tensor_dim1], TOKEN0_LAYER2_ATTN_V_OUTPUT_VALUES
	jne .Llayer2_attn_context_done
	cmp qword ptr [rip + layer2_attn_output_tensor_found], 1
	jne .Llayer2_attn_context_done
	cmp qword ptr [rip + layer2_attn_output_tensor_n_dimensions], 2
	jne .Llayer2_attn_context_done
	cmp qword ptr [rip + layer2_attn_output_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer2_attn_context_done
	cmp qword ptr [rip + layer2_attn_output_tensor_dim0], TOKEN0_LAYER2_ATTN_CONTEXT_VALUES
	jne .Llayer2_attn_context_done
	cmp qword ptr [rip + layer2_attn_output_tensor_dim1], TOKEN0_LAYER2_ATTN_NORM_VALUES
	jne .Llayer2_attn_context_done

	# With a one-token layer-local sequence, every query head attends to a single
	# key/value entry. Softmax is exactly 1, so grouped-query context expansion
	# is a pure copy from each KV head into its four query heads.
	lea rsi, [rip + token0_layer2_attn_v_output]
	lea rdi, [rip + token0_layer2_attn_context]
	mov r8, TOKEN0_LAYER2_ATTN_KV_HEADS

.Llayer2_attn_context_kv_head_loop:
	mov r9, TOKEN0_LAYER2_ATTN_QUERY_HEADS_PER_KV_HEAD

.Llayer2_attn_context_repeat_loop:
	mov rcx, TOKEN0_LAYER2_ATTN_HEAD_DIM_VALUES
	mov r10, rsi

.Llayer2_attn_context_copy_loop:
	mov eax, dword ptr [r10]
	mov dword ptr [rdi], eax
	add r10, 4
	add rdi, 4
	dec rcx
	jnz .Llayer2_attn_context_copy_loop

	dec r9
	jnz .Llayer2_attn_context_repeat_loop

	add rsi, TOKEN0_LAYER2_ATTN_HEAD_DIM_VALUES * 4
	dec r8
	jnz .Llayer2_attn_context_kv_head_loop

	mov eax, 1

.Llayer2_attn_context_done:
	ret

.size token0_layer2_attn_context_smoke, . - token0_layer2_attn_context_smoke

.type print_token0_layer2_attn_context_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-2 attention
# context when the context smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer2_attn_context_status and the
# first four f32 words of token0_layer2_attn_context.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer2_attn_context_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads private module-owned layer-2 context storage only
# during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer2_attn_context_slice:
	cmp qword ptr [rip + token0_layer2_attn_context_status], 1
	jne .Lprint_layer2_attn_context_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer2_attn_context0_f32_text]
	mov rdx, token0_layer2_attn_context0_f32_text_end - token0_layer2_attn_context0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_attn_context]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer2_attn_context1_f32_text]
	mov rdx, token0_layer2_attn_context1_f32_text_end - token0_layer2_attn_context1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_attn_context + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer2_attn_context2_f32_text]
	mov rdx, token0_layer2_attn_context2_f32_text_end - token0_layer2_attn_context2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_attn_context + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer2_attn_context3_f32_text]
	mov rdx, token0_layer2_attn_context3_f32_text_end - token0_layer2_attn_context3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_attn_context + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer2_attn_context_slice_done:
	ret

.size print_token0_layer2_attn_context_slice, . - print_token0_layer2_attn_context_slice

.section .note.GNU-stack,"",@progbits
