
.section .text

.global gguf_validate_file
.type gguf_validate_file, @function

# Contract: validate the fixed GGUF header, metadata record bounds, and tensor
# descriptor directory shape for the narrow first loader.
# Inputs: rdi = pointer to a NUL-terminated model path; rsi = pointer to a
# caller-owned summary buffer with room for tensor_count at offset 0,
# metadata_kv_count at offset 8, a 32-byte NUL-terminated architecture string
# at offset 16, context_length as a u64 at offset 48, and block_count as a u64
# at offset 56, vocab_size as a u64 at offset 64, a 96-byte NUL-terminated
# first tensor name at offset 72, the first tensor's dimension count at offset
# 168, up to four u64 dimension sizes at offset 176, and the first tensor's
# ggml_type and relative payload offset as u64 values at offsets 208 and 216,
# followed by a one-name lookup descriptor slot beginning at offset 224, the
# aligned tensor-data base offset at offset 384, a fixed first-layer attention
# RMSNorm weight descriptor slot beginning at offset 392, a fixed first-layer
# query projection descriptor slot beginning at offset 552, a fixed first-layer
# key projection descriptor slot beginning at offset 712, a fixed first-layer
# value projection descriptor slot beginning at offset 872, a fixed first-layer
# attention output projection descriptor slot beginning at offset 1032, a fixed
# first-layer FFN RMSNorm weight descriptor slot beginning at offset 1192, a
# fixed first-layer FFN gate projection descriptor slot beginning at offset
# 1352, a fixed first-layer FFN up projection descriptor slot beginning at
# offset 1512, a fixed first-layer FFN down projection descriptor slot beginning
# at offset 1672, plus the attention RMSNorm epsilon found flag at offset 1832,
# raw f32 bits at offset 1840, and tensor-info directory start offset at offset
# 1848. rdx = pointer to the requested tensor name bytes; rcx = requested
# tensor name length; r8 = pointer to a 16-byte mapping descriptor whose first
# word receives the mmap base and whose second word receives the file size.
# Outputs: rax = GGUF_OK on success or one of the GGUF_ERR_* status codes above.
# Clobbers: caller-saved registers and flags. Preserves callee-saved registers
# it uses (rbx, r12, r13, r14, r15, rbp).
# Ownership/lifetime: opens the model read-only, mmaps the whole file privately,
# closes the file descriptor before returning, and transfers the live mapping to
# the caller on success through the mapping descriptor. Error paths release any
# mapping they created before returning. The summary buffer remains
# caller-owned; this function writes header counts, bounded metadata copies,
# selected scalar metadata, and selected array lengths into it, plus a bounded
# first tensor descriptor snapshot, the bounded descriptor for the requested
# tensor when found, the fixed `blk.0.attn_norm.weight` descriptor when found,
# the fixed `blk.0.attn_q.weight`, `blk.0.attn_k.weight`,
# `blk.0.attn_v.weight`, `blk.0.attn_output.weight`,
# `blk.0.ffn_norm.weight`, `blk.0.ffn_gate.weight`,
# `blk.0.ffn_up.weight`, and `blk.0.ffn_down.weight` descriptors when found,
# the attention RMSNorm epsilon metadata when found, the validated tensor-info
# directory start offset, and the aligned tensor-data base offset when the tensor
# directory is non-empty.
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
	# to keep a round size and read st_size at STAT_SIZE_OFFSET below, plus words
	# for the requested tensor name and output mapping descriptor passed through
	# later parser stages.
	sub rsp, STAT_BUFFER_SIZE + 32
	mov r15, rsi
	mov qword ptr [rsp + STAT_BUFFER_SIZE], rdx
	mov qword ptr [rsp + STAT_BUFFER_SIZE + 8], rcx
	mov qword ptr [rsp + STAT_BUFFER_SIZE + 16], r8
	mov qword ptr [r8 + GGUF_MAPPING_BASE], 0
	mov qword ptr [r8 + GGUF_MAPPING_SIZE], 0

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
	# Clear optional summary fields before capture so callers never see stale
	# bytes or scalar values when metadata keys are absent, wrong-typed, or when
	# the tensor directory is empty.
	lea rdi, [r15 + GGUF_SUMMARY_ARCHITECTURE]
	mov ecx, (GGUF_SUMMARY_SIZE - GGUF_SUMMARY_ARCHITECTURE) / 8
	xor eax, eax
.Lclear_optional_summary:
	mov qword ptr [rdi], rax
	add rdi, 8
	dec ecx
	jnz .Lclear_optional_summary

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
	mov qword ptr [r15 + GGUF_SUMMARY_TENSOR_INFOS_OFFSET], rdx

	# Tensor infos are also variable-width because names and dimension counts
	# vary per tensor. Retain the first descriptor in caller-owned storage, then
	# keep walking the rest with the same bounds and alignment checks.
	mov rdi, r13
	mov rsi, r12
	mov rcx, qword ptr [r15 + GGUF_SUMMARY_TENSOR_COUNT]
	mov r8, r15
	mov r9, qword ptr [rsp + STAT_BUFFER_SIZE]
	mov r10, qword ptr [rsp + STAT_BUFFER_SIZE + 8]
	call gguf_walk_tensor_infos
	test rax, rax
	jnz .Ltensor_failed
	cmp qword ptr [r15 + GGUF_SUMMARY_TENSOR_COUNT], 0
	je .Ltensor_data_base_recorded
	mov qword ptr [r15 + GGUF_SUMMARY_TENSOR_DATA_OFFSET], rdx

.Ltensor_data_base_recorded:

	# On success the validated read-only mapping is intentionally kept live for
	# the caller. Future forward code will read tensor payloads through this
	# descriptor before calling gguf_release_mapping.
	mov rax, qword ptr [rsp + STAT_BUFFER_SIZE + 16]
	mov qword ptr [rax + GGUF_MAPPING_BASE], r13
	mov qword ptr [rax + GGUF_MAPPING_SIZE], r12
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
	add rsp, STAT_BUFFER_SIZE + 32
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

.size gguf_validate_file, . - gguf_validate_file

.global gguf_release_mapping
.type gguf_release_mapping, @function

# Contract: release a GGUF mapping descriptor returned by gguf_validate_file.
# Inputs: rdi = pointer to a 16-byte descriptor with mmap base at offset 0 and
# mapping length/file size at offset 8.
# Outputs: rax = GGUF_OK on success or GGUF_ERR_MUNMAP when munmap(2) fails.
# Clobbers: caller-saved registers and flags. Preserves rbx.
# Ownership/lifetime: on success, releases the caller-owned read-only mapping
# and clears both descriptor words. A zero base or zero length is treated as an
# already-empty descriptor and is cleared without a syscall. On munmap failure,
# the descriptor is left intact because the mapping may still be live.
# Error behavior: returns a stable loader status code instead of raw errno.
gguf_release_mapping:
	push rbx
	mov rbx, rdi

	mov rdi, qword ptr [rbx + GGUF_MAPPING_BASE]
	mov rsi, qword ptr [rbx + GGUF_MAPPING_SIZE]
	test rdi, rdi
	jz .Lrelease_clear
	test rsi, rsi
	jz .Lrelease_clear

	call sys_munmap
	test rax, rax
	js .Lrelease_failed

.Lrelease_clear:
	mov qword ptr [rbx + GGUF_MAPPING_BASE], 0
	mov qword ptr [rbx + GGUF_MAPPING_SIZE], 0
	xor eax, eax
	jmp .Lrelease_done

.Lrelease_failed:
	mov eax, GGUF_ERR_MUNMAP

.Lrelease_done:
	pop rbx
	ret

.size gguf_release_mapping, . - gguf_release_mapping
