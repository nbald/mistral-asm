.Llookup_layer5_attn_norm_tensor:
	# Start layer-5 attention coverage with descriptor publication only. The
	# eventual RMSNorm smoke must first export and consume the layer-4 post-FFN
	# residual handoff, then prove this f32 payload span before reading weights.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer5_attn_norm_tensor_request]
	mov r9, layer5_attn_norm_tensor_request_end - layer5_attn_norm_tensor_request
	lea r10, [rip + layer5_attn_norm_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer5_attn_q_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer5_attn_q_tensor:
	# Retain the layer-5 query projection descriptor after the RMSNorm
	# descriptor. This descriptor-only step publishes shape, type, and relative
	# offset metadata; the Q8_0 payload remains unread until a later guarded
	# query matvec consumes the layer-5 attention-normalized activation.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer5_attn_q_tensor_request]
	mov r9, layer5_attn_q_tensor_request_end - layer5_attn_q_tensor_request
	lea r10, [rip + layer5_attn_q_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer5_attn_k_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer5_attn_k_tensor:
	# Retain the layer-5 key projection descriptor after query. This lookup
	# publishes shape, type, and relative offset metadata without reading Q8_0
	# payload bytes; the guarded key matvec proves the full span before it
	# consumes the descriptor.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer5_attn_k_tensor_request]
	mov r9, layer5_attn_k_tensor_request_end - layer5_attn_k_tensor_request
	lea r10, [rip + layer5_attn_k_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer5_attn_v_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer5_attn_v_tensor:
	# Retain the layer-5 value projection descriptor after key. This remains
	# descriptor-only: it publishes shape, type, and relative offset metadata,
	# and the later value matvec must independently prove the Q8_0 payload span
	# before reading any matrix bytes.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer5_attn_v_tensor_request]
	mov r9, layer5_attn_v_tensor_request_end - layer5_attn_v_tensor_request
	lea r10, [rip + layer5_attn_v_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer5_attn_output_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer5_attn_output_tensor:
	# Capture the layer-5 attention output projection descriptor after value.
	# This descriptor-only step publishes shape, type, and relative offset
	# metadata; the Q8_0 payload stays unread until later context/output-projection
	# work proves the full matrix span before consuming it.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer5_attn_output_tensor_request]
	mov r9, layer5_attn_output_tensor_request_end - layer5_attn_output_tensor_request
	lea r10, [rip + layer5_attn_output_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer5_ffn_norm_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer5_ffn_norm_tensor:
	# Capture the layer-5 FFN RMSNorm descriptor for later use after the
	# post-attention residual handoff exists. This is deliberately
	# descriptor-only: later FFN RMSNorm work must first consume
	# token0_layer5_post_attn_residual through an explicit status guard and
	# prove this f32 payload span before reading weight bytes.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer5_ffn_norm_tensor_request]
	mov r9, layer5_ffn_norm_tensor_request_end - layer5_ffn_norm_tensor_request
	lea r10, [rip + layer5_ffn_norm_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer5_ffn_gate_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer5_ffn_gate_tensor:
	# Retain the layer-5 FFN gate descriptor after the FFN RMSNorm descriptor.
	# This publishes shape, type, and relative offset metadata only; a later
	# guarded gate matvec must prove the Q8_0 payload span before reading any
	# matrix bytes.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer5_ffn_gate_tensor_request]
	mov r9, layer5_ffn_gate_tensor_request_end - layer5_ffn_gate_tensor_request
	lea r10, [rip + layer5_ffn_gate_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer5_ffn_up_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer5_ffn_up_tensor:
	# Retain the layer-5 FFN up descriptor after the gate descriptor. This step
	# deliberately publishes only shape, type, and relative offset metadata; no
	# up payload bytes are read and no up matvec status is emitted yet.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer5_ffn_up_tensor_request]
	mov r9, layer5_ffn_up_tensor_request_end - layer5_ffn_up_tensor_request
	lea r10, [rip + layer5_ffn_up_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer5_ffn_down_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer5_ffn_down_tensor:
	# Retain the layer-5 FFN down descriptor after the up descriptor. This is
	# descriptor-only: it prints shape, type, and relative offset metadata, and
	# leaves the Q8_0 payload untouched until a later guarded post-SwiGLU matvec
	# rechecks the descriptor and proves the mapped span.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer5_ffn_down_tensor_request]
	mov r9, layer5_ffn_down_tensor_request_end - layer5_ffn_down_tensor_request
	lea r10, [rip + layer5_ffn_down_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer6_attn_norm_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error
