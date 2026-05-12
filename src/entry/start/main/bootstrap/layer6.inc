.Llookup_layer6_attn_norm_tensor:
	# Start layer-6 attention coverage with descriptor publication first. The
	# RMSNorm smoke later consumes the layer-5 post-FFN residual handoff, then
	# proves this f32 payload span before reading weight bytes.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer6_attn_norm_tensor_request]
	mov r9, layer6_attn_norm_tensor_request_end - layer6_attn_norm_tensor_request
	lea r10, [rip + layer6_attn_norm_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer6_attn_q_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer6_attn_q_tensor:
	# Retain the layer-6 query projection descriptor after the RMSNorm
	# descriptor. Runtime summary still publishes only shape, type, and relative
	# offset metadata; the guarded matvec smoke below reads payload bytes only
	# after the private layer-6 attention-normalized activation exists.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer6_attn_q_tensor_request]
	mov r9, layer6_attn_q_tensor_request_end - layer6_attn_q_tensor_request
	lea r10, [rip + layer6_attn_q_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Lsummary_print
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error
