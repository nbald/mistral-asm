
	mov rdi, 1
	lea rsi, [rip + first_tensor_name_text]
	mov rdx, first_tensor_name_text_end - first_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_first_tensor_name]
	mov rdx, GGUF_SUMMARY_FIRST_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_n_dimensions_text]
	mov rdx, first_tensor_n_dimensions_text_end - first_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_dim0_text]
	mov rdx, first_tensor_dim0_text_end - first_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_dim1_text]
	mov rdx, first_tensor_dim1_text_end - first_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_dim2_text]
	mov rdx, first_tensor_dim2_text_end - first_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_dim3_text]
	mov rdx, first_tensor_dim3_text_end - first_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_ggml_type_text]
	mov rdx, first_tensor_ggml_type_text_end - first_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_offset_text]
	mov rdx, first_tensor_offset_text_end - first_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_found_text]
	mov rdx, lookup_tensor_found_text_end - lookup_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_name_text]
	mov rdx, lookup_tensor_name_text_end - lookup_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_lookup_tensor_name]
	mov rdx, GGUF_SUMMARY_LOOKUP_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_n_dimensions_text]
	mov rdx, lookup_tensor_n_dimensions_text_end - lookup_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_dim0_text]
	mov rdx, lookup_tensor_dim0_text_end - lookup_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_dim1_text]
	mov rdx, lookup_tensor_dim1_text_end - lookup_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_dim2_text]
	mov rdx, lookup_tensor_dim2_text_end - lookup_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_dim3_text]
	mov rdx, lookup_tensor_dim3_text_end - lookup_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_ggml_type_text]
	mov rdx, lookup_tensor_ggml_type_text_end - lookup_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_offset_text]
	mov rdx, lookup_tensor_offset_text_end - lookup_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write
