
	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_found_text]
	mov rdx, ffn_norm_tensor_found_text_end - ffn_norm_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_name_text]
	mov rdx, ffn_norm_tensor_name_text_end - ffn_norm_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_ffn_norm_tensor_name]
	mov rdx, GGUF_SUMMARY_FFN_NORM_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_n_dimensions_text]
	mov rdx, ffn_norm_tensor_n_dimensions_text_end - ffn_norm_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_dim0_text]
	mov rdx, ffn_norm_tensor_dim0_text_end - ffn_norm_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_dim1_text]
	mov rdx, ffn_norm_tensor_dim1_text_end - ffn_norm_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_dim2_text]
	mov rdx, ffn_norm_tensor_dim2_text_end - ffn_norm_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_dim3_text]
	mov rdx, ffn_norm_tensor_dim3_text_end - ffn_norm_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_ggml_type_text]
	mov rdx, ffn_norm_tensor_ggml_type_text_end - ffn_norm_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_offset_text]
	mov rdx, ffn_norm_tensor_offset_text_end - ffn_norm_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_found_text]
	mov rdx, ffn_gate_tensor_found_text_end - ffn_gate_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_name_text]
	mov rdx, ffn_gate_tensor_name_text_end - ffn_gate_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_ffn_gate_tensor_name]
	mov rdx, GGUF_SUMMARY_FFN_GATE_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_n_dimensions_text]
	mov rdx, ffn_gate_tensor_n_dimensions_text_end - ffn_gate_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_dim0_text]
	mov rdx, ffn_gate_tensor_dim0_text_end - ffn_gate_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_dim1_text]
	mov rdx, ffn_gate_tensor_dim1_text_end - ffn_gate_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_dim2_text]
	mov rdx, ffn_gate_tensor_dim2_text_end - ffn_gate_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_dim3_text]
	mov rdx, ffn_gate_tensor_dim3_text_end - ffn_gate_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_ggml_type_text]
	mov rdx, ffn_gate_tensor_ggml_type_text_end - ffn_gate_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_offset_text]
	mov rdx, ffn_gate_tensor_offset_text_end - ffn_gate_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_found_text]
	mov rdx, ffn_up_tensor_found_text_end - ffn_up_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_name_text]
	mov rdx, ffn_up_tensor_name_text_end - ffn_up_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_ffn_up_tensor_name]
	mov rdx, GGUF_SUMMARY_FFN_UP_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_n_dimensions_text]
	mov rdx, ffn_up_tensor_n_dimensions_text_end - ffn_up_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_dim0_text]
	mov rdx, ffn_up_tensor_dim0_text_end - ffn_up_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_dim1_text]
	mov rdx, ffn_up_tensor_dim1_text_end - ffn_up_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_dim2_text]
	mov rdx, ffn_up_tensor_dim2_text_end - ffn_up_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_dim3_text]
	mov rdx, ffn_up_tensor_dim3_text_end - ffn_up_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_ggml_type_text]
	mov rdx, ffn_up_tensor_ggml_type_text_end - ffn_up_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_offset_text]
	mov rdx, ffn_up_tensor_offset_text_end - ffn_up_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_found_text]
	mov rdx, ffn_down_tensor_found_text_end - ffn_down_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_name_text]
	mov rdx, ffn_down_tensor_name_text_end - ffn_down_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_ffn_down_tensor_name]
	mov rdx, GGUF_SUMMARY_FFN_DOWN_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_n_dimensions_text]
	mov rdx, ffn_down_tensor_n_dimensions_text_end - ffn_down_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_dim0_text]
	mov rdx, ffn_down_tensor_dim0_text_end - ffn_down_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_dim1_text]
	mov rdx, ffn_down_tensor_dim1_text_end - ffn_down_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_dim2_text]
	mov rdx, ffn_down_tensor_dim2_text_end - ffn_down_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_dim3_text]
	mov rdx, ffn_down_tensor_dim3_text_end - ffn_down_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_ggml_type_text]
	mov rdx, ffn_down_tensor_ggml_type_text_end - ffn_down_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_offset_text]
	mov rdx, ffn_down_tensor_offset_text_end - ffn_down_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	# The token-0 embedding smoke is deliberately after the summary print so the
	# retained descriptor remains visible even when a narrow synthetic GGUF is not
	# target-shaped enough to dequantize.
