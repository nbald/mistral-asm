.Llookup_layer3_attn_norm_tensor:
	# Start layer-3 setup with descriptor-only attention RMSNorm coverage. This
	# publishes the tensor-directory fields but does not read f32 payload bytes.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer3_attn_norm_tensor_request]
	mov r9, layer3_attn_norm_tensor_request_end - layer3_attn_norm_tensor_request
	lea r10, [rip + layer3_attn_norm_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer3_attn_q_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer3_attn_q_tensor:
	# Capture the layer-3 query projection descriptor in its own retained slot.
	# This step publishes directory shape metadata only; the Q8_0 matrix payload
	# remains untouched until a later guarded matvec smoke exists.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer3_attn_q_tensor_request]
	mov r9, layer3_attn_q_tensor_request_end - layer3_attn_q_tensor_request
	lea r10, [rip + layer3_attn_q_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer3_attn_k_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer3_attn_k_tensor:
	# Capture the layer-3 key projection descriptor in a retained slot for the
	# next attention step. This descriptor-only smoke publishes directory shape
	# metadata and deliberately leaves Q8_0 key payload bytes untouched.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer3_attn_k_tensor_request]
	mov r9, layer3_attn_k_tensor_request_end - layer3_attn_k_tensor_request
	lea r10, [rip + layer3_attn_k_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer3_attn_v_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer3_attn_v_tensor:
	# Capture the layer-3 value projection descriptor for the next attention
	# step. This publishes directory shape metadata only; the Q8_0 value payload
	# remains untouched until the guarded value matvec smoke succeeds.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer3_attn_v_tensor_request]
	mov r9, layer3_attn_v_tensor_request_end - layer3_attn_v_tensor_request
	lea r10, [rip + layer3_attn_v_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer3_attn_output_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer3_attn_output_tensor:
	# Capture the layer-3 attention output projection descriptor in its own
	# retained slot. This publishes only directory shape metadata; the Q8_0
	# output-projection payload remains unread until a later guarded matvec
	# smoke consumes the layer-3 attention context.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer3_attn_output_tensor_request]
	mov r9, layer3_attn_output_tensor_request_end - layer3_attn_output_tensor_request
	lea r10, [rip + layer3_attn_output_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer3_ffn_norm_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer3_ffn_norm_tensor:
	# Capture the layer-3 FFN RMSNorm descriptor for the next post-attention
	# step. Descriptor publication remains separate from the guarded RMSNorm
	# smoke that proves the f32 payload span before reading weight bytes.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer3_ffn_norm_tensor_request]
	mov r9, layer3_ffn_norm_tensor_request_end - layer3_ffn_norm_tensor_request
	lea r10, [rip + layer3_ffn_norm_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer3_ffn_gate_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer3_ffn_gate_tensor:
	# Capture the layer-3 FFN gate descriptor for the focused projection smoke.
	# Descriptor publication is still separate from the guarded Q8_0 payload
	# read performed after the FFN RMSNorm activation is available.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer3_ffn_gate_tensor_request]
	mov r9, layer3_ffn_gate_tensor_request_end - layer3_ffn_gate_tensor_request
	lea r10, [rip + layer3_ffn_gate_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer3_ffn_up_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer3_ffn_up_tensor:
	# Capture the layer-3 FFN up descriptor for the focused projection smoke.
	# The later matvec gate rechecks shape and proves the complete Q8_0 payload
	# span before reading matrix bytes.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer3_ffn_up_tensor_request]
	mov r9, layer3_ffn_up_tensor_request_end - layer3_ffn_up_tensor_request
	lea r10, [rip + layer3_ffn_up_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer3_ffn_down_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer3_ffn_down_tensor:
	# Capture the layer-3 FFN down descriptor for the focused post-SwiGLU
	# projection smoke. The later matvec gate proves shape and bounds before
	# reading any Q8_0 payload bytes.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer3_ffn_down_tensor_request]
	mov r9, layer3_ffn_down_tensor_request_end - layer3_ffn_down_tensor_request
	lea r10, [rip + layer3_ffn_down_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer4_attn_norm_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error
