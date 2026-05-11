
.Lsummary_print:
	# This milestone validates the fixed GGUF header, metadata shapes, and
	# tensor-info directory bounds, then exposes header counts, selected metadata,
	# the aligned tensor-data base, and retained tensor descriptors in
	# caller-owned storage.
	mov rdi, 1
	lea rsi, [rip + gguf_ok_text]
	mov rdx, gguf_ok_text_end - gguf_ok_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + tensor_count_text]
	mov rdx, tensor_count_text_end - tensor_count_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_tensor_count]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + metadata_count_text]
	mov rdx, metadata_count_text_end - metadata_count_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_metadata_count]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + architecture_text]
	mov rdx, architecture_text_end - architecture_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_architecture]
	mov rdx, GGUF_SUMMARY_ARCHITECTURE_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + context_length_text]
	mov rdx, context_length_text_end - context_length_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_context_length]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + block_count_text]
	mov rdx, block_count_text_end - block_count_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_block_count]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + vocab_size_text]
	mov rdx, vocab_size_text_end - vocab_size_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_vocab_size]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_rms_epsilon_found_text]
	mov rdx, attn_norm_rms_epsilon_found_text_end - attn_norm_rms_epsilon_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_rms_epsilon_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_rms_epsilon_f32_text]
	mov rdx, attn_norm_rms_epsilon_f32_text_end - attn_norm_rms_epsilon_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + gguf_summary_attn_norm_rms_epsilon_f32]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + tensor_infos_offset_text]
	mov rdx, tensor_infos_offset_text_end - tensor_infos_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_tensor_infos_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + tensor_data_offset_text]
	mov rdx, tensor_data_offset_text_end - tensor_data_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_tensor_data_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_layer1_attn_norm_lookup_summary
	call print_layer1_attn_q_lookup_summary
	call print_layer1_attn_k_lookup_summary
	call print_layer1_attn_v_lookup_summary
	call print_layer1_attn_output_lookup_summary
	call print_layer1_ffn_norm_lookup_summary
	call print_layer1_ffn_gate_lookup_summary
	call print_layer1_ffn_up_lookup_summary
	call print_layer1_ffn_down_lookup_summary
	call print_layer2_attn_norm_lookup_summary
	call print_layer2_attn_q_lookup_summary
	call print_layer2_attn_k_lookup_summary
	call print_layer2_attn_v_lookup_summary
	call print_layer2_attn_output_lookup_summary
	call print_layer2_ffn_norm_lookup_summary
	call print_layer2_ffn_gate_lookup_summary
	call print_layer2_ffn_up_lookup_summary
	call print_layer2_ffn_down_lookup_summary
	call print_layer3_attn_norm_lookup_summary
	call print_layer3_attn_q_lookup_summary
	call print_layer3_attn_k_lookup_summary
	call print_layer3_attn_v_lookup_summary
	call print_layer3_attn_output_lookup_summary
	call print_layer3_ffn_norm_lookup_summary
