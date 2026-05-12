.intel_syntax noprefix

.equ GGML_TYPE_Q8_0, 8
.equ TOKEN0_LAYER5_ATTN_NORM_VALUES, 3072
.equ TOKEN0_LAYER5_ATTN_Q_OUTPUT_VALUES, 4096
.equ TOKEN0_LAYER5_ATTN_K_OUTPUT_VALUES, 1024
.equ TOKEN0_LAYER5_ATTN_V_OUTPUT_VALUES, 1024
.equ TOKEN0_LAYER5_ATTN_HEAD_DIM_VALUES, 128
.equ TOKEN0_LAYER5_ATTN_QUERY_HEADS_PER_KV_HEAD, 4
.equ TOKEN0_LAYER5_ATTN_KV_HEADS, TOKEN0_LAYER5_ATTN_V_OUTPUT_VALUES / TOKEN0_LAYER5_ATTN_HEAD_DIM_VALUES
.equ TOKEN0_LAYER5_ATTN_CONTEXT_VALUES, 4096
.equ TOKEN0_LAYER5_ATTN_CONTEXT_BYTES, TOKEN0_LAYER5_ATTN_CONTEXT_VALUES * 4

.section .rodata

token0_layer5_attn_context_text:
	.ascii "token0_layer5_attn_context: "
token0_layer5_attn_context_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

.section .bss

.global token0_layer5_attn_context_status
.balign 8
token0_layer5_attn_context_status:
	.skip 8

.global token0_layer5_attn_context
.balign 4
token0_layer5_attn_context:
	.skip TOKEN0_LAYER5_ATTN_CONTEXT_BYTES

.section .text

.global run_token0_layer5_attn_context_status
.type run_token0_layer5_attn_context_status, @function

# Contract: run the token-0 layer-5 single-token attention context smoke and
# publish its status line without adding public exact-hex context labels.
# Inputs: no register inputs. Reads token0_layer5_attn_qkv_handoff_status,
# token0_layer5_attn_v_output, and retained blk.5 attention query, key, value,
# and output-projection tensor descriptors.
# Outputs: writes token0_layer5_attn_context_status and, on success, fills the
# exported token0_layer5_attn_context buffer. Always prints exactly one status
# label/value/newline sequence to stdout. The return register is unspecified.
# Clobbers: caller-saved registers and flags through the smoke helper,
# sys_write, and write_u64_decimal.
# Ownership/lifetime: borrows the layer-5 value projection output only after
# the explicit Q/K/V handoff status is 1, then owns the static context buffer
# for future layer-5 output-projection work. Descriptor slots remain
# process-owned parser summaries. This function reads no model payload bytes.
# Error behavior: status is 1 only after the handoff is complete and retained
# tensor shapes match the narrow target GGUF. Otherwise status is 0 and no
# context bytes are written. Output write failures are diagnostic-only in the
# current milestone.
run_token0_layer5_attn_context_status:
	call token0_layer5_attn_context_smoke
	mov qword ptr [rip + token0_layer5_attn_context_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer5_attn_context_text]
	mov rdx, token0_layer5_attn_context_text_end - token0_layer5_attn_context_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer5_attn_context_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size run_token0_layer5_attn_context_status, . - run_token0_layer5_attn_context_status

.type token0_layer5_attn_context_smoke, @function

# Contract: derive the token-0 layer-5 single-token attention context from the
# exported layer-5 value projection output.
# Inputs: no register inputs. Reads token0_layer5_attn_qkv_handoff_status,
# token0_layer5_attn_v_output, and retained layer-5 query, key, value, and
# output projection tensor descriptors.
# Outputs: rax = 1 after writing a 4096-f32 token0_layer5_attn_context by
# repeating each 128-f32 KV-head value block four times for the associated query
# heads; otherwise rax = 0 and no context bytes are written.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: reads only process-owned static layer-5 value-output
# storage and writes only process-owned static layer-5 context storage. The
# query and key descriptors are shape guards for the completed handoff, the
# value descriptor proves the borrowed buffer width, and the output-projection
# descriptor is only a shape guard for the eventual consumer. This function
# does not read any output-projection payload bytes.
# Error behavior: this smoke gate returns status only; invalid inputs and shape
# mismatches are skipped with status 0.
token0_layer5_attn_context_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer5_attn_qkv_handoff_status], 1
	jne .Llayer5_attn_context_done

	cmp qword ptr [rip + layer5_attn_q_tensor_found], 1
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_q_tensor_n_dimensions], 2
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_q_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_q_tensor_dim0], TOKEN0_LAYER5_ATTN_NORM_VALUES
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_q_tensor_dim1], TOKEN0_LAYER5_ATTN_Q_OUTPUT_VALUES
	jne .Llayer5_attn_context_done

	cmp qword ptr [rip + layer5_attn_k_tensor_found], 1
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_k_tensor_n_dimensions], 2
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_k_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_k_tensor_dim0], TOKEN0_LAYER5_ATTN_NORM_VALUES
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_k_tensor_dim1], TOKEN0_LAYER5_ATTN_K_OUTPUT_VALUES
	jne .Llayer5_attn_context_done

	cmp qword ptr [rip + layer5_attn_v_tensor_found], 1
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_v_tensor_n_dimensions], 2
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_v_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_v_tensor_dim0], TOKEN0_LAYER5_ATTN_NORM_VALUES
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_v_tensor_dim1], TOKEN0_LAYER5_ATTN_V_OUTPUT_VALUES
	jne .Llayer5_attn_context_done

	cmp qword ptr [rip + layer5_attn_output_tensor_found], 1
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_output_tensor_n_dimensions], 2
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_output_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_output_tensor_dim0], TOKEN0_LAYER5_ATTN_CONTEXT_VALUES
	jne .Llayer5_attn_context_done
	cmp qword ptr [rip + layer5_attn_output_tensor_dim1], TOKEN0_LAYER5_ATTN_NORM_VALUES
	jne .Llayer5_attn_context_done

	# With one token in the layer-local sequence, each query head attends to the
	# single key/value entry for its KV group. Softmax is exactly 1, so the
	# context is the value head copied into each of its four query heads.
	lea rsi, [rip + token0_layer5_attn_v_output]
	lea rdi, [rip + token0_layer5_attn_context]
	mov r8, TOKEN0_LAYER5_ATTN_KV_HEADS

.Llayer5_attn_context_kv_head_loop:
	mov r9, TOKEN0_LAYER5_ATTN_QUERY_HEADS_PER_KV_HEAD

.Llayer5_attn_context_repeat_loop:
	mov rcx, TOKEN0_LAYER5_ATTN_HEAD_DIM_VALUES
	mov r10, rsi

.Llayer5_attn_context_copy_loop:
	mov eax, dword ptr [r10]
	mov dword ptr [rdi], eax
	add r10, 4
	add rdi, 4
	dec rcx
	jnz .Llayer5_attn_context_copy_loop

	dec r9
	jnz .Llayer5_attn_context_repeat_loop

	add rsi, TOKEN0_LAYER5_ATTN_HEAD_DIM_VALUES * 4
	dec r8
	jnz .Llayer5_attn_context_kv_head_loop

	mov eax, 1

.Llayer5_attn_context_done:
	ret

.size token0_layer5_attn_context_smoke, . - token0_layer5_attn_context_smoke

.section .note.GNU-stack,"",@progbits
