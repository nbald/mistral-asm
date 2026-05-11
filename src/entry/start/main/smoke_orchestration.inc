	call dequant_token0_embedding_smoke
	mov qword ptr [rip + token0_embedding_dequant_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_embedding_dequant_text]
	mov rdx, token0_embedding_dequant_text_end - token0_embedding_dequant_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_embedding_dequant_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call token0_attn_norm_smoke
	mov qword ptr [rip + token0_attn_norm_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_attn_norm_text]
	mov rdx, token0_attn_norm_text_end - token0_attn_norm_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_attn_norm_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call token0_attn_q_matvec_smoke
	mov qword ptr [rip + token0_attn_q_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_attn_q_matvec_text]
	mov rdx, token0_attn_q_matvec_text_end - token0_attn_q_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_attn_q_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_attn_q_output_slice

	call token0_attn_k_matvec_smoke
	mov qword ptr [rip + token0_attn_k_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_attn_k_matvec_text]
	mov rdx, token0_attn_k_matvec_text_end - token0_attn_k_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_attn_k_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_attn_k_output_slice

	call token0_attn_v_matvec_smoke
	mov qword ptr [rip + token0_attn_v_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_attn_v_matvec_text]
	mov rdx, token0_attn_v_matvec_text_end - token0_attn_v_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_attn_v_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_attn_v_output_slice

	call token0_attn_context_smoke
	mov qword ptr [rip + token0_attn_context_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_attn_context_text]
	mov rdx, token0_attn_context_text_end - token0_attn_context_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_attn_context_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_attn_context_slice

	call token0_attn_output_matvec_smoke
	mov qword ptr [rip + token0_attn_output_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_attn_output_matvec_text]
	mov rdx, token0_attn_output_matvec_text_end - token0_attn_output_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_attn_output_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_attn_output_slice

	call token0_post_attn_residual_smoke
	mov qword ptr [rip + token0_post_attn_residual_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_post_attn_residual_text]
	mov rdx, token0_post_attn_residual_text_end - token0_post_attn_residual_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_post_attn_residual_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_post_attn_residual_slice

	call token0_ffn_norm_smoke
	mov qword ptr [rip + token0_ffn_norm_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_ffn_norm_text]
	mov rdx, token0_ffn_norm_text_end - token0_ffn_norm_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_ffn_norm_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_ffn_norm_slice

	call token0_ffn_gate_matvec_smoke
	mov qword ptr [rip + token0_ffn_gate_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_ffn_gate_matvec_text]
	mov rdx, token0_ffn_gate_matvec_text_end - token0_ffn_gate_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_ffn_gate_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_ffn_gate_output_slice

	call token0_ffn_up_matvec_smoke
	mov qword ptr [rip + token0_ffn_up_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_ffn_up_matvec_text]
	mov rdx, token0_ffn_up_matvec_text_end - token0_ffn_up_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_ffn_up_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_ffn_up_output_slice

	call token0_ffn_swiglu_smoke
	mov qword ptr [rip + token0_ffn_swiglu_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_ffn_swiglu_text]
	mov rdx, token0_ffn_swiglu_text_end - token0_ffn_swiglu_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_ffn_swiglu_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_ffn_swiglu_output_slice

	call token0_ffn_down_matvec_smoke
	mov qword ptr [rip + token0_ffn_down_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_ffn_down_matvec_text]
	mov rdx, token0_ffn_down_matvec_text_end - token0_ffn_down_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_ffn_down_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_ffn_down_output_slice

	call token0_post_ffn_residual_smoke
	mov qword ptr [rip + token0_post_ffn_residual_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_post_ffn_residual_text]
	mov rdx, token0_post_ffn_residual_text_end - token0_post_ffn_residual_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_post_ffn_residual_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_post_ffn_residual_slice

	call token0_layer1_attn_norm_smoke
	mov qword ptr [rip + token0_layer1_attn_norm_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_norm_text]
	mov rdx, token0_layer1_attn_norm_text_end - token0_layer1_attn_norm_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_attn_norm_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_attn_norm_slice

	call token0_layer1_attn_q_matvec_smoke
	mov qword ptr [rip + token0_layer1_attn_q_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_q_matvec_text]
	mov rdx, token0_layer1_attn_q_matvec_text_end - token0_layer1_attn_q_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_attn_q_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_attn_q_output_slice

	call token0_layer1_attn_k_matvec_smoke
	mov qword ptr [rip + token0_layer1_attn_k_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_k_matvec_text]
	mov rdx, token0_layer1_attn_k_matvec_text_end - token0_layer1_attn_k_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_attn_k_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_attn_k_output_slice

	call token0_layer1_attn_v_matvec_smoke
	mov qword ptr [rip + token0_layer1_attn_v_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_v_matvec_text]
	mov rdx, token0_layer1_attn_v_matvec_text_end - token0_layer1_attn_v_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_attn_v_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_attn_v_output_slice

	call token0_layer1_attn_context_smoke
	mov qword ptr [rip + token0_layer1_attn_context_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_context_text]
	mov rdx, token0_layer1_attn_context_text_end - token0_layer1_attn_context_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_attn_context_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_attn_context_slice

	call token0_layer1_attn_output_matvec_smoke
	mov qword ptr [rip + token0_layer1_attn_output_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_output_matvec_text]
	mov rdx, token0_layer1_attn_output_matvec_text_end - token0_layer1_attn_output_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_attn_output_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_attn_output_slice

	call token0_layer1_post_attn_residual_smoke
	mov qword ptr [rip + token0_layer1_post_attn_residual_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_post_attn_residual_text]
	mov rdx, token0_layer1_post_attn_residual_text_end - token0_layer1_post_attn_residual_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_post_attn_residual_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_post_attn_residual_slice

	call run_token0_layer1_ffn_norm_status

	call run_token0_layer1_ffn_gate_matvec_status
	call run_token0_layer1_ffn_up_matvec_status
	call run_token0_layer1_ffn_swiglu_status
	call run_token0_layer1_ffn_down_matvec_status

	# The live mapping has now served parser summary and guarded tensor payload
	# smoke paths. Ownership remains explicit and is released before exit.
	lea rdi, [rip + gguf_mapping]
	call gguf_release_mapping
	test rax, rax
	jz .Lsummary_exit_ok

	lea rsi, [rip + gguf_munmap_error_text]
	mov rdx, gguf_munmap_error_text_end - gguf_munmap_error_text
	jmp .Lwrite_model_error
