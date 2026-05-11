
.type gguf_skip_value_by_type, @function

# Contract: skip one GGUF metadata value payload after its u32 type tag has
# already been consumed.
# Inputs: rdi = mapping base, rsi = mapped file length, rdx = value payload
# offset, ecx = GGUF metadata value type.
# Outputs: rax = GGUF_OK on success or a metadata error; rdx = offset after the
# value on success.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: reads only enough bytes to compute the next offset.
# Error behavior: returns GGUF_ERR_METADATA_TYPE for unknown or intentionally
# unsupported type tags.
gguf_skip_value_by_type:
	cmp ecx, 8
	je .Lvalue_string
	cmp ecx, 9
	je .Lvalue_array

	call gguf_fixed_type_size
	test rax, rax
	jz .Lvalue_bad_type
	mov r8, rax
	call gguf_skip_fixed_bytes
	ret

.Lvalue_string:
	jmp gguf_skip_string

.Lvalue_array:
	jmp gguf_skip_array

.Lvalue_bad_type:
	mov eax, GGUF_ERR_METADATA_TYPE
	ret

.size gguf_skip_value_by_type, . - gguf_skip_value_by_type

.type gguf_fixed_type_size, @function

# Contract: classify fixed-width GGUF metadata scalar types.
# Inputs: ecx = GGUF metadata value type.
# Outputs: rax = byte width for fixed-width types, or 0 for string, array, or
# unknown types.
# Clobbers: rax and flags.
# Error behavior: none; callers decide whether a zero result is unsupported.
gguf_fixed_type_size:
	cmp ecx, 0
	je .Lfixed_1
	cmp ecx, 1
	je .Lfixed_1
	cmp ecx, 7
	je .Lfixed_1

	cmp ecx, 2
	je .Lfixed_2
	cmp ecx, 3
	je .Lfixed_2

	cmp ecx, 4
	je .Lfixed_4
	cmp ecx, 5
	je .Lfixed_4
	cmp ecx, 6
	je .Lfixed_4

	cmp ecx, 10
	je .Lfixed_8
	cmp ecx, 11
	je .Lfixed_8
	cmp ecx, 12
	je .Lfixed_8

	xor eax, eax
	ret

.Lfixed_1:
	mov eax, 1
	ret

.Lfixed_2:
	mov eax, 2
	ret

.Lfixed_4:
	mov eax, 4
	ret

.Lfixed_8:
	mov eax, 8
	ret

.size gguf_fixed_type_size, . - gguf_fixed_type_size

.type gguf_skip_fixed_bytes, @function

# Contract: advance an offset by a known byte count after proving the range fits
# inside the mapped file.
# Inputs: rsi = mapped file length, rdx = current offset, r8 = byte count.
# Outputs: rax = GGUF_OK on success or GGUF_ERR_METADATA_BOUNDS; rdx = advanced
# offset on success.
# Clobbers: rax, rdx and flags.
# Ownership/lifetime: performs arithmetic only; it does not read memory.
# Error behavior: rejects offsets beyond the file or byte counts larger than the
# remaining mapped range.
gguf_skip_fixed_bytes:
	cmp rdx, rsi
	ja .Lfixed_bytes_bad
	mov rax, rsi
	sub rax, rdx
	cmp rax, r8
	jb .Lfixed_bytes_bad
	add rdx, r8
	xor eax, eax
	ret

.Lfixed_bytes_bad:
	mov eax, GGUF_ERR_METADATA_BOUNDS
	ret

.size gguf_skip_fixed_bytes, . - gguf_skip_fixed_bytes

.type gguf_skip_string, @function

# Contract: skip one GGUF string.
# Inputs: rdi = mapping base, rsi = mapped file length, rdx = string length
# field offset.
# Outputs: rax = GGUF_OK on success or GGUF_ERR_METADATA_BOUNDS; rdx = offset
# after the string bytes on success.
# Clobbers: rax, r8, rdx and flags.
# Ownership/lifetime: reads the u64 length and skips the bytes; it does not
# retain the string pointer.
# Error behavior: rejects missing length fields, high-bit-set lengths, and
# strings whose bytes would extend beyond the mapping.
gguf_skip_string:
	cmp rdx, rsi
	ja .Lstring_bad
	mov rax, rsi
	sub rax, rdx
	cmp rax, 8
	jb .Lstring_bad

	mov r8, qword ptr [rdi + rdx]
	test r8, r8
	js .Lstring_bad
	add rdx, 8

	mov rax, rsi
	sub rax, rdx
	cmp rax, r8
	jb .Lstring_bad
	add rdx, r8
	xor eax, eax
	ret

.Lstring_bad:
	mov eax, GGUF_ERR_METADATA_BOUNDS
	ret

.size gguf_skip_string, . - gguf_skip_string

.type gguf_skip_array, @function

# Contract: skip one GGUF metadata array payload.
# Inputs: rdi = mapping base, rsi = mapped file length, rdx = array payload
# offset, where the array element type and element count begin.
# Outputs: rax = GGUF_OK on success or a metadata error; rdx = offset after the
# array on success; r8 = element count on success.
# Clobbers: caller-saved registers and flags. Preserves callee-saved registers
# it uses (rbx, r12, r13, r14, r15).
# Ownership/lifetime: reads only from the caller-owned mapping and keeps no
# pointers after returning.
# Error behavior: validates array headers and fixed-width byte spans. Variable
# string arrays are walked element by element. Nested arrays are rejected in this
# early narrow parser with GGUF_ERR_METADATA_TYPE.
gguf_skip_array:
	push rbx
	push r12
	push r13
	push r14
	push r15

	mov r13, rdi
	mov r14, rsi
	mov r12, rdx

	# Array payloads start with a u32 element type and a u64 element count.
	cmp r12, r14
	ja .Larray_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Larray_bad
	mov ebx, dword ptr [r13 + r12]
	add r12, 4

	cmp r12, r14
	ja .Larray_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 8
	jb .Larray_bad
	mov r15, qword ptr [r13 + r12]
	test r15, r15
	js .Larray_bad
	add r12, 8

	cmp ebx, 8
	je .Larray_strings
	cmp ebx, 9
	je .Larray_bad_type

	mov ecx, ebx
	call gguf_fixed_type_size
	test rax, rax
	jz .Larray_bad_type

	# Fixed-width arrays can be skipped as one checked byte span. The unsigned
	# multiply catches count * element_size overflow before the bounds check.
	mov r9, rax
	mov rax, r15
	mul r9
	test rdx, rdx
	jnz .Larray_bad
	mov r8, rax
	mov rsi, r14
	mov rdx, r12
	call gguf_skip_fixed_bytes
	test rax, rax
	jnz .Larray_return
	mov r12, rdx
	jmp .Larray_success

.Larray_strings:
	mov rbx, r15

.Larray_string_loop:
	test rbx, rbx
	jz .Larray_success
	mov rdi, r13
	mov rsi, r14
	mov rdx, r12
	call gguf_skip_string
	test rax, rax
	jnz .Larray_return
	mov r12, rdx
	dec rbx
	jmp .Larray_string_loop

.Larray_success:
	mov rdx, r12
	mov r8, r15
	xor eax, eax
	jmp .Larray_epilogue

.Larray_bad_type:
	mov eax, GGUF_ERR_METADATA_TYPE
	jmp .Larray_epilogue

.Larray_bad:
	mov eax, GGUF_ERR_METADATA_BOUNDS

.Larray_return:
.Larray_epilogue:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	ret

.size gguf_skip_array, . - gguf_skip_array
