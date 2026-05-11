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
# the layer-1 FFN RMSNorm, gate/up matvec, SwiGLU, down matvec, and post-FFN
# residual smokes plus the layer-2 attention RMSNorm, query/key/value matvec,
# single-token context, and output-projection matvec smokes to focused inference
# code, and publishing status-gated exact-hex slices from the audited output
# buffers. It also performs non-math
# reusable descriptor lookups for
# `blk.1.attn_norm.weight`, `blk.1.attn_q.weight`, `blk.1.attn_k.weight`,
# `blk.1.attn_v.weight`, `blk.1.attn_output.weight`, and
# `blk.1.ffn_norm.weight`, `blk.1.ffn_gate.weight`, `blk.1.ffn_up.weight`, and
# `blk.1.ffn_down.weight`, plus layer-2 attention
# RMSNorm/query/key/value/output setup for `blk.2.attn_norm.weight`,
# `blk.2.attn_q.weight`,
# `blk.2.attn_k.weight`, `blk.2.attn_v.weight`, and
# `blk.2.attn_output.weight`, into separate
# process-owned scratch slots before the token-0 math path. The layer-1 FFN and
# layer-2 attention descriptors and retained activation outputs are consumed
# only by guarded focused smokes after their prerequisite activations exist.
# The mapping is released explicitly with gguf_release_mapping before exit. The
# GGUF summary buffer is process-owned
# static storage passed to the loader for scalar header counts, bounded metadata
# string copies, and selected scalar and array-length
# metadata values, plus a bounded snapshot of the first tensor descriptor and
# the first requested tensor-name lookup, including up to four dimension sizes
# for each retained descriptor, the tensor-info directory start offset, the
# aligned tensor-data base offset for non-empty tensor directories, and a
# retained descriptor for the first-layer attention RMSNorm weights, query
# projection, key projection, value projection, output projection, FFN RMSNorm
# weights, FFN gate, FFN up, FFN down projections, and the current layer-2
# attention setup descriptors.
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
	# Capture the next-layer FFN up descriptor in its own handoff slot for the
	# focused FFN inference module.
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
	jz .Llookup_layer1_ffn_down_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_ffn_down_tensor:
	# Capture the next-layer FFN down descriptor for descriptor-only coverage.
	# Its payload remains unread until the layer-1 SwiGLU activation can be
	# projected by a later atomic step.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_ffn_down_tensor_request]
	mov r9, layer1_ffn_down_tensor_request_end - layer1_ffn_down_tensor_request
	lea r10, [rip + layer1_ffn_down_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer2_attn_norm_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer2_attn_norm_tensor:
	# Start layer-2 setup with a dedicated RMSNorm descriptor. The payload is
	# read only by the guarded focused layer-2 attention RMSNorm smoke after the
	# layer-1 post-FFN residual activation exists.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer2_attn_norm_tensor_request]
	mov r9, layer2_attn_norm_tensor_request_end - layer2_attn_norm_tensor_request
	lea r10, [rip + layer2_attn_norm_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer2_attn_q_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer2_attn_q_tensor:
	# Capture the layer-2 query projection descriptor for the next attention
	# setup step. This descriptor-only smoke still avoids tensor payload reads.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer2_attn_q_tensor_request]
	mov r9, layer2_attn_q_tensor_request_end - layer2_attn_q_tensor_request
	lea r10, [rip + layer2_attn_q_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer2_attn_k_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer2_attn_k_tensor:
	# Capture the layer-2 key projection descriptor in its own scratch slot for
	# descriptor-only coverage. The key matrix payload remains unread here.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer2_attn_k_tensor_request]
	mov r9, layer2_attn_k_tensor_request_end - layer2_attn_k_tensor_request
	lea r10, [rip + layer2_attn_k_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer2_attn_v_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer2_attn_v_tensor:
	# Capture the layer-2 value projection descriptor in its own scratch slot
	# for descriptor-only coverage. The value matrix payload remains unread.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer2_attn_v_tensor_request]
	mov r9, layer2_attn_v_tensor_request_end - layer2_attn_v_tensor_request
	lea r10, [rip + layer2_attn_v_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer2_attn_output_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer2_attn_output_tensor:
	# Capture the layer-2 output projection descriptor in its own scratch slot
	# for shape-gating future output-context work. This step intentionally
	# publishes only descriptor fields and does not read matrix payload bytes.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer2_attn_output_tensor_request]
	mov r9, layer2_attn_output_tensor_request_end - layer2_attn_output_tensor_request
	lea r10, [rip + layer2_attn_output_tensor_slot]
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
