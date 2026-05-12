.intel_syntax noprefix

.equ GGML_TYPE_Q8_0, 8
.equ TOKEN0_LAYER5_ATTN_NORM_VALUES, 3072
.equ TOKEN0_LAYER5_ATTN_Q_OUTPUT_VALUES, 4096
.equ TOKEN0_LAYER5_ATTN_K_OUTPUT_VALUES, 1024
.equ TOKEN0_LAYER5_ATTN_V_OUTPUT_VALUES, 1024

.section .rodata

token0_layer5_attn_qkv_handoff_text:
	.ascii "token0_layer5_attn_qkv_handoff: "
token0_layer5_attn_qkv_handoff_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

.section .bss

.global token0_layer5_attn_qkv_handoff_status
.balign 8
token0_layer5_attn_qkv_handoff_status:
	.skip 8

.section .text

.global run_token0_layer5_attn_qkv_handoff_status
.type run_token0_layer5_attn_qkv_handoff_status, @function

# Contract: publish the token-0 layer-5 attention Q/K/V projection handoff.
# Inputs: no register inputs. Reads the layer-5 query/key/value matvec status
# words and retained blk.5.attn_q.weight, blk.5.attn_k.weight, and
# blk.5.attn_v.weight descriptor summaries.
# Outputs: writes token0_layer5_attn_qkv_handoff_status. Always prints exactly
# one status label/value/newline sequence to stdout. The return register is
# unspecified.
# Clobbers: caller-saved registers and flags through the smoke helper,
# sys_write, and write_u64_decimal.
# Ownership/lifetime: this module owns only the handoff status. The exported
# token0_layer5_attn_q_output, token0_layer5_attn_k_output, and
# token0_layer5_attn_v_output buffers are owned and filled by the layer-5
# attention projection module, then remain valid static storage until process
# exit. Future context code must require this handoff status before borrowing
# those buffers.
# Error behavior: status is 1 only after the three projection statuses are 1
# and their retained descriptor shapes still match the narrow target GGUF.
# Otherwise status is 0. This handoff does not read projection buffer bytes,
# derive context values, or read blk.5.attn_output.weight payload bytes.
run_token0_layer5_attn_qkv_handoff_status:
	call token0_layer5_attn_qkv_handoff_smoke
	mov qword ptr [rip + token0_layer5_attn_qkv_handoff_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer5_attn_qkv_handoff_text]
	mov rdx, token0_layer5_attn_qkv_handoff_text_end - token0_layer5_attn_qkv_handoff_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer5_attn_qkv_handoff_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size run_token0_layer5_attn_qkv_handoff_status, . - run_token0_layer5_attn_qkv_handoff_status

.type token0_layer5_attn_qkv_handoff_smoke, @function

# Contract: verify that the layer-5 Q/K/V projection outputs are ready to be
# borrowed by a later focused context module.
# Inputs: no register inputs. Reads token0_layer5_attn_q_matvec_status,
# token0_layer5_attn_k_matvec_status, token0_layer5_attn_v_matvec_status, and
# the retained layer-5 Q/K/V tensor descriptor summaries.
# Outputs: rax = 1 when the three projection statuses are complete and the
# query/key/value descriptor shapes prove the expected exported buffer widths;
# otherwise rax = 0. No memory owned by the exported projection buffers is read
# or written.
# Clobbers: rax and flags.
# Ownership/lifetime: observes process-owned status and descriptor summaries
# only. The projection buffers remain owned by the layer-5 attention projection
# module.
# Error behavior: this smoke gate returns status only; missing prerequisites or
# shape mismatches skip with status 0.
token0_layer5_attn_qkv_handoff_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer5_attn_q_matvec_status], 1
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + token0_layer5_attn_k_matvec_status], 1
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + token0_layer5_attn_v_matvec_status], 1
	jne .Llayer5_attn_qkv_handoff_done

	cmp qword ptr [rip + layer5_attn_q_tensor_found], 1
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + layer5_attn_q_tensor_n_dimensions], 2
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + layer5_attn_q_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + layer5_attn_q_tensor_dim0], TOKEN0_LAYER5_ATTN_NORM_VALUES
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + layer5_attn_q_tensor_dim1], TOKEN0_LAYER5_ATTN_Q_OUTPUT_VALUES
	jne .Llayer5_attn_qkv_handoff_done

	cmp qword ptr [rip + layer5_attn_k_tensor_found], 1
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + layer5_attn_k_tensor_n_dimensions], 2
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + layer5_attn_k_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + layer5_attn_k_tensor_dim0], TOKEN0_LAYER5_ATTN_NORM_VALUES
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + layer5_attn_k_tensor_dim1], TOKEN0_LAYER5_ATTN_K_OUTPUT_VALUES
	jne .Llayer5_attn_qkv_handoff_done

	cmp qword ptr [rip + layer5_attn_v_tensor_found], 1
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + layer5_attn_v_tensor_n_dimensions], 2
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + layer5_attn_v_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + layer5_attn_v_tensor_dim0], TOKEN0_LAYER5_ATTN_NORM_VALUES
	jne .Llayer5_attn_qkv_handoff_done
	cmp qword ptr [rip + layer5_attn_v_tensor_dim1], TOKEN0_LAYER5_ATTN_V_OUTPUT_VALUES
	jne .Llayer5_attn_qkv_handoff_done

	mov eax, 1

.Llayer5_attn_qkv_handoff_done:
	ret

.size token0_layer5_attn_qkv_handoff_smoke, . - token0_layer5_attn_qkv_handoff_smoke

.section .note.GNU-stack,"",@progbits
