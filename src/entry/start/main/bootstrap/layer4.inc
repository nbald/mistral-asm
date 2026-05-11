.Llookup_layer4_attn_norm_tensor:
	# Begin layer-4 setup with descriptor-only attention RMSNorm coverage. This
	# step publishes the tensor-directory fields for the next layer and leaves
	# f32 payload bytes unread until a guarded RMSNorm smoke is added.
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
	jz .Lsummary_print
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error
