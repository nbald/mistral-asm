
.type gguf_walk_tensor_infos, @function

# Contract: advance over the GGUF tensor-info directory, retain a bounded
# snapshot of the first descriptor, retain a bounded descriptor snapshot for one
# requested tensor name when it is present, and retain the fixed first-layer
# attention RMSNorm weight, query projection, key projection, value projection,
# attention output projection, FFN RMSNorm weight, FFN gate projection, FFN up
# projection, and FFN down projection descriptors when present.
# Inputs: rdi = mapping base, rsi = mapped file length, rdx = tensor-info start
# offset, rcx = tensor count from the GGUF header, r8 = summary buffer, r9 =
# requested tensor name bytes, r10 = requested tensor name length.
# Outputs: rax = GGUF_OK on success or a GGUF_ERR_TENSOR_* code; rdx = aligned
# tensor-data start offset on success when tensors exist, or the unchanged cursor
# when tensor_count is zero.
# Clobbers: caller-saved registers and flags. Preserves callee-saved registers
# it uses (rbx, rbp, r12, r13, r14, r15).
# Ownership/lifetime: reads only from the caller-owned mapping. Retained tensor
# names and up to four dimension sizes are copied into fixed-size caller-owned
# summary storage; no mapped-file pointer is retained.
# Error behavior: returns malformed-tensor status before any out-of-bounds read.
# Tensor payload offsets with the high bit set, not divisible by the current
# default alignment, or not landing inside the mapped file after tensor-data
# base alignment are rejected in this narrow parser.
gguf_walk_tensor_infos:
	push rbp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 120

	# rbp tracks the largest relative payload offset seen in the directory. Once
	# the tensor-data base is aligned, one bounds check proves every retained
	# relative payload start lands inside the mapping.
	xor ebp, ebp
	mov r13, rdi
	mov r14, rsi
	mov r12, rdx
	mov rbx, rcx
	mov r15, r8
	mov qword ptr [rsp], r9
	mov qword ptr [rsp + 8], r10

	# A no-tensor synthetic fixture has no tensor-data section to align. It is
	# still useful for header/metadata smoke tests, so leave the cursor unchanged.
	test rbx, rbx
	jz .Ltensor_empty_success

.Ltensor_first:
	# Parse the first descriptor name directly so the same checked name bytes can
	# feed the first-tensor summary, requested-name lookup, and fixed first-layer
	# descriptor lookups.
	cmp r12, r14
	ja .Ltensor_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 8
	jb .Ltensor_bad
	mov r8, qword ptr [r13 + r12]
	test r8, r8
	js .Ltensor_bad
	add r12, 8

	mov rax, r14
	sub rax, r12
	cmp rax, r8
	jb .Ltensor_bad
	lea rax, [r13 + r12]
	mov qword ptr [rsp + 24], rax
	mov qword ptr [rsp + 32], r8
	add r12, r8

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_FIRST_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_FIRST_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

	xor eax, eax
	mov qword ptr [rsp + 16], rax
	mov qword ptr [rsp + 48], rax
	mov qword ptr [rsp + 56], rax
	mov qword ptr [rsp + 64], rax
	mov qword ptr [rsp + 72], rax
	mov qword ptr [rsp + 80], rax
	mov qword ptr [rsp + 88], rax
	mov qword ptr [rsp + 96], rax
	mov qword ptr [rsp + 104], rax
	mov qword ptr [rsp + 112], rax
	cmp qword ptr [rsp + 8], 0
	je .Ltensor_first_name_compared
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	mov rdx, qword ptr [rsp]
	mov rcx, qword ptr [rsp + 8]
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 16], rax

.Ltensor_first_name_compared:
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + attn_norm_tensor_request]
	mov rcx, attn_norm_tensor_request_end - attn_norm_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 48], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + attn_q_tensor_request]
	mov rcx, attn_q_tensor_request_end - attn_q_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 56], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + attn_k_tensor_request]
	mov rcx, attn_k_tensor_request_end - attn_k_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 64], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + attn_v_tensor_request]
	mov rcx, attn_v_tensor_request_end - attn_v_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 72], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + attn_output_tensor_request]
	mov rcx, attn_output_tensor_request_end - attn_output_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 80], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + ffn_norm_tensor_request]
	mov rcx, ffn_norm_tensor_request_end - ffn_norm_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 88], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + ffn_gate_tensor_request]
	mov rcx, ffn_gate_tensor_request_end - ffn_gate_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 96], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + ffn_up_tensor_request]
	mov rcx, ffn_up_tensor_request_end - ffn_up_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 104], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + ffn_down_tensor_request]
	mov rcx, ffn_down_tensor_request_end - ffn_down_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 112], rax

	# n_dimensions is recorded as a u64 in the summary, but its in-file encoding
	# is a u32 followed by that many u64 dimension sizes.
	cmp r12, r14
	ja .Ltensor_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Ltensor_bad
	mov eax, dword ptr [r13 + r12]
	add r12, 4
	test eax, eax
	jz .Ltensor_bad
	cmp eax, GGUF_MAX_DIMS
	ja .Ltensor_bad
	mov qword ptr [r15 + GGUF_SUMMARY_FIRST_TENSOR_N_DIMS], rax
	cmp qword ptr [rsp + 16], 0
	je .Ltensor_first_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_DIMS + 24], 0

.Ltensor_first_n_dims_recorded:
	cmp qword ptr [rsp + 48], 0
	je .Ltensor_first_attn_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_DIMS + 24], 0

.Ltensor_first_attn_n_dims_recorded:
	cmp qword ptr [rsp + 56], 0
	je .Ltensor_first_attn_q_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_DIMS + 24], 0

.Ltensor_first_attn_q_n_dims_recorded:
	cmp qword ptr [rsp + 64], 0
	je .Ltensor_first_attn_k_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_DIMS + 24], 0

.Ltensor_first_attn_k_n_dims_recorded:
	cmp qword ptr [rsp + 72], 0
	je .Ltensor_first_attn_v_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_DIMS + 24], 0

.Ltensor_first_attn_v_n_dims_recorded:
	cmp qword ptr [rsp + 80], 0
	je .Ltensor_first_attn_output_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_DIMS + 24], 0

.Ltensor_first_attn_output_n_dims_recorded:
	cmp qword ptr [rsp + 88], 0
	je .Ltensor_first_ffn_norm_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_DIMS + 24], 0

.Ltensor_first_ffn_norm_n_dims_recorded:
	cmp qword ptr [rsp + 96], 0
	je .Ltensor_first_ffn_gate_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_DIMS + 24], 0

.Ltensor_first_ffn_gate_n_dims_recorded:
	cmp qword ptr [rsp + 104], 0
	je .Ltensor_first_ffn_up_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_DIMS + 24], 0

.Ltensor_first_ffn_up_n_dims_recorded:
	cmp qword ptr [rsp + 112], 0
	je .Ltensor_first_ffn_down_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_DIMS + 24], 0

.Ltensor_first_ffn_down_n_dims_recorded:

	# The summary has exactly four dimension slots, matching the GGUF max dims
	# accepted above. Bounds-check the whole in-file span before copying any
	# dimension value, so unused summary slots can safely remain zero-filled.
	mov rcx, rax
	mov r11, rax
	shl r11, 3
	cmp r12, r14
	ja .Ltensor_bad
	mov rax, r14
	sub rax, r12
	cmp rax, r11
	jb .Ltensor_bad
	mov r8, r13
	add r8, r12
	lea r9, [r15 + GGUF_SUMMARY_FIRST_TENSOR_DIMS]
	xor edx, edx

.Ltensor_first_dim_loop:
	cmp rdx, rcx
	je .Ltensor_first_dims_done
	mov r10, qword ptr [r8 + rdx * 8]
	mov qword ptr [r9 + rdx * 8], r10
	cmp qword ptr [rsp + 16], 0
	je .Ltensor_first_attn_dim
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_DIMS + rdx * 8], r10

.Ltensor_first_attn_dim:
	cmp qword ptr [rsp + 48], 0
	je .Ltensor_first_attn_q_dim
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_DIMS + rdx * 8], r10

.Ltensor_first_attn_q_dim:
	cmp qword ptr [rsp + 56], 0
	je .Ltensor_first_attn_k_dim
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_DIMS + rdx * 8], r10

.Ltensor_first_attn_k_dim:
	cmp qword ptr [rsp + 64], 0
	je .Ltensor_first_attn_v_dim
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_DIMS + rdx * 8], r10

.Ltensor_first_attn_v_dim:
	cmp qword ptr [rsp + 72], 0
	je .Ltensor_first_attn_output_dim
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_DIMS + rdx * 8], r10

.Ltensor_first_attn_output_dim:
	cmp qword ptr [rsp + 80], 0
	je .Ltensor_first_ffn_norm_dim
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_DIMS + rdx * 8], r10

.Ltensor_first_ffn_norm_dim:
	cmp qword ptr [rsp + 88], 0
	je .Ltensor_first_ffn_gate_dim
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_DIMS + rdx * 8], r10

.Ltensor_first_ffn_gate_dim:
	cmp qword ptr [rsp + 96], 0
	je .Ltensor_first_ffn_up_dim
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_DIMS + rdx * 8], r10

.Ltensor_first_ffn_up_dim:
	cmp qword ptr [rsp + 104], 0
	je .Ltensor_first_ffn_down_dim
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_DIMS + rdx * 8], r10

.Ltensor_first_ffn_down_dim:
	cmp qword ptr [rsp + 112], 0
	je .Ltensor_first_dim_next
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_DIMS + rdx * 8], r10

.Ltensor_first_dim_next:
	inc rdx
	jmp .Ltensor_first_dim_loop

.Ltensor_first_dims_done:
	add r12, r11

	# ggml_type is a u32 enum in GGUF. Keep the raw value for the first tensor so
	# later type validation can be audited against the original directory entry.
	cmp r12, r14
	ja .Ltensor_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Ltensor_bad
	mov eax, dword ptr [r13 + r12]
	mov qword ptr [r15 + GGUF_SUMMARY_FIRST_TENSOR_GGML_TYPE], rax
	cmp qword ptr [rsp + 16], 0
	je .Ltensor_first_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_GGML_TYPE], rax

.Ltensor_first_type_recorded:
	cmp qword ptr [rsp + 48], 0
	je .Ltensor_first_attn_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_GGML_TYPE], rax

.Ltensor_first_attn_type_recorded:
	cmp qword ptr [rsp + 56], 0
	je .Ltensor_first_attn_q_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_GGML_TYPE], rax

.Ltensor_first_attn_q_type_recorded:
	cmp qword ptr [rsp + 64], 0
	je .Ltensor_first_attn_k_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_GGML_TYPE], rax

.Ltensor_first_attn_k_type_recorded:
	cmp qword ptr [rsp + 72], 0
	je .Ltensor_first_attn_v_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_GGML_TYPE], rax

.Ltensor_first_attn_v_type_recorded:
	cmp qword ptr [rsp + 80], 0
	je .Ltensor_first_attn_output_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_GGML_TYPE], rax

.Ltensor_first_attn_output_type_recorded:
	cmp qword ptr [rsp + 88], 0
	je .Ltensor_first_ffn_norm_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_GGML_TYPE], rax

.Ltensor_first_ffn_norm_type_recorded:
	cmp qword ptr [rsp + 96], 0
	je .Ltensor_first_ffn_gate_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_GGML_TYPE], rax

.Ltensor_first_ffn_gate_type_recorded:
	cmp qword ptr [rsp + 104], 0
	je .Ltensor_first_ffn_up_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_GGML_TYPE], rax

.Ltensor_first_ffn_up_type_recorded:
	cmp qword ptr [rsp + 112], 0
	je .Ltensor_first_ffn_down_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_GGML_TYPE], rax

.Ltensor_first_ffn_down_type_recorded:
	add r12, 4

	# Tensor offsets are relative to the aligned tensor-data section, not the
	# start of the file. Retain the raw relative offset for the first descriptor.
	cmp r12, r14
	ja .Ltensor_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 8
	jb .Ltensor_bad
	mov rax, qword ptr [r13 + r12]
	test rax, rax
	js .Ltensor_bad
	test al, GGUF_DEFAULT_ALIGNMENT - 1
	jnz .Ltensor_bad_alignment
	mov qword ptr [rsp + 40], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FIRST_TENSOR_OFFSET], rax
	cmp qword ptr [rsp + 16], 0
	je .Ltensor_first_offset_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_LOOKUP_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_first_offset_recorded:
	cmp qword ptr [rsp + 48], 0
	je .Ltensor_first_attn_offset_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_ATTN_NORM_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_first_attn_offset_recorded:
	cmp qword ptr [rsp + 56], 0
	je .Ltensor_first_attn_q_offset_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_ATTN_Q_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_first_attn_q_offset_recorded:
	cmp qword ptr [rsp + 64], 0
	je .Ltensor_first_attn_k_offset_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_ATTN_K_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_first_attn_k_offset_recorded:
	cmp qword ptr [rsp + 72], 0
	je .Ltensor_first_attn_v_offset_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_ATTN_V_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_first_attn_v_offset_recorded:
	cmp qword ptr [rsp + 80], 0
	je .Ltensor_first_attn_output_offset_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_first_attn_output_offset_recorded:
	cmp qword ptr [rsp + 88], 0
	je .Ltensor_first_ffn_norm_offset_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_FFN_NORM_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_first_ffn_norm_offset_recorded:
	cmp qword ptr [rsp + 96], 0
	je .Ltensor_first_ffn_gate_offset_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_FFN_GATE_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_first_ffn_gate_offset_recorded:
	cmp qword ptr [rsp + 104], 0
	je .Ltensor_first_ffn_up_offset_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_FFN_UP_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_first_ffn_up_offset_recorded:
	cmp qword ptr [rsp + 112], 0
	je .Ltensor_first_ffn_down_offset_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_FFN_DOWN_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_first_ffn_down_offset_recorded:
	mov rax, qword ptr [rsp + 40]
	mov rbp, rax
	add r12, 8

	dec rbx
	jz .Ltensor_align_data_start

.Ltensor_loop:
	# Tensor names use the same GGUF string encoding as metadata keys: u64 byte
	# length followed by raw bytes, with no padding before the dimension count.
	cmp r12, r14
	ja .Ltensor_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 8
	jb .Ltensor_bad
	mov r8, qword ptr [r13 + r12]
	test r8, r8
	js .Ltensor_bad
	add r12, 8

	mov rax, r14
	sub rax, r12
	cmp rax, r8
	jb .Ltensor_bad
	lea rax, [r13 + r12]
	mov qword ptr [rsp + 24], rax
	mov qword ptr [rsp + 32], r8
	add r12, r8

	xor eax, eax
	mov qword ptr [rsp + 16], rax
	mov qword ptr [rsp + 48], rax
	mov qword ptr [rsp + 56], rax
	mov qword ptr [rsp + 64], rax
	mov qword ptr [rsp + 72], rax
	mov qword ptr [rsp + 80], rax
	mov qword ptr [rsp + 88], rax
	mov qword ptr [rsp + 96], rax
	mov qword ptr [rsp + 104], rax
	mov qword ptr [rsp + 112], rax
	cmp qword ptr [rsp + 8], 0
	je .Ltensor_name_compared
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	mov rdx, qword ptr [rsp]
	mov rcx, qword ptr [rsp + 8]
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 16], rax

.Ltensor_name_compared:
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + attn_norm_tensor_request]
	mov rcx, attn_norm_tensor_request_end - attn_norm_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 48], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + attn_q_tensor_request]
	mov rcx, attn_q_tensor_request_end - attn_q_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 56], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + attn_k_tensor_request]
	mov rcx, attn_k_tensor_request_end - attn_k_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 64], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + attn_v_tensor_request]
	mov rcx, attn_v_tensor_request_end - attn_v_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 72], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + attn_output_tensor_request]
	mov rcx, attn_output_tensor_request_end - attn_output_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 80], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + ffn_norm_tensor_request]
	mov rcx, ffn_norm_tensor_request_end - ffn_norm_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 88], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + ffn_gate_tensor_request]
	mov rcx, ffn_gate_tensor_request_end - ffn_gate_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 96], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + ffn_up_tensor_request]
	mov rcx, ffn_up_tensor_request_end - ffn_up_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 104], rax

	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [rip + ffn_down_tensor_request]
	mov rcx, ffn_down_tensor_request_end - ffn_down_tensor_request
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 112], rax

	# n_dimensions is a u32 followed by that many u64 dimension sizes. GGUF
	# tensors are capped by GGML_MAX_DIMS, four dimensions in this target format.
	cmp r12, r14
	ja .Ltensor_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Ltensor_bad
	mov eax, dword ptr [r13 + r12]
	add r12, 4
	test eax, eax
	jz .Ltensor_bad
	cmp eax, GGUF_MAX_DIMS
	ja .Ltensor_bad
	cmp qword ptr [rsp + 16], 0
	je .Ltensor_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_DIMS + 24], 0

.Ltensor_n_dims_recorded:
	cmp qword ptr [rsp + 48], 0
	je .Ltensor_attn_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_DIMS + 24], 0

.Ltensor_attn_n_dims_recorded:
	cmp qword ptr [rsp + 56], 0
	je .Ltensor_attn_q_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_DIMS + 24], 0

.Ltensor_attn_q_n_dims_recorded:
	cmp qword ptr [rsp + 64], 0
	je .Ltensor_attn_k_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_DIMS + 24], 0

.Ltensor_attn_k_n_dims_recorded:
	cmp qword ptr [rsp + 72], 0
	je .Ltensor_attn_v_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_DIMS + 24], 0

.Ltensor_attn_v_n_dims_recorded:
	cmp qword ptr [rsp + 80], 0
	je .Ltensor_attn_output_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_DIMS + 24], 0

.Ltensor_attn_output_n_dims_recorded:
	cmp qword ptr [rsp + 88], 0
	je .Ltensor_ffn_norm_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_DIMS + 24], 0

.Ltensor_ffn_norm_n_dims_recorded:
	cmp qword ptr [rsp + 96], 0
	je .Ltensor_ffn_gate_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_DIMS + 24], 0

.Ltensor_ffn_gate_n_dims_recorded:
	cmp qword ptr [rsp + 104], 0
	je .Ltensor_ffn_up_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_DIMS + 24], 0

.Ltensor_ffn_up_n_dims_recorded:
	cmp qword ptr [rsp + 112], 0
	je .Ltensor_ffn_down_n_dims_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_N_DIMS], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_DIMS], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_DIMS + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_DIMS + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_DIMS + 24], 0

.Ltensor_ffn_down_n_dims_recorded:
	mov r8, rax
	shl r8, 3
	cmp r12, r14
	ja .Ltensor_bad
	mov rax, r14
	sub rax, r12
	cmp rax, r8
	jb .Ltensor_bad
	cmp qword ptr [rsp + 16], 0
	je .Ltensor_maybe_attn_dims
	mov r11, r13
	add r11, r12
	xor edx, edx

.Ltensor_dim_loop:
	cmp rdx, qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_N_DIMS]
	je .Ltensor_maybe_attn_dims
	mov r10, qword ptr [r11 + rdx * 8]
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_DIMS + rdx * 8], r10
	inc rdx
	jmp .Ltensor_dim_loop

.Ltensor_maybe_attn_dims:
	cmp qword ptr [rsp + 48], 0
	je .Ltensor_maybe_attn_q_dims
	mov r11, r13
	add r11, r12
	xor edx, edx

.Ltensor_attn_dim_loop:
	cmp rdx, qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_N_DIMS]
	je .Ltensor_dims_done
	mov r10, qword ptr [r11 + rdx * 8]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_DIMS + rdx * 8], r10
	inc rdx
	jmp .Ltensor_attn_dim_loop

.Ltensor_maybe_attn_q_dims:
	cmp qword ptr [rsp + 56], 0
	je .Ltensor_maybe_attn_k_dims
	mov r11, r13
	add r11, r12
	xor edx, edx

.Ltensor_attn_q_dim_loop:
	cmp rdx, qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_N_DIMS]
	je .Ltensor_dims_done
	mov r10, qword ptr [r11 + rdx * 8]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_DIMS + rdx * 8], r10
	inc rdx
	jmp .Ltensor_attn_q_dim_loop

.Ltensor_maybe_attn_k_dims:
	cmp qword ptr [rsp + 64], 0
	je .Ltensor_maybe_attn_v_dims
	mov r11, r13
	add r11, r12
	xor edx, edx

.Ltensor_attn_k_dim_loop:
	cmp rdx, qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_N_DIMS]
	je .Ltensor_dims_done
	mov r10, qword ptr [r11 + rdx * 8]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_DIMS + rdx * 8], r10
	inc rdx
	jmp .Ltensor_attn_k_dim_loop

.Ltensor_maybe_attn_v_dims:
	cmp qword ptr [rsp + 72], 0
	je .Ltensor_maybe_attn_output_dims
	mov r11, r13
	add r11, r12
	xor edx, edx

.Ltensor_attn_v_dim_loop:
	cmp rdx, qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_N_DIMS]
	je .Ltensor_dims_done
	mov r10, qword ptr [r11 + rdx * 8]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_DIMS + rdx * 8], r10
	inc rdx
	jmp .Ltensor_attn_v_dim_loop

.Ltensor_maybe_attn_output_dims:
	cmp qword ptr [rsp + 80], 0
	je .Ltensor_maybe_ffn_norm_dims
	mov r11, r13
	add r11, r12
	xor edx, edx

.Ltensor_attn_output_dim_loop:
	cmp rdx, qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_N_DIMS]
	je .Ltensor_dims_done
	mov r10, qword ptr [r11 + rdx * 8]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_DIMS + rdx * 8], r10
	inc rdx
	jmp .Ltensor_attn_output_dim_loop

.Ltensor_maybe_ffn_norm_dims:
	cmp qword ptr [rsp + 88], 0
	je .Ltensor_maybe_ffn_gate_dims
	mov r11, r13
	add r11, r12
	xor edx, edx

.Ltensor_ffn_norm_dim_loop:
	cmp rdx, qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_N_DIMS]
	je .Ltensor_dims_done
	mov r10, qword ptr [r11 + rdx * 8]
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_DIMS + rdx * 8], r10
	inc rdx
	jmp .Ltensor_ffn_norm_dim_loop

.Ltensor_maybe_ffn_gate_dims:
	cmp qword ptr [rsp + 96], 0
	je .Ltensor_maybe_ffn_up_dims
	mov r11, r13
	add r11, r12
	xor edx, edx

.Ltensor_ffn_gate_dim_loop:
	cmp rdx, qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_N_DIMS]
	je .Ltensor_dims_done
	mov r10, qword ptr [r11 + rdx * 8]
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_DIMS + rdx * 8], r10
	inc rdx
	jmp .Ltensor_ffn_gate_dim_loop

.Ltensor_maybe_ffn_up_dims:
	cmp qword ptr [rsp + 104], 0
	je .Ltensor_maybe_ffn_down_dims
	mov r11, r13
	add r11, r12
	xor edx, edx

.Ltensor_ffn_up_dim_loop:
	cmp rdx, qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_N_DIMS]
	je .Ltensor_dims_done
	mov r10, qword ptr [r11 + rdx * 8]
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_DIMS + rdx * 8], r10
	inc rdx
	jmp .Ltensor_ffn_up_dim_loop

.Ltensor_maybe_ffn_down_dims:
	cmp qword ptr [rsp + 112], 0
	je .Ltensor_dims_done
	mov r11, r13
	add r11, r12
	xor edx, edx

.Ltensor_ffn_down_dim_loop:
	cmp rdx, qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_N_DIMS]
	je .Ltensor_dims_done
	mov r10, qword ptr [r11 + rdx * 8]
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_DIMS + rdx * 8], r10
	inc rdx
	jmp .Ltensor_ffn_down_dim_loop

.Ltensor_dims_done:
	add r12, r8

	# Tensor type tags are consumed for every descriptor and retained only for a
	# requested-name or fixed first-layer descriptor match. The bounds check keeps
	# the cursor trustworthy even when the descriptor is otherwise not interesting
	# yet.
	cmp r12, r14
	ja .Ltensor_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Ltensor_bad
	mov eax, dword ptr [r13 + r12]
	cmp qword ptr [rsp + 16], 0
	je .Ltensor_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_GGML_TYPE], rax

.Ltensor_type_recorded:
	cmp qword ptr [rsp + 48], 0
	je .Ltensor_attn_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_GGML_TYPE], rax

.Ltensor_attn_type_recorded:
	cmp qword ptr [rsp + 56], 0
	je .Ltensor_attn_q_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_GGML_TYPE], rax

.Ltensor_attn_q_type_recorded:
	cmp qword ptr [rsp + 64], 0
	je .Ltensor_attn_k_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_GGML_TYPE], rax

.Ltensor_attn_k_type_recorded:
	cmp qword ptr [rsp + 72], 0
	je .Ltensor_attn_v_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_GGML_TYPE], rax

.Ltensor_attn_v_type_recorded:
	cmp qword ptr [rsp + 80], 0
	je .Ltensor_attn_output_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_GGML_TYPE], rax

.Ltensor_attn_output_type_recorded:
	cmp qword ptr [rsp + 88], 0
	je .Ltensor_ffn_norm_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_GGML_TYPE], rax

.Ltensor_ffn_norm_type_recorded:
	cmp qword ptr [rsp + 96], 0
	je .Ltensor_ffn_gate_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_GGML_TYPE], rax

.Ltensor_ffn_gate_type_recorded:
	cmp qword ptr [rsp + 104], 0
	je .Ltensor_ffn_up_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_GGML_TYPE], rax

.Ltensor_ffn_up_type_recorded:
	cmp qword ptr [rsp + 112], 0
	je .Ltensor_ffn_down_type_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_GGML_TYPE], rax

.Ltensor_ffn_down_type_recorded:
	add r12, 4

	# Tensor offsets are relative to the aligned tensor-data section. Rejecting
	# misaligned offsets now catches malformed directories before any data load.
	cmp r12, r14
	ja .Ltensor_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 8
	jb .Ltensor_bad
	mov rax, qword ptr [r13 + r12]
	test rax, rax
	js .Ltensor_bad
	test al, GGUF_DEFAULT_ALIGNMENT - 1
	jnz .Ltensor_bad_alignment
	mov qword ptr [rsp + 40], rax
	cmp qword ptr [rsp + 16], 0
	je .Ltensor_lookup_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_LOOKUP_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_LOOKUP_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_lookup_recorded:
	cmp qword ptr [rsp + 48], 0
	je .Ltensor_attn_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_ATTN_NORM_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_ATTN_NORM_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_attn_recorded:
	cmp qword ptr [rsp + 56], 0
	je .Ltensor_attn_q_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_ATTN_Q_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_ATTN_Q_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_attn_q_recorded:
	cmp qword ptr [rsp + 64], 0
	je .Ltensor_attn_k_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_ATTN_K_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_ATTN_K_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_attn_k_recorded:
	cmp qword ptr [rsp + 72], 0
	je .Ltensor_attn_v_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_ATTN_V_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_ATTN_V_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_attn_v_recorded:
	cmp qword ptr [rsp + 80], 0
	je .Ltensor_attn_output_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_attn_output_recorded:
	cmp qword ptr [rsp + 88], 0
	je .Ltensor_ffn_norm_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_FFN_NORM_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_FFN_NORM_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_ffn_norm_recorded:
	cmp qword ptr [rsp + 96], 0
	je .Ltensor_ffn_gate_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_FFN_GATE_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_FFN_GATE_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_ffn_gate_recorded:
	cmp qword ptr [rsp + 104], 0
	je .Ltensor_ffn_up_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_FFN_UP_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_ffn_up_recorded:
	cmp qword ptr [rsp + 112], 0
	je .Ltensor_ffn_down_recorded
	mov rax, qword ptr [rsp + 40]
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_OFFSET], rax
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_FOUND], 1
	mov rdi, qword ptr [rsp + 24]
	mov rsi, qword ptr [rsp + 32]
	lea rdx, [r15 + GGUF_SUMMARY_FFN_DOWN_TENSOR_NAME]
	mov rcx, GGUF_SUMMARY_FFN_DOWN_TENSOR_NAME_CAP
	call gguf_copy_bytes_to_fixed

.Ltensor_ffn_down_recorded:
	mov rax, qword ptr [rsp + 40]
	cmp rbp, rax
	cmovb rbp, rax
	add r12, 8

	dec rbx
	jnz .Ltensor_loop

.Ltensor_align_data_start:
	# Tensor payload bytes start after padding the descriptor cursor to the GGUF
	# default alignment. This validates the data-section start without reading or
	# sizing tensor payloads yet.
	mov rax, r12
	add rax, GGUF_DEFAULT_ALIGNMENT - 1
	jc .Ltensor_bad
	and rax, -GGUF_DEFAULT_ALIGNMENT
	cmp rax, r14
	ja .Ltensor_bad
	# The directory stores offsets relative to this aligned data base. Requiring
	# the largest relative offset to be strictly smaller than the remaining file
	# bytes proves every payload start address is inside the mmap range.
	mov rdx, r14
	sub rdx, rax
	cmp rdx, rbp
	jbe .Ltensor_bad
	mov rdx, rax
	xor eax, eax
	jmp .Ltensor_epilogue

.Ltensor_empty_success:
	cmp r12, r14
	ja .Ltensor_bad
	mov rdx, r12
	xor eax, eax
	jmp .Ltensor_epilogue

.Ltensor_bad_alignment:
	mov eax, GGUF_ERR_TENSOR_ALIGNMENT
	jmp .Ltensor_epilogue

.Ltensor_bad:
	mov eax, GGUF_ERR_TENSOR_BOUNDS

.Ltensor_epilogue:
	add rsp, 120
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

.size gguf_walk_tensor_infos, . - gguf_walk_tensor_infos
