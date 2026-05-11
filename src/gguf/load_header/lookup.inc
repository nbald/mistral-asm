
.global gguf_lookup_tensor_info
.type gguf_lookup_tensor_info, @function

# Contract: rescan a validated GGUF tensor-info directory and capture one named
# tensor descriptor into a caller-provided generic descriptor slot.
# Inputs: rdi = mapping base, rsi = mapped file length, rdx = tensor-info
# directory start offset retained by gguf_validate_file, rcx = tensor count,
# r8 = requested tensor name bytes, r9 = requested tensor name byte length,
# r10 = pointer to a 160-byte descriptor slot laid out as found flag, 96-byte
# NUL-terminated name, n_dimensions, four u64 dimensions, ggml_type, and
# relative payload offset, and r11 = aligned tensor-data base offset retained by
# gguf_validate_file.
# Outputs: rax = GGUF_OK on success or a GGUF_ERR_TENSOR_* code. On success,
# the descriptor slot is zero-filled first, then its found flag is set to 1 and
# the descriptor fields are copied when the requested name is present. A missing
# name is not an error and leaves found = 0.
# Clobbers: caller-saved registers and flags. Preserves callee-saved registers
# it uses (rbx, rbp, r12, r13, r14).
# Ownership/lifetime: reads only from the caller-owned mapping and writes only
# the caller-provided descriptor slot. Captured names and dimensions are copied,
# so no mapped-file pointer is retained.
# Error behavior: malformed descriptor bounds return GGUF_ERR_TENSOR_BOUNDS;
# misaligned relative payload offsets return GGUF_ERR_TENSOR_ALIGNMENT. This
# helper is intended for mappings already accepted by gguf_validate_file, but it
# still bounds-checks every field it traverses before reading.
gguf_lookup_tensor_info:
	push rbp
	push rbx
	push r12
	push r13
	push r14
	sub rsp, 112

	mov r13, rdi
	mov r14, rsi
	mov r12, rdx
	mov rbx, rcx
	mov rbp, r10
	mov qword ptr [rsp], r8
	mov qword ptr [rsp + 8], r9
	mov qword ptr [rsp + 16], r11

	# The output slot is caller-owned scratch. Clear it up front so a clean
	# missing-name result is visible without depending on previous contents.
	mov rdi, rbp
	mov ecx, GGUF_TENSOR_SLOT_SIZE / 8
	xor eax, eax
.Llookup_clear_slot:
	mov qword ptr [rdi], rax
	add rdi, 8
	dec ecx
	jnz .Llookup_clear_slot

	# Empty tensor directories are valid synthetic fixtures and cannot contain a
	# match. The retained start cursor still must be inside the mapping.
	test rbx, rbx
	jz .Llookup_empty_success

	# Relative tensor payload offsets are meaningful only against the aligned
	# tensor-data base computed by the validating directory walk.
	mov rax, qword ptr [rsp + 16]
	cmp rax, r14
	ja .Llookup_bad
	mov rax, r14
	sub rax, qword ptr [rsp + 16]
	mov qword ptr [rsp + 24], rax

.Llookup_loop:
	# Tensor names are GGUF strings: u64 byte length followed by raw bytes.
	cmp r12, r14
	ja .Llookup_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 8
	jb .Llookup_bad
	mov r8, qword ptr [r13 + r12]
	test r8, r8
	js .Llookup_bad
	add r12, 8

	mov rax, r14
	sub rax, r12
	cmp rax, r8
	jb .Llookup_bad
	lea rax, [r13 + r12]
	mov qword ptr [rsp + 32], rax
	mov qword ptr [rsp + 40], r8
	add r12, r8

	# A zero-length request is treated as "lookup disabled"; it still walks the
	# directory for structural validation but can never set the found flag.
	mov qword ptr [rsp + 48], 0
	cmp qword ptr [rsp + 8], 0
	je .Llookup_name_compared
	mov rdi, qword ptr [rsp + 32]
	mov rsi, qword ptr [rsp + 40]
	mov rdx, qword ptr [rsp]
	mov rcx, qword ptr [rsp + 8]
	call gguf_bytes_eq_literal
	mov qword ptr [rsp + 48], rax

.Llookup_name_compared:
	# n_dimensions is a u32 followed by up to four u64 dimension sizes. Keep a
	# temporary descriptor on the stack until the matching entry's offset has
	# passed the same sign/alignment/bounds checks as the original walker.
	cmp r12, r14
	ja .Llookup_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Llookup_bad
	mov eax, dword ptr [r13 + r12]
	add r12, 4
	test eax, eax
	jz .Llookup_bad
	cmp eax, GGUF_MAX_DIMS
	ja .Llookup_bad
	mov qword ptr [rsp + 56], rax
	mov qword ptr [rsp + 64], 0
	mov qword ptr [rsp + 72], 0
	mov qword ptr [rsp + 80], 0
	mov qword ptr [rsp + 88], 0

	mov rcx, rax
	mov r11, rax
	shl r11, 3
	cmp r12, r14
	ja .Llookup_bad
	mov rax, r14
	sub rax, r12
	cmp rax, r11
	jb .Llookup_bad
	lea r8, [r13 + r12]
	xor edx, edx

.Llookup_dim_loop:
	cmp rdx, rcx
	je .Llookup_dims_done
	mov r10, qword ptr [r8 + rdx * 8]
	mov qword ptr [rsp + 64 + rdx * 8], r10
	inc rdx
	jmp .Llookup_dim_loop

.Llookup_dims_done:
	add r12, r11

	# Capture the raw ggml_type enum after checking the field is present.
	cmp r12, r14
	ja .Llookup_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Llookup_bad
	mov eax, dword ptr [r13 + r12]
	mov qword ptr [rsp + 96], rax
	add r12, 4

	# Relative payload offsets must be non-negative, GGUF-default-aligned, and
	# strictly inside the bytes remaining after the aligned tensor-data base.
	cmp r12, r14
	ja .Llookup_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 8
	jb .Llookup_bad
	mov rax, qword ptr [r13 + r12]
	test rax, rax
	js .Llookup_bad
	test al, GGUF_DEFAULT_ALIGNMENT - 1
	jnz .Llookup_bad_alignment
	cmp qword ptr [rsp + 24], rax
	jbe .Llookup_bad
	mov qword ptr [rsp + 104], rax
	add r12, 8

	cmp qword ptr [rsp + 48], 0
	je .Llookup_next

	mov qword ptr [rbp + GGUF_TENSOR_SLOT_FOUND], 1
	mov rdi, qword ptr [rsp + 32]
	mov rsi, qword ptr [rsp + 40]
	lea rdx, [rbp + GGUF_TENSOR_SLOT_NAME]
	mov rcx, GGUF_TENSOR_SLOT_NAME_CAP
	call gguf_copy_bytes_to_fixed

	mov rax, qword ptr [rsp + 56]
	mov qword ptr [rbp + GGUF_TENSOR_SLOT_N_DIMS], rax
	mov rax, qword ptr [rsp + 64]
	mov qword ptr [rbp + GGUF_TENSOR_SLOT_DIMS], rax
	mov rax, qword ptr [rsp + 72]
	mov qword ptr [rbp + GGUF_TENSOR_SLOT_DIMS + 8], rax
	mov rax, qword ptr [rsp + 80]
	mov qword ptr [rbp + GGUF_TENSOR_SLOT_DIMS + 16], rax
	mov rax, qword ptr [rsp + 88]
	mov qword ptr [rbp + GGUF_TENSOR_SLOT_DIMS + 24], rax
	mov rax, qword ptr [rsp + 96]
	mov qword ptr [rbp + GGUF_TENSOR_SLOT_GGML_TYPE], rax
	mov rax, qword ptr [rsp + 104]
	mov qword ptr [rbp + GGUF_TENSOR_SLOT_OFFSET], rax

.Llookup_next:
	dec rbx
	jnz .Llookup_loop

	# Cross-check that the caller-provided tensor-data base is the aligned cursor
	# reached by this rescan. A mismatch means the helper was called with stale
	# or unrelated summary state.
	mov rax, r12
	add rax, GGUF_DEFAULT_ALIGNMENT - 1
	jc .Llookup_bad
	and rax, -GGUF_DEFAULT_ALIGNMENT
	cmp rax, qword ptr [rsp + 16]
	jne .Llookup_bad
	xor eax, eax
	jmp .Llookup_epilogue

.Llookup_empty_success:
	cmp r12, r14
	ja .Llookup_bad
	xor eax, eax
	jmp .Llookup_epilogue

.Llookup_bad_alignment:
	mov eax, GGUF_ERR_TENSOR_ALIGNMENT
	jmp .Llookup_epilogue

.Llookup_bad:
	mov eax, GGUF_ERR_TENSOR_BOUNDS

.Llookup_epilogue:
	add rsp, 112
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

.size gguf_lookup_tensor_info, . - gguf_lookup_tensor_info
