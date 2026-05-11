.intel_syntax noprefix

.equ GGML_TYPE_Q8_0, 8
.equ TOKEN0_LAYER3_ATTN_NORM_VALUES, 3072
.equ TOKEN0_LAYER3_ATTN_Q_OUTPUT_VALUES, 4096
.equ TOKEN0_LAYER3_ATTN_K_OUTPUT_VALUES, 1024
.equ TOKEN0_LAYER3_ATTN_V_OUTPUT_VALUES, 1024
.equ TOKEN0_LAYER3_ATTN_HEAD_DIM_VALUES, 128
.equ TOKEN0_LAYER3_ATTN_QUERY_HEADS_PER_KV_HEAD, 4
.equ TOKEN0_LAYER3_ATTN_KV_HEADS, TOKEN0_LAYER3_ATTN_V_OUTPUT_VALUES / TOKEN0_LAYER3_ATTN_HEAD_DIM_VALUES
.equ TOKEN0_LAYER3_ATTN_CONTEXT_VALUES, TOKEN0_LAYER3_ATTN_Q_OUTPUT_VALUES
.equ TOKEN0_LAYER3_ATTN_CONTEXT_BYTES, TOKEN0_LAYER3_ATTN_CONTEXT_VALUES * 4

.section .rodata

token0_layer3_attn_context_text:
	.ascii "token0_layer3_attn_context: "
token0_layer3_attn_context_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

.section .bss

.global token0_layer3_attn_context_status
.balign 8
token0_layer3_attn_context_status:
	.skip 8

.global token0_layer3_attn_context
.balign 4
token0_layer3_attn_context:
	.skip TOKEN0_LAYER3_ATTN_CONTEXT_BYTES

.section .text

.global run_token0_layer3_attn_context_status
.type run_token0_layer3_attn_context_status, @function

# Contract: run the token-0 layer-3 single-token attention context smoke and
# publish its status line only.
# Inputs: no register inputs. Reads token0_layer3_attn_q_matvec_status,
# token0_layer3_attn_k_matvec_status, token0_layer3_attn_v_matvec_status,
# token0_layer3_attn_v_output, and the retained blk.3.attn_q.weight,
# blk.3.attn_k.weight, blk.3.attn_v.weight, and blk.3.attn_output.weight
# descriptors.
# Outputs: writes token0_layer3_attn_context_status and, on success, fills the
# private token0_layer3_attn_context buffer. Always prints exactly one status
# label/value/newline sequence to stdout and prints no context exact-hex words.
# The return register is unspecified.
# Clobbers: caller-saved registers and flags through the smoke helper and
# summary writers.
# Ownership/lifetime: borrows the layer-3 value projection output owned by the
# layer-3 attention module only for this call and owns the context storage for
# later layer-3 output-projection work. Descriptor slots remain process-owned
# static parser summaries. This function does not read model payload bytes.
# Error behavior: status is 1 only after all prerequisite statuses and tensor
# shapes match the narrow target GGUF. Otherwise status is 0. Output write
# failures are diagnostic-only in the current milestone.
run_token0_layer3_attn_context_status:
	call token0_layer3_attn_context_smoke
	mov qword ptr [rip + token0_layer3_attn_context_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer3_attn_context_text]
	mov rdx, token0_layer3_attn_context_text_end - token0_layer3_attn_context_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer3_attn_context_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write
	ret

.size run_token0_layer3_attn_context_status, . - run_token0_layer3_attn_context_status

.type token0_layer3_attn_context_smoke, @function

# Contract: derive the token-0 layer-3 single-token attention context from the
# retained layer-3 value projection output.
# Inputs: no register inputs. Reads the layer-3 query/key/value matvec
# statuses, token0_layer3_attn_v_output, and retained layer-3 query, key, value,
# and output projection tensor descriptors.
# Outputs: rax = 1 after writing a 4096-f32 token0_layer3_attn_context by
# repeating each 128-f32 KV-head value block four times for the associated query
# heads; otherwise rax = 0 and no context bytes are written.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: reads only process-owned static layer-3 value-output
# storage and writes only process-owned static layer-3 context storage. The
# query/key descriptors prove the prerequisite output shapes, while the
# blk.3.attn_output.weight descriptor is used as a shape guard for the eventual
# consumer. This function does not read any output-projection payload bytes.
# Error behavior: this smoke gate returns status only; invalid inputs and shape
# mismatches are skipped with status 0.
token0_layer3_attn_context_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer3_attn_q_matvec_status], 1
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + token0_layer3_attn_k_matvec_status], 1
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + token0_layer3_attn_v_matvec_status], 1
	jne .Llayer3_attn_context_done

	cmp qword ptr [rip + layer3_attn_q_tensor_found], 1
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_q_tensor_n_dimensions], 2
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_q_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_q_tensor_dim0], TOKEN0_LAYER3_ATTN_NORM_VALUES
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_q_tensor_dim1], TOKEN0_LAYER3_ATTN_Q_OUTPUT_VALUES
	jne .Llayer3_attn_context_done

	cmp qword ptr [rip + layer3_attn_k_tensor_found], 1
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_k_tensor_n_dimensions], 2
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_k_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_k_tensor_dim0], TOKEN0_LAYER3_ATTN_NORM_VALUES
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_k_tensor_dim1], TOKEN0_LAYER3_ATTN_K_OUTPUT_VALUES
	jne .Llayer3_attn_context_done

	cmp qword ptr [rip + layer3_attn_v_tensor_found], 1
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_v_tensor_n_dimensions], 2
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_v_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_v_tensor_dim0], TOKEN0_LAYER3_ATTN_NORM_VALUES
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_v_tensor_dim1], TOKEN0_LAYER3_ATTN_V_OUTPUT_VALUES
	jne .Llayer3_attn_context_done

	cmp qword ptr [rip + layer3_attn_output_tensor_found], 1
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_output_tensor_n_dimensions], 2
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_output_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_output_tensor_dim0], TOKEN0_LAYER3_ATTN_CONTEXT_VALUES
	jne .Llayer3_attn_context_done
	cmp qword ptr [rip + layer3_attn_output_tensor_dim1], TOKEN0_LAYER3_ATTN_NORM_VALUES
	jne .Llayer3_attn_context_done

	# With a one-token layer-local sequence, every query head attends to a single
	# key/value entry. Softmax is exactly 1, so grouped-query context expansion
	# is a pure copy from each KV head into its four query heads.
	lea rsi, [rip + token0_layer3_attn_v_output]
	lea rdi, [rip + token0_layer3_attn_context]
	mov r8, TOKEN0_LAYER3_ATTN_KV_HEADS

.Llayer3_attn_context_kv_head_loop:
	mov r9, TOKEN0_LAYER3_ATTN_QUERY_HEADS_PER_KV_HEAD

.Llayer3_attn_context_repeat_loop:
	mov rcx, TOKEN0_LAYER3_ATTN_HEAD_DIM_VALUES
	mov r10, rsi

.Llayer3_attn_context_copy_loop:
	mov eax, dword ptr [r10]
	mov dword ptr [rdi], eax
	add r10, 4
	add rdi, 4
	dec rcx
	jnz .Llayer3_attn_context_copy_loop

	dec r9
	jnz .Llayer3_attn_context_repeat_loop

	add rsi, TOKEN0_LAYER3_ATTN_HEAD_DIM_VALUES * 4
	dec r8
	jnz .Llayer3_attn_context_kv_head_loop

	mov eax, 1

.Llayer3_attn_context_done:
	ret

.size token0_layer3_attn_context_smoke, . - token0_layer3_attn_context_smoke

.section .note.GNU-stack,"",@progbits
