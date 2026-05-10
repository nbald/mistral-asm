.intel_syntax noprefix

.equ AT_FDCWD, -100
.equ O_RDONLY, 0
.equ PROT_READ, 1
.equ MAP_PRIVATE, 2
.equ GGUF_HEADER_SIZE, 24
.equ STAT_SIZE_OFFSET, 48
.equ STAT_BUFFER_SIZE, 160
.equ GGUF_MAGIC_LE, 0x46554747
.equ GGUF_VERSION_SUPPORTED, 3
.equ GGUF_DEFAULT_ALIGNMENT, 32
.equ GGUF_MAX_DIMS, 4
.equ GGUF_SUMMARY_TENSOR_COUNT, 0
.equ GGUF_SUMMARY_METADATA_COUNT, 8
.equ GGUF_SUMMARY_ARCHITECTURE, 16
.equ GGUF_SUMMARY_ARCHITECTURE_CAP, 32

.equ GGUF_OK, 0
.equ GGUF_ERR_OPEN, 1
.equ GGUF_ERR_FSTAT, 2
.equ GGUF_ERR_TOO_SMALL, 3
.equ GGUF_ERR_MMAP, 4
.equ GGUF_ERR_BAD_MAGIC, 5
.equ GGUF_ERR_BAD_VERSION, 6
.equ GGUF_ERR_MUNMAP, 7
.equ GGUF_ERR_BAD_COUNT, 8
.equ GGUF_ERR_METADATA_BOUNDS, 9
.equ GGUF_ERR_METADATA_TYPE, 10
.equ GGUF_ERR_TENSOR_BOUNDS, 11
.equ GGUF_ERR_TENSOR_ALIGNMENT, 12

.section .rodata

general_architecture_key:
	.ascii "general.architecture"
general_architecture_key_end:

.section .text

.global gguf_validate_file
.type gguf_validate_file, @function

# Contract: validate the fixed GGUF header, metadata record bounds, and tensor
# descriptor directory shape for the narrow first loader.
# Inputs: rdi = pointer to a NUL-terminated model path; rsi = pointer to a
# caller-owned summary buffer with room for tensor_count at offset 0,
# metadata_kv_count at offset 8, and a 32-byte NUL-terminated architecture
# string at offset 16.
# Outputs: rax = GGUF_OK on success or one of the GGUF_ERR_* status codes above.
# Clobbers: caller-saved registers and flags. Preserves callee-saved registers
# it uses (rbx, r12, r13, r14, r15, rbp).
# Ownership/lifetime: opens the model read-only, mmaps the whole file privately,
# and releases any descriptor/mapping before returning. The caller never owns the
# descriptor or mapping. The summary buffer remains caller-owned; this function
# writes header counts and bounded metadata copies into it.
# Error behavior: syscall failures are collapsed into stable loader status codes;
# malformed magic/version/count fields, unsupported metadata shapes, malformed
# tensor descriptors, and tensor-data alignment failures are reported separately.
gguf_validate_file:
	push rbp
	mov rbp, rsp
	# rbx tracks the open file descriptor, r12 the file size, r13 the mapping
	# base, and r14d the status to return after cleanup.
	push rbx
	push r12
	push r13
	push r14
	push r15
	# Linux x86-64 struct stat is 144 bytes on the target ABI. Reserve 160 bytes
	# to keep a round size and read st_size at STAT_SIZE_OFFSET below.
	sub rsp, STAT_BUFFER_SIZE
	mov r15, rsi

	# openat(AT_FDCWD, path, O_RDONLY, 0). Using openat keeps all file opens in
	# one syscall wrapper; mode is ignored without O_CREAT but is passed as 0.
	mov rsi, rdi
	mov rdi, AT_FDCWD
	mov rdx, O_RDONLY
	xor r10d, r10d
	call sys_openat
	test rax, rax
	js .Lopen_failed
	mov rbx, rax

	# fstat fills the stack buffer. Later parser code needs the file size for
	# mmap length and for bounds checks while walking metadata.
	mov rdi, rbx
	lea rsi, [rsp]
	call sys_fstat
	test rax, rax
	js .Lfstat_failed

	# st_size is a signed off_t. Reject files smaller than the fixed header
	# before any mmap attempt.
	mov r12, qword ptr [rsp + STAT_SIZE_OFFSET]
	cmp r12, GGUF_HEADER_SIZE
	jb .Ltoo_small

	# mmap(NULL, file_size, PROT_READ, MAP_PRIVATE, fd, 0). A private read-only
	# mapping is enough for parser reads and keeps ownership local to this call.
	xor edi, edi
	mov rsi, r12
	mov edx, PROT_READ
	mov r10d, MAP_PRIVATE
	mov r8, rbx
	xor r9d, r9d
	call sys_mmap
	test rax, rax
	js .Lmmap_failed
	mov r13, rax

	# GGUF stores little-endian fixed fields: magic at 0, version at 4,
	# tensor_count at 8, metadata_kv_count at 16. This runtime currently accepts
	# only v3 little-endian files.
	cmp dword ptr [r13], GGUF_MAGIC_LE
	jne .Lbad_magic
	cmp dword ptr [r13 + 4], GGUF_VERSION_SUPPORTED
	jne .Lbad_version
	# Treat high-bit-set u64 counts as unsupported for now. Keeping counts within
	# the signed positive range simplifies early parser arithmetic and bounds
	# checks until the metadata walker is mature.
	mov rax, qword ptr [r13 + 8]
	test rax, rax
	js .Lbad_count
	mov rdx, qword ptr [r13 + 16]
	test rdx, rdx
	js .Lbad_count
	# Copy the validated header counts into caller-owned storage before the
	# variable-width walkers consume the same values. No mapped-file pointer
	# escapes through this summary.
	mov qword ptr [r15 + GGUF_SUMMARY_TENSOR_COUNT], rax
	mov qword ptr [r15 + GGUF_SUMMARY_METADATA_COUNT], rdx
	# Clear optional string fields before metadata capture so callers never see
	# stale bytes when a key is absent or has a non-string value.
	mov qword ptr [r15 + GGUF_SUMMARY_ARCHITECTURE], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ARCHITECTURE + 8], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ARCHITECTURE + 16], 0
	mov qword ptr [r15 + GGUF_SUMMARY_ARCHITECTURE + 24], 0

	# Metadata records are variable-width. Walk them with offset arithmetic
	# against the mapped file length so every later load is preceded by an
	# explicit bounds check. GGUF tensor infos start immediately at the cursor
	# after metadata.
	mov rdi, r13
	mov rsi, r12
	mov rdx, GGUF_HEADER_SIZE
	mov rcx, qword ptr [r15 + GGUF_SUMMARY_METADATA_COUNT]
	mov r8, r15
	call gguf_walk_metadata
	test rax, rax
	jnz .Lmetadata_failed

	# Tensor infos are also variable-width because names and dimension counts
	# vary per tensor. This pass only validates descriptor layout and the default
	# 32-byte tensor-data alignment used by the target model family; it does not
	# retain names, shapes, types, or offsets yet.
	mov rdi, r13
	mov rsi, r12
	mov rcx, qword ptr [r15 + GGUF_SUMMARY_TENSOR_COUNT]
	call gguf_walk_tensor_infos
	test rax, rax
	jnz .Ltensor_failed

	# The success path also unmaps before closing; no mapped pointer escapes.
	mov rdi, r13
	mov rsi, r12
	call sys_munmap
	test rax, rax
	js .Lmunmap_failed

	mov r14d, GGUF_OK
	jmp .Lclose_with_code

.Lbad_magic:
	mov r14d, GGUF_ERR_BAD_MAGIC
	jmp .Lunmap_with_code

.Lbad_version:
	mov r14d, GGUF_ERR_BAD_VERSION
	jmp .Lunmap_with_code

.Lbad_count:
	mov r14d, GGUF_ERR_BAD_COUNT
	jmp .Lunmap_with_code

.Lmetadata_failed:
	mov r14d, eax
	jmp .Lunmap_with_code

.Ltensor_failed:
	mov r14d, eax
	jmp .Lunmap_with_code

.Lunmap_with_code:
	# Preserve the original validation error in r14d. A munmap failure on this
	# path is ignored because the malformed-file reason is more useful to report.
	mov rdi, r13
	mov rsi, r12
	call sys_munmap
	jmp .Lclose_with_code

.Lmunmap_failed:
	# A cleanup failure after a valid header gets its own status so the caller
	# does not claim success when the mapping could not be released.
	mov r14d, GGUF_ERR_MUNMAP
	jmp .Lclose_with_code

.Lmmap_failed:
	mov r14d, GGUF_ERR_MMAP
	jmp .Lclose_with_code

.Ltoo_small:
	mov r14d, GGUF_ERR_TOO_SMALL
	jmp .Lclose_with_code

.Lfstat_failed:
	mov r14d, GGUF_ERR_FSTAT
	jmp .Lclose_with_code

.Lclose_with_code:
	# Close is best-effort in this milestone; the stable parse/open/map status in
	# r14d is what _start reports to users.
	mov rdi, rbx
	call sys_close
	mov eax, r14d
	jmp .Ldone

.Lopen_failed:
	# No descriptor exists when openat fails, so skip shared cleanup.
	mov eax, GGUF_ERR_OPEN

.Ldone:
	add rsp, STAT_BUFFER_SIZE
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

.size gguf_validate_file, . - gguf_validate_file

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
# are copied into fixed-size caller-owned summary fields; no mapped-file pointer
# is retained.
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
	lea rdi, [r13 + r12]
	mov rsi, r8
	lea rdx, [rip + general_architecture_key]
	mov rcx, general_architecture_key_end - general_architecture_key
	call gguf_bytes_eq_literal
	mov r9d, eax
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

	test r9d, r9d
	jz .Lmetadata_skip_value
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

.type gguf_walk_tensor_infos, @function

# Contract: advance over the GGUF tensor-info directory without retaining
# descriptor fields.
# Inputs: rdi = mapping base, rsi = mapped file length, rdx = tensor-info start
# offset, rcx = tensor count from the GGUF header.
# Outputs: rax = GGUF_OK on success or a GGUF_ERR_TENSOR_* code; rdx = aligned
# tensor-data start offset on success when tensors exist, or the unchanged cursor
# when tensor_count is zero.
# Clobbers: caller-saved registers and flags. Preserves callee-saved registers
# it uses (rbx, r12, r13, r14, r15).
# Ownership/lifetime: reads only from the caller-owned mapping and stores no
# pointers into it.
# Error behavior: returns malformed-tensor status before any out-of-bounds read.
# Tensor payload offsets with the high bit set or not divisible by the current
# default alignment are rejected in this narrow parser.
gguf_walk_tensor_infos:
	push rbx
	push r12
	push r13
	push r14
	push r15

	mov r13, rdi
	mov r14, rsi
	mov r12, rdx
	mov rbx, rcx

	# A no-tensor synthetic fixture has no tensor-data section to align. It is
	# still useful for header/metadata smoke tests, so leave the cursor unchanged.
	test rbx, rbx
	jz .Ltensor_empty_success

.Ltensor_loop:
	# Tensor names use the same GGUF string encoding as metadata keys: u64 byte
	# length followed by raw bytes, with no padding before the dimension count.
	mov rdi, r13
	mov rsi, r14
	mov rdx, r12
	call gguf_skip_string
	test rax, rax
	jnz .Ltensor_bad
	mov r12, rdx

	# n_dimensions is a u32 followed by that many u64 dimension sizes. GGUF
	# tensors are capped by GGML_MAX_DIMS, four dimensions in this target format.
	cmp r12, r14
	ja .Ltensor_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Ltensor_bad
	mov r15d, dword ptr [r13 + r12]
	add r12, 4
	test r15d, r15d
	jz .Ltensor_bad
	cmp r15d, GGUF_MAX_DIMS
	ja .Ltensor_bad

	mov r8, r15
	shl r8, 3
	mov rsi, r14
	mov rdx, r12
	call gguf_skip_fixed_bytes
	test rax, rax
	jnz .Ltensor_bad
	mov r12, rdx

	# The u32 ggml_type tag is consumed but not interpreted in this milestone.
	# Later tensor-directory work will record and validate supported tensor types.
	cmp r12, r14
	ja .Ltensor_bad
	mov rax, r14
	sub rax, r12
	cmp rax, 4
	jb .Ltensor_bad
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
	add r12, 8

	dec rbx
	jnz .Ltensor_loop

	# Tensor payload bytes start after padding the descriptor cursor to the GGUF
	# default alignment. This validates the data-section start without reading or
	# sizing tensor payloads yet.
	mov rax, r12
	add rax, GGUF_DEFAULT_ALIGNMENT - 1
	jc .Ltensor_bad
	and rax, -GGUF_DEFAULT_ALIGNMENT
	cmp rax, r14
	ja .Ltensor_bad
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
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	ret

.size gguf_walk_tensor_infos, . - gguf_walk_tensor_infos

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
# array on success.
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

.section .note.GNU-stack,"",@progbits
