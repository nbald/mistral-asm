.Llookup_layer4_attn_norm_tensor:
	# Begin layer-4 setup with the attention RMSNorm descriptor before the query
	# descriptor. The RMSNorm payload is consumed only later by its guarded
	# smoke; this bootstrap step itself still retains directory metadata only.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer4_attn_norm_tensor_request]
	mov r9, layer4_attn_norm_tensor_request_end - layer4_attn_norm_tensor_request
	lea r10, [rip + layer4_attn_norm_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer4_attn_q_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer4_attn_q_tensor:
	# Capture the layer-4 query projection descriptor in its own retained slot.
	# This publishes tensor-directory shape metadata only; Q8_0 payload bytes
	# remain unread until a later guarded matvec smoke consumes the layer-4
	# attention RMSNorm activation.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer4_attn_q_tensor_request]
	mov r9, layer4_attn_q_tensor_request_end - layer4_attn_q_tensor_request
	lea r10, [rip + layer4_attn_q_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer4_attn_k_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer4_attn_k_tensor:
	# Retain the layer-4 key projection descriptor after the query descriptor.
	# This step keeps the same descriptor-only boundary: it publishes shape,
	# type, and relative offset metadata without reading Q8_0 payload bytes.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer4_attn_k_tensor_request]
	mov r9, layer4_attn_k_tensor_request_end - layer4_attn_k_tensor_request
	lea r10, [rip + layer4_attn_k_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer4_attn_v_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer4_attn_v_tensor:
	# Retain the layer-4 value projection descriptor after key. This publishes
	# shape, type, and relative offset metadata only; the Q8_0 payload remains
	# unread until a later guarded value matvec smoke proves the full span.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer4_attn_v_tensor_request]
	mov r9, layer4_attn_v_tensor_request_end - layer4_attn_v_tensor_request
	lea r10, [rip + layer4_attn_v_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Lsummary_print
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error
