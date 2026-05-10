.section .text

.global _start
.type _start, @function

# Contract: process entry point for the current runtime milestone.
# Inputs: initial Linux process stack at rsp; argv[0..argc-1] and envp follow
# the System V AMD64 process-start layout. This function currently accepts
# either "--help" or one GGUF model path.
# Outputs: does not return. Writes help, success, or diagnostic text, then exits
# with status 0 for help/valid GGUF summary and smoke handling, 2 for CLI usage
# errors, or 3 for GGUF validation errors.
# Clobbers: all general-purpose registers may be clobbered; no caller exists.
# Ownership/lifetime: argv strings remain kernel-provided process memory. The
# loader returns a live read-only model mapping descriptor on success; _start
# keeps it live through the current summary path and token embedding, RMSNorm,
# first query projection, first key projection, and first value projection
# smokes, then derives the single-token attention context and projects it
# through the first output projection before adding the post-attention residual
# from process-owned static buffers, applies the FFN RMSNorm smoke through
# retained FFN norm weights, and projects that activation through the retained
# FFN gate and up matrices before deriving the first FFN SwiGLU activation,
# projecting it through the retained FFN down matrix, adding the guarded post-FFN
# residual from process-owned static buffers, then applying guarded layer-1
# attention RMSNorm, query/key/value projection, context, output projection, and
# post-attention residual smokes through reusable layer-1 descriptors, delegating
# the layer-1 FFN RMSNorm and gate matvec smokes to focused inference code, and
# publishing
# status-gated exact-hex slices from the audited output buffers. It also
# performs non-math reusable descriptor lookups for
# `blk.1.attn_norm.weight`, `blk.1.attn_q.weight`, `blk.1.attn_k.weight`,
# `blk.1.attn_v.weight`, `blk.1.attn_output.weight`, and
# `blk.1.ffn_norm.weight`, `blk.1.ffn_gate.weight`, and
# `blk.1.ffn_up.weight` into separate process-owned scratch slots before the
# token-0 math path. The up descriptor is still descriptor-only in this step;
# the gate descriptor is consumed only by the layer-1 FFN gate status smoke
# after the FFN-normalized activation exists. The mapping is released explicitly
# with
# gguf_release_mapping before exit. The GGUF summary buffer is process-owned
# static storage passed to the loader for scalar header counts, bounded metadata
# string copies, and selected scalar and array-length
# metadata values, plus a bounded snapshot of the first tensor descriptor and
# the first requested tensor-name lookup, including up to four dimension sizes
# for each retained descriptor, the tensor-info directory start offset, the
# aligned tensor-data base offset for non-empty tensor directories, and a
# retained descriptor for the first-layer attention RMSNorm weights, query
# projection, key projection, value projection, output projection, FFN RMSNorm
# weights, and FFN gate, FFN up, and FFN down projections.
# Error behavior: maps gguf_validate_file and post-validation tensor lookup
# status codes to stderr diagnostics after releasing any live mapping.
_start:
	# argc is the first word on the initial process stack. The milestone CLI
	# accepts exactly one user argument: either "--help" or a model path.
	mov rax, qword ptr [rsp]
	cmp rax, 2
	jne .Lusage_error

	# Compare argv[1] against the literal help flag before treating it as a
	# filesystem path. str_eq_exact also rejects longer strings with this prefix.
	mov rdi, qword ptr [rsp + 16]
	lea rsi, [rip + help_arg]
	mov rdx, help_arg_end - help_arg
	call str_eq_exact
	test rax, rax
	jz .Lvalidate_model

	# Help output goes to stdout. sys_exit never returns, so no cleanup follows.
	mov rdi, 1
	lea rsi, [rip + help_text]
	mov rdx, help_text_end - help_text
	call sys_write

	xor rdi, rdi
	call sys_exit

.Lvalidate_model:
	# The loader closes the file descriptor after validation and hands back a
	# read-only mapping descriptor. Keeping the mapping live here is the handoff
	# needed before tensor payload reads are added.
	mov rdi, qword ptr [rsp + 16]
	lea rsi, [rip + gguf_summary]
	lea rdx, [rip + lookup_tensor_request]
	mov rcx, lookup_tensor_request_end - lookup_tensor_request
	lea r8, [rip + gguf_mapping]
	call gguf_validate_file
	test rax, rax
	jz .Lgguf_ok

	# Keep this dispatch explicit while the status enum is still small; it makes
	# audit of each user-visible failure path straightforward.
	cmp rax, 1
	je .Lgguf_open_error
	cmp rax, 2
	je .Lgguf_fstat_error
	cmp rax, 3
	je .Lgguf_too_small_error
	cmp rax, 4
	je .Lgguf_mmap_error
	cmp rax, 5
	je .Lgguf_magic_error
	cmp rax, 6
	je .Lgguf_version_error
	cmp rax, 7
	je .Lgguf_munmap_error
	cmp rax, 8
	je .Lgguf_count_error
	cmp rax, 9
	je .Lgguf_metadata_bounds_error
	cmp rax, 10
	je .Lgguf_metadata_type_error
	cmp rax, 11
	je .Lgguf_tensor_bounds_error
	cmp rax, 12
	je .Lgguf_tensor_alignment_error

	lea rsi, [rip + gguf_unknown_error_text]
	mov rdx, gguf_unknown_error_text_end - gguf_unknown_error_text
	jmp .Lwrite_model_error

.Lgguf_open_error:
	lea rsi, [rip + gguf_open_error_text]
	mov rdx, gguf_open_error_text_end - gguf_open_error_text
	jmp .Lwrite_model_error

.Lgguf_fstat_error:
	lea rsi, [rip + gguf_fstat_error_text]
	mov rdx, gguf_fstat_error_text_end - gguf_fstat_error_text
	jmp .Lwrite_model_error

.Lgguf_too_small_error:
	lea rsi, [rip + gguf_too_small_error_text]
	mov rdx, gguf_too_small_error_text_end - gguf_too_small_error_text
	jmp .Lwrite_model_error

.Lgguf_mmap_error:
	lea rsi, [rip + gguf_mmap_error_text]
	mov rdx, gguf_mmap_error_text_end - gguf_mmap_error_text
	jmp .Lwrite_model_error

.Lgguf_magic_error:
	lea rsi, [rip + gguf_magic_error_text]
	mov rdx, gguf_magic_error_text_end - gguf_magic_error_text
	jmp .Lwrite_model_error

.Lgguf_version_error:
	lea rsi, [rip + gguf_version_error_text]
	mov rdx, gguf_version_error_text_end - gguf_version_error_text
	jmp .Lwrite_model_error

.Lgguf_munmap_error:
	lea rsi, [rip + gguf_munmap_error_text]
	mov rdx, gguf_munmap_error_text_end - gguf_munmap_error_text
	jmp .Lwrite_model_error

.Lgguf_count_error:
	lea rsi, [rip + gguf_count_error_text]
	mov rdx, gguf_count_error_text_end - gguf_count_error_text
	jmp .Lwrite_model_error

.Lgguf_metadata_bounds_error:
	lea rsi, [rip + gguf_metadata_bounds_error_text]
	mov rdx, gguf_metadata_bounds_error_text_end - gguf_metadata_bounds_error_text
	jmp .Lwrite_model_error

.Lgguf_metadata_type_error:
	lea rsi, [rip + gguf_metadata_type_error_text]
	mov rdx, gguf_metadata_type_error_text_end - gguf_metadata_type_error_text
	jmp .Lwrite_model_error

.Lgguf_tensor_bounds_error:
	lea rsi, [rip + gguf_tensor_bounds_error_text]
	mov rdx, gguf_tensor_bounds_error_text_end - gguf_tensor_bounds_error_text
	jmp .Lwrite_model_error

.Lgguf_tensor_alignment_error:
	lea rsi, [rip + gguf_tensor_alignment_error_text]
	mov rdx, gguf_tensor_alignment_error_text_end - gguf_tensor_alignment_error_text

.Lwrite_model_error:
	# Loader and post-validation lookup failures are runtime errors, distinct
	# from CLI misuse.
	mov rdi, 2
	call sys_write

	mov rdi, 3
	call sys_exit

.Lgguf_ok:
	# Exercise the reusable tensor-info lookup on later-layer descriptors while
	# leaving the fixed first-layer summary slots as the only inputs to the
	# token-0 layer-0 math smoke path below.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_attn_norm_tensor_request]
	mov r9, layer1_attn_norm_tensor_request_end - layer1_attn_norm_tensor_request
	lea r10, [rip + layer1_attn_norm_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_attn_q_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_attn_q_tensor:
	# Keep the next-layer query projection descriptor separate from the fixed
	# first-layer summary slots. The math smoke below consumes only this generic
	# slot after the layer-1 RMSNorm activation exists.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_attn_q_tensor_request]
	mov r9, layer1_attn_q_tensor_request_end - layer1_attn_q_tensor_request
	lea r10, [rip + layer1_attn_q_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_attn_k_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_attn_k_tensor:
	# Capture the next-layer key projection descriptor for descriptor-only smoke
	# coverage. No key projection payload bytes are read in this step.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_attn_k_tensor_request]
	mov r9, layer1_attn_k_tensor_request_end - layer1_attn_k_tensor_request
	lea r10, [rip + layer1_attn_k_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_attn_v_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_attn_v_tensor:
	# Capture the next-layer value projection descriptor for descriptor-only smoke
	# coverage. No layer-1 value projection payload bytes are read in this step.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_attn_v_tensor_request]
	mov r9, layer1_attn_v_tensor_request_end - layer1_attn_v_tensor_request
	lea r10, [rip + layer1_attn_v_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_attn_output_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_attn_output_tensor:
	# Capture the next-layer output projection descriptor for descriptor-only
	# coverage. The layer-1 output projection payload remains unread.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_attn_output_tensor_request]
	mov r9, layer1_attn_output_tensor_request_end - layer1_attn_output_tensor_request
	lea r10, [rip + layer1_attn_output_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_ffn_norm_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_ffn_norm_tensor:
	# Capture the next-layer FFN RMSNorm descriptor for descriptor-only coverage.
	# The tensor payload remains unread until a later RMSNorm smoke step.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_ffn_norm_tensor_request]
	mov r9, layer1_ffn_norm_tensor_request_end - layer1_ffn_norm_tensor_request
	lea r10, [rip + layer1_ffn_norm_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_ffn_gate_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_ffn_gate_tensor:
	# Capture the next-layer FFN gate descriptor for descriptor-only coverage.
	# This step intentionally prints only the directory summary and does not
	# inspect any Q8_0 payload bytes.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_ffn_gate_tensor_request]
	mov r9, layer1_ffn_gate_tensor_request_end - layer1_ffn_gate_tensor_request
	lea r10, [rip + layer1_ffn_gate_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_ffn_up_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_ffn_up_tensor:
	# Capture the next-layer FFN up descriptor for descriptor-only coverage.
	# The consumer matvec will be added in a later atomic step after this
	# directory lookup is independently visible.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_ffn_up_tensor_request]
	mov r9, layer1_ffn_up_tensor_request_end - layer1_ffn_up_tensor_request
	lea r10, [rip + layer1_ffn_up_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Lsummary_print
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_tensor_alignment_error:
	lea rdi, [rip + gguf_mapping]
	call gguf_release_mapping
	lea rsi, [rip + gguf_tensor_alignment_error_text]
	mov rdx, gguf_tensor_alignment_error_text_end - gguf_tensor_alignment_error_text
	jmp .Lwrite_model_error

.Llookup_tensor_bounds_error:
	lea rdi, [rip + gguf_mapping]
	call gguf_release_mapping
	lea rsi, [rip + gguf_tensor_bounds_error_text]
	mov rdx, gguf_tensor_bounds_error_text_end - gguf_tensor_bounds_error_text
	jmp .Lwrite_model_error

.Llookup_unknown_error:
	lea rdi, [rip + gguf_mapping]
	call gguf_release_mapping
	lea rsi, [rip + gguf_unknown_error_text]
	mov rdx, gguf_unknown_error_text_end - gguf_unknown_error_text
	jmp .Lwrite_model_error

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

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_found_text]
	mov rdx, attn_norm_tensor_found_text_end - attn_norm_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_name_text]
	mov rdx, attn_norm_tensor_name_text_end - attn_norm_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_attn_norm_tensor_name]
	mov rdx, GGUF_SUMMARY_ATTN_NORM_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_n_dimensions_text]
	mov rdx, attn_norm_tensor_n_dimensions_text_end - attn_norm_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_dim0_text]
	mov rdx, attn_norm_tensor_dim0_text_end - attn_norm_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_dim1_text]
	mov rdx, attn_norm_tensor_dim1_text_end - attn_norm_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_dim2_text]
	mov rdx, attn_norm_tensor_dim2_text_end - attn_norm_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_dim3_text]
	mov rdx, attn_norm_tensor_dim3_text_end - attn_norm_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_ggml_type_text]
	mov rdx, attn_norm_tensor_ggml_type_text_end - attn_norm_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_offset_text]
	mov rdx, attn_norm_tensor_offset_text_end - attn_norm_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_found_text]
	mov rdx, attn_q_tensor_found_text_end - attn_q_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_name_text]
	mov rdx, attn_q_tensor_name_text_end - attn_q_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_attn_q_tensor_name]
	mov rdx, GGUF_SUMMARY_ATTN_Q_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_n_dimensions_text]
	mov rdx, attn_q_tensor_n_dimensions_text_end - attn_q_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_dim0_text]
	mov rdx, attn_q_tensor_dim0_text_end - attn_q_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_dim1_text]
	mov rdx, attn_q_tensor_dim1_text_end - attn_q_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_dim2_text]
	mov rdx, attn_q_tensor_dim2_text_end - attn_q_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_dim3_text]
	mov rdx, attn_q_tensor_dim3_text_end - attn_q_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_ggml_type_text]
	mov rdx, attn_q_tensor_ggml_type_text_end - attn_q_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_offset_text]
	mov rdx, attn_q_tensor_offset_text_end - attn_q_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_found_text]
	mov rdx, attn_k_tensor_found_text_end - attn_k_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_name_text]
	mov rdx, attn_k_tensor_name_text_end - attn_k_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_attn_k_tensor_name]
	mov rdx, GGUF_SUMMARY_ATTN_K_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_n_dimensions_text]
	mov rdx, attn_k_tensor_n_dimensions_text_end - attn_k_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_dim0_text]
	mov rdx, attn_k_tensor_dim0_text_end - attn_k_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_dim1_text]
	mov rdx, attn_k_tensor_dim1_text_end - attn_k_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_dim2_text]
	mov rdx, attn_k_tensor_dim2_text_end - attn_k_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_dim3_text]
	mov rdx, attn_k_tensor_dim3_text_end - attn_k_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_ggml_type_text]
	mov rdx, attn_k_tensor_ggml_type_text_end - attn_k_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_offset_text]
	mov rdx, attn_k_tensor_offset_text_end - attn_k_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_found_text]
	mov rdx, attn_v_tensor_found_text_end - attn_v_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_name_text]
	mov rdx, attn_v_tensor_name_text_end - attn_v_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_attn_v_tensor_name]
	mov rdx, GGUF_SUMMARY_ATTN_V_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_n_dimensions_text]
	mov rdx, attn_v_tensor_n_dimensions_text_end - attn_v_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_dim0_text]
	mov rdx, attn_v_tensor_dim0_text_end - attn_v_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_dim1_text]
	mov rdx, attn_v_tensor_dim1_text_end - attn_v_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_dim2_text]
	mov rdx, attn_v_tensor_dim2_text_end - attn_v_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_dim3_text]
	mov rdx, attn_v_tensor_dim3_text_end - attn_v_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_ggml_type_text]
	mov rdx, attn_v_tensor_ggml_type_text_end - attn_v_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_offset_text]
	mov rdx, attn_v_tensor_offset_text_end - attn_v_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_found_text]
	mov rdx, attn_output_tensor_found_text_end - attn_output_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_name_text]
	mov rdx, attn_output_tensor_name_text_end - attn_output_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_attn_output_tensor_name]
	mov rdx, GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_n_dimensions_text]
	mov rdx, attn_output_tensor_n_dimensions_text_end - attn_output_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_dim0_text]
	mov rdx, attn_output_tensor_dim0_text_end - attn_output_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_dim1_text]
	mov rdx, attn_output_tensor_dim1_text_end - attn_output_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_dim2_text]
	mov rdx, attn_output_tensor_dim2_text_end - attn_output_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_dim3_text]
	mov rdx, attn_output_tensor_dim3_text_end - attn_output_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_ggml_type_text]
	mov rdx, attn_output_tensor_ggml_type_text_end - attn_output_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_offset_text]
	mov rdx, attn_output_tensor_offset_text_end - attn_output_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

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

	# The live mapping has now served parser summary and guarded tensor payload
	# smoke paths. Ownership remains explicit and is released before exit.
	lea rdi, [rip + gguf_mapping]
	call gguf_release_mapping
	test rax, rax
	jz .Lsummary_exit_ok

	lea rsi, [rip + gguf_munmap_error_text]
	mov rdx, gguf_munmap_error_text_end - gguf_munmap_error_text
	jmp .Lwrite_model_error

.Lsummary_exit_ok:
	xor rdi, rdi
	call sys_exit

.Lusage_error:
	# Usage errors are intentionally handled before any file syscall.
	mov rdi, 2
	lea rsi, [rip + usage_error_text]
	mov rdx, usage_error_text_end - usage_error_text
	call sys_write

	mov rdi, 2
	call sys_exit

.size _start, . - _start

