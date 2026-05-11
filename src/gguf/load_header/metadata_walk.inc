
.type gguf_walk_metadata, @function

# Contract: advance over the GGUF metadata key/value array and retain selected
# small metadata values in the caller-owned summary.
# Inputs: rdi = mapping base, rsi = mapped file length, rdx = metadata start
# offset, rcx = metadata key/value count, r8 = summary buffer.
# Outputs: rax = GGUF_OK on success or a GGUF_ERR_METADATA_* code; rdx = tensor
# info directory start offset on success.
# Clobbers: caller-saved registers and flags. Preserves callee-saved registers
# it uses (rbx, r12, r13, r14, r15).
# Ownership/lifetime: reads only from the caller-owned mapping. Captured strings
# are copied into fixed-size caller-owned summary fields; captured array
# metadata keeps only the element count, so no mapped-file pointer is retained.
# Error behavior: returns malformed-metadata status before any out-of-bounds
# read; unsupported value tags return GGUF_ERR_METADATA_TYPE.
gguf_walk_metadata:
	push rbx
	push r12
	push r13
	push r14
	push r15

	mov r13, rdi
	mov r14, rsi
	mov r12, rdx
	mov rbx, rcx
	mov r15, r8

.Lmetadata_loop:
	test rbx, rbx
	jz .Lmetadata_done

	# Each metadata key is a GGUF string: u64 byte length followed by bytes.
	# Parse it here instead of calling gguf_skip_string so the key bytes can be
	# compared against names this milestone wants to retain.
	cmp r12, r14
	ja .Lmetadata_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 8
	jb .Lmetadata_bad
	mov r8, qword ptr [r13 + r12]
	test r8, r8
	js .Lmetadata_bad
	add r12, 8

	mov rax, r14
	sub rax, r12
	cmp rax, r8
	jb .Lmetadata_bad
	mov r10, r8
	# r9d is a small key-kind enum for values retained in the summary:
	# 0 = not retained, 1 = architecture, 2 = context_length, 3 = block_count,
	# 4 = vocab_size from tokenizer.ggml.tokens, 5 = RMSNorm epsilon f32.
	xor r9d, r9d
	lea rdi, [r13 + r12]
	mov rsi, r8
	lea rdx, [rip + general_architecture_key]
	mov rcx, general_architecture_key_end - general_architecture_key
	call gguf_bytes_eq_literal
	test eax, eax
	jz .Lmetadata_check_context_key
	mov r9d, 1
	jmp .Lmetadata_key_compared

.Lmetadata_check_context_key:
	lea rdi, [r13 + r12]
	mov rsi, r10
	lea rdx, [rip + mistral3_context_length_key]
	mov rcx, mistral3_context_length_key_end - mistral3_context_length_key
	call gguf_bytes_eq_literal
	test eax, eax
	jz .Lmetadata_check_block_key
	mov r9d, 2
	jmp .Lmetadata_key_compared

.Lmetadata_check_block_key:
	lea rdi, [r13 + r12]
	mov rsi, r10
	lea rdx, [rip + mistral3_block_count_key]
	mov rcx, mistral3_block_count_key_end - mistral3_block_count_key
	call gguf_bytes_eq_literal
	test eax, eax
	jz .Lmetadata_check_rms_epsilon_key
	mov r9d, 3
	jmp .Lmetadata_key_compared

.Lmetadata_check_rms_epsilon_key:
	lea rdi, [r13 + r12]
	mov rsi, r10
	lea rdx, [rip + mistral3_attn_norm_rms_epsilon_key]
	mov rcx, mistral3_attn_norm_rms_epsilon_key_end - mistral3_attn_norm_rms_epsilon_key
	call gguf_bytes_eq_literal
	test eax, eax
	jz .Lmetadata_check_tokens_key
	mov r9d, 5
	jmp .Lmetadata_key_compared

.Lmetadata_check_tokens_key:
	lea rdi, [r13 + r12]
	mov rsi, r10
	lea rdx, [rip + tokenizer_tokens_key]
	mov rcx, tokenizer_tokens_key_end - tokenizer_tokens_key
	call gguf_bytes_eq_literal
	test eax, eax
	jz .Lmetadata_key_compared
	mov r9d, 4

.Lmetadata_key_compared:
	add r12, r10

	# Values begin with a u32 type tag immediately after the key, with no padding.
	cmp r12, r14
	ja .Lmetadata_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Lmetadata_bad
	mov ecx, dword ptr [r13 + r12]
	add r12, 4

	cmp r9d, 1
	jne .Lmetadata_check_context_length
	cmp ecx, 8
	jne .Lmetadata_skip_value

	# general.architecture is a short GGUF string such as "mistral3". Copy a
	# bounded NUL-terminated snapshot so the summary survives after munmap.
	mov rdi, r13
	mov rsi, r14
	mov rdx, r12
	lea r8, [r15 + GGUF_SUMMARY_ARCHITECTURE]
	mov r9, GGUF_SUMMARY_ARCHITECTURE_CAP
	call gguf_capture_string_to_fixed
	test rax, rax
	jnz .Lmetadata_return
	mov r12, rdx
	jmp .Lmetadata_next

.Lmetadata_check_context_length:
	cmp r9d, 2
	jne .Lmetadata_check_block_count
	mov r8, GGUF_SUMMARY_CONTEXT_LENGTH
	jmp .Lmetadata_capture_unsigned_scalar

.Lmetadata_check_block_count:
	cmp r9d, 3
	jne .Lmetadata_check_rms_epsilon
	mov r8, GGUF_SUMMARY_BLOCK_COUNT

.Lmetadata_capture_unsigned_scalar:
	cmp ecx, 4
	je .Lmetadata_capture_scalar_u32
	cmp ecx, 10
	je .Lmetadata_capture_scalar_u64
	jmp .Lmetadata_skip_value

.Lmetadata_capture_scalar_u32:
	# Selected mistral3 shape metadata are unsigned scalars in the target file.
	# A u32 value is widened into the caller-owned u64 summary slot chosen above.
	cmp r12, r14
	ja .Lmetadata_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Lmetadata_bad
	mov eax, dword ptr [r13 + r12]
	mov qword ptr [r15 + r8], rax
	add r12, 4
	jmp .Lmetadata_next

.Lmetadata_capture_scalar_u64:
	# Keep the full u64 value; the summary printer already handles unsigned
	# decimal output.
	cmp r12, r14
	ja .Lmetadata_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 8
	jb .Lmetadata_bad
	mov rax, qword ptr [r13 + r12]
	mov qword ptr [r15 + r8], rax
	add r12, 8
	jmp .Lmetadata_next

.Lmetadata_check_rms_epsilon:
	cmp r9d, 5
	jne .Lmetadata_check_vocab_size
	cmp ecx, 6
	jne .Lmetadata_skip_value

	# The target GGUF stores the RMSNorm epsilon as GGUF float32. Retain the raw
	# IEEE-754 bits so the summary can be printed exactly and the smoke path can
	# pass the value to rmsnorm_f32 without inventing a process-local constant.
	cmp r12, r14
	ja .Lmetadata_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Lmetadata_bad
	mov eax, dword ptr [r13 + r12]
	mov dword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_RMS_EPSILON_F32], eax
	mov qword ptr [r15 + GGUF_SUMMARY_ATTN_NORM_RMS_EPSILON_FOUND], 1
	add r12, 4
	jmp .Lmetadata_next

.Lmetadata_check_vocab_size:
	cmp r9d, 4
	jne .Lmetadata_skip_value
	cmp ecx, 9
	jne .Lmetadata_skip_value

	# tokenizer.ggml.tokens is the vocabulary string array in the target GGUF.
	# Other array element types are structurally skipped but do not define the
	# tokenizer vocabulary size.
	cmp r12, r14
	ja .Lmetadata_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Lmetadata_bad
	cmp dword ptr [r13 + r12], 8
	jne .Lmetadata_skip_value

	# Retain only the array element count; token string bytes are merely walked
	# for bounds validation and remain owned by the mapped file.
	mov rdi, r13
	mov rsi, r14
	mov rdx, r12
	call gguf_skip_array
	test rax, rax
	jnz .Lmetadata_return
	mov qword ptr [r15 + GGUF_SUMMARY_VOCAB_SIZE], r8
	mov r12, rdx
	jmp .Lmetadata_next

.Lmetadata_skip_value:
	mov rdi, r13
	mov rsi, r14
	mov rdx, r12
	call gguf_skip_value_by_type
	test rax, rax
	jnz .Lmetadata_return
	mov r12, rdx

.Lmetadata_next:
	dec rbx
	jmp .Lmetadata_loop

.Lmetadata_done:
	# The tensor-info directory starts at this cursor. Return the handoff offset
	# so the caller can run the dedicated tensor-info walker with the same
	# mapping bounds.
	cmp r12, r14
	ja .Lmetadata_bad
	mov rdx, r12
	xor eax, eax
	jmp .Lmetadata_epilogue

.Lmetadata_bad:
	mov eax, GGUF_ERR_METADATA_BOUNDS

.Lmetadata_return:
.Lmetadata_epilogue:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	ret

.size gguf_walk_metadata, . - gguf_walk_metadata

.type gguf_bytes_eq_literal, @function

# Contract: compare checked in-file bytes against an assembler literal.
# Inputs: rdi = pointer to candidate bytes, rsi = candidate byte length,
# rdx = pointer to literal bytes, rcx = literal byte length.
# Outputs: rax = 1 when lengths and bytes match exactly, otherwise 0.
# Clobbers: rax, r8 and flags.
# Ownership/lifetime: reads both buffers only; does not retain pointers.
# Error behavior: none. Callers must bounds-check candidate bytes before use.
gguf_bytes_eq_literal:
	xor eax, eax
	cmp rsi, rcx
	jne .Lbytes_eq_done

.Lbytes_eq_loop:
	cmp rax, rcx
	je .Lbytes_eq_yes
	mov r8b, byte ptr [rdi + rax]
	cmp r8b, byte ptr [rdx + rax]
	jne .Lbytes_eq_no
	inc rax
	jmp .Lbytes_eq_loop

.Lbytes_eq_yes:
	mov eax, 1
	ret

.Lbytes_eq_no:
	xor eax, eax

.Lbytes_eq_done:
	ret

.size gguf_bytes_eq_literal, . - gguf_bytes_eq_literal

.type gguf_capture_string_to_fixed, @function

# Contract: validate one GGUF string value and copy a bounded NUL-terminated
# snapshot into caller-owned summary storage.
# Inputs: rdi = mapping base, rsi = mapped file length, rdx = string length
# field offset, r8 = destination buffer, r9 = destination capacity in bytes.
# Outputs: rax = GGUF_OK on success or GGUF_ERR_METADATA_BOUNDS; rdx = offset
# after the source string bytes on success.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: reads from the mapping and writes only to the destination
# buffer during this call. Long source strings are truncated to capacity - 1 so
# the destination remains NUL-terminated.
# Error behavior: rejects missing length fields, high-bit-set lengths, and
# source strings whose bytes would extend beyond the mapping.
gguf_capture_string_to_fixed:
	cmp rdx, rsi
	ja .Lcapture_bad
	mov rax, rsi
	sub rax, rdx
	cmp rax, 8
	jb .Lcapture_bad

	mov r10, qword ptr [rdi + rdx]
	test r10, r10
	js .Lcapture_bad
	add rdx, 8

	mov rax, rsi
	sub rax, rdx
	cmp rax, r10
	jb .Lcapture_bad
	mov r11, rdx
	add r11, r10

	# Copy at most capacity - 1 bytes, then write a terminator. The parser still
	# advances over the full source string even if the retained summary is
	# truncated.
	test r9, r9
	jz .Lcapture_advance_only
	mov rcx, r10
	mov rax, r9
	dec rax
	cmp rcx, rax
	cmova rcx, rax
	lea r10, [rdi + rdx]
	xor eax, eax

.Lcapture_copy_loop:
	cmp rax, rcx
	je .Lcapture_terminate
	mov r9b, byte ptr [r10 + rax]
	mov byte ptr [r8 + rax], r9b
	inc rax
	jmp .Lcapture_copy_loop

.Lcapture_terminate:
	mov byte ptr [r8 + rcx], 0

.Lcapture_advance_only:
	mov rdx, r11
	xor eax, eax
	ret

.Lcapture_bad:
	mov eax, GGUF_ERR_METADATA_BOUNDS
	ret

.size gguf_capture_string_to_fixed, . - gguf_capture_string_to_fixed

.type gguf_copy_bytes_to_fixed, @function

# Contract: copy checked bytes into fixed-size caller-owned storage as a bounded
# NUL-terminated string.
# Inputs: rdi = source byte pointer, rsi = source byte length, rdx =
# destination buffer, rcx = destination capacity in bytes.
# Outputs: none.
# Clobbers: rax, r8, r9 and flags.
# Ownership/lifetime: reads only the source byte range during this call and
# writes only to the destination buffer. Long source strings are truncated to
# capacity - 1 so the destination remains NUL-terminated.
# Error behavior: none. Callers must validate the source byte range and provide
# a real destination when capacity is non-zero.
gguf_copy_bytes_to_fixed:
	test rcx, rcx
	jz .Lcopy_bytes_done

	mov r8, rsi
	mov r9, rcx
	dec r9
	cmp r8, r9
	cmova r8, r9
	xor eax, eax

.Lcopy_bytes_loop:
	cmp rax, r8
	je .Lcopy_bytes_terminate
	mov r9b, byte ptr [rdi + rax]
	mov byte ptr [rdx + rax], r9b
	inc rax
	jmp .Lcopy_bytes_loop

.Lcopy_bytes_terminate:
	mov byte ptr [rdx + r8], 0

.Lcopy_bytes_done:
	ret

.size gguf_copy_bytes_to_fixed, . - gguf_copy_bytes_to_fixed
