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
.equ GGUF_SUMMARY_CONTEXT_LENGTH, 48
.equ GGUF_SUMMARY_BLOCK_COUNT, 56
.equ GGUF_SUMMARY_VOCAB_SIZE, 64
.equ GGUF_SUMMARY_FIRST_TENSOR_NAME, 72
.equ GGUF_SUMMARY_FIRST_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_FIRST_TENSOR_N_DIMS, 168
.equ GGUF_SUMMARY_FIRST_TENSOR_DIMS, 176
.equ GGUF_SUMMARY_FIRST_TENSOR_GGML_TYPE, 208
.equ GGUF_SUMMARY_FIRST_TENSOR_OFFSET, 216
.equ GGUF_SUMMARY_LOOKUP_TENSOR_FOUND, 224
.equ GGUF_SUMMARY_LOOKUP_TENSOR_NAME, 232
.equ GGUF_SUMMARY_LOOKUP_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_LOOKUP_TENSOR_N_DIMS, 328
.equ GGUF_SUMMARY_LOOKUP_TENSOR_DIMS, 336
.equ GGUF_SUMMARY_LOOKUP_TENSOR_GGML_TYPE, 368
.equ GGUF_SUMMARY_LOOKUP_TENSOR_OFFSET, 376
.equ GGUF_SUMMARY_TENSOR_DATA_OFFSET, 384
.equ GGUF_SUMMARY_ATTN_NORM_TENSOR_FOUND, 392
.equ GGUF_SUMMARY_ATTN_NORM_TENSOR_NAME, 400
.equ GGUF_SUMMARY_ATTN_NORM_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_ATTN_NORM_TENSOR_N_DIMS, 496
.equ GGUF_SUMMARY_ATTN_NORM_TENSOR_DIMS, 504
.equ GGUF_SUMMARY_ATTN_NORM_TENSOR_GGML_TYPE, 536
.equ GGUF_SUMMARY_ATTN_NORM_TENSOR_OFFSET, 544
.equ GGUF_SUMMARY_ATTN_Q_TENSOR_FOUND, 552
.equ GGUF_SUMMARY_ATTN_Q_TENSOR_NAME, 560
.equ GGUF_SUMMARY_ATTN_Q_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_ATTN_Q_TENSOR_N_DIMS, 656
.equ GGUF_SUMMARY_ATTN_Q_TENSOR_DIMS, 664
.equ GGUF_SUMMARY_ATTN_Q_TENSOR_GGML_TYPE, 696
.equ GGUF_SUMMARY_ATTN_Q_TENSOR_OFFSET, 704
.equ GGUF_SUMMARY_ATTN_K_TENSOR_FOUND, 712
.equ GGUF_SUMMARY_ATTN_K_TENSOR_NAME, 720
.equ GGUF_SUMMARY_ATTN_K_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_ATTN_K_TENSOR_N_DIMS, 816
.equ GGUF_SUMMARY_ATTN_K_TENSOR_DIMS, 824
.equ GGUF_SUMMARY_ATTN_K_TENSOR_GGML_TYPE, 856
.equ GGUF_SUMMARY_ATTN_K_TENSOR_OFFSET, 864
.equ GGUF_SUMMARY_ATTN_V_TENSOR_FOUND, 872
.equ GGUF_SUMMARY_ATTN_V_TENSOR_NAME, 880
.equ GGUF_SUMMARY_ATTN_V_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_ATTN_V_TENSOR_N_DIMS, 976
.equ GGUF_SUMMARY_ATTN_V_TENSOR_DIMS, 984
.equ GGUF_SUMMARY_ATTN_V_TENSOR_GGML_TYPE, 1016
.equ GGUF_SUMMARY_ATTN_V_TENSOR_OFFSET, 1024
.equ GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_FOUND, 1032
.equ GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_NAME, 1040
.equ GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_N_DIMS, 1136
.equ GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_DIMS, 1144
.equ GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_GGML_TYPE, 1176
.equ GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_OFFSET, 1184
.equ GGUF_SUMMARY_FFN_NORM_TENSOR_FOUND, 1192
.equ GGUF_SUMMARY_FFN_NORM_TENSOR_NAME, 1200
.equ GGUF_SUMMARY_FFN_NORM_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_FFN_NORM_TENSOR_N_DIMS, 1296
.equ GGUF_SUMMARY_FFN_NORM_TENSOR_DIMS, 1304
.equ GGUF_SUMMARY_FFN_NORM_TENSOR_GGML_TYPE, 1336
.equ GGUF_SUMMARY_FFN_NORM_TENSOR_OFFSET, 1344
.equ GGUF_SUMMARY_FFN_GATE_TENSOR_FOUND, 1352
.equ GGUF_SUMMARY_FFN_GATE_TENSOR_NAME, 1360
.equ GGUF_SUMMARY_FFN_GATE_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_FFN_GATE_TENSOR_N_DIMS, 1456
.equ GGUF_SUMMARY_FFN_GATE_TENSOR_DIMS, 1464
.equ GGUF_SUMMARY_FFN_GATE_TENSOR_GGML_TYPE, 1496
.equ GGUF_SUMMARY_FFN_GATE_TENSOR_OFFSET, 1504
.equ GGUF_SUMMARY_FFN_UP_TENSOR_FOUND, 1512
.equ GGUF_SUMMARY_FFN_UP_TENSOR_NAME, 1520
.equ GGUF_SUMMARY_FFN_UP_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_FFN_UP_TENSOR_N_DIMS, 1616
.equ GGUF_SUMMARY_FFN_UP_TENSOR_DIMS, 1624
.equ GGUF_SUMMARY_FFN_UP_TENSOR_GGML_TYPE, 1656
.equ GGUF_SUMMARY_FFN_UP_TENSOR_OFFSET, 1664
.equ GGUF_SUMMARY_ATTN_NORM_RMS_EPSILON_FOUND, 1672
.equ GGUF_SUMMARY_ATTN_NORM_RMS_EPSILON_F32, 1680
.equ GGUF_SUMMARY_SIZE, 1688
.equ GGUF_MAPPING_BASE, 0
.equ GGUF_MAPPING_SIZE, 8

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

mistral3_context_length_key:
	.ascii "mistral3.context_length"
mistral3_context_length_key_end:

mistral3_block_count_key:
	.ascii "mistral3.block_count"
mistral3_block_count_key_end:

mistral3_attn_norm_rms_epsilon_key:
	.ascii "mistral3.attention.layer_norm_rms_epsilon"
mistral3_attn_norm_rms_epsilon_key_end:

tokenizer_tokens_key:
	.ascii "tokenizer.ggml.tokens"
tokenizer_tokens_key_end:

attn_norm_tensor_request:
	.ascii "blk.0.attn_norm.weight"
attn_norm_tensor_request_end:

attn_q_tensor_request:
	.ascii "blk.0.attn_q.weight"
attn_q_tensor_request_end:

attn_k_tensor_request:
	.ascii "blk.0.attn_k.weight"
attn_k_tensor_request_end:

attn_v_tensor_request:
	.ascii "blk.0.attn_v.weight"
attn_v_tensor_request_end:

attn_output_tensor_request:
	.ascii "blk.0.attn_output.weight"
attn_output_tensor_request_end:

ffn_norm_tensor_request:
	.ascii "blk.0.ffn_norm.weight"
ffn_norm_tensor_request_end:

ffn_gate_tensor_request:
	.ascii "blk.0.ffn_gate.weight"
ffn_gate_tensor_request_end:

ffn_up_tensor_request:
	.ascii "blk.0.ffn_up.weight"
ffn_up_tensor_request_end:

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
# offset 1512, plus the attention RMSNorm epsilon found flag at offset 1672 and
# raw f32 bits at offset 1680. rdx = pointer to the requested tensor name bytes; rcx = requested tensor
# name length; r8 = pointer to a 16-byte mapping descriptor whose first word
# receives the mmap base and whose second word receives the file size.
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
# `blk.0.ffn_norm.weight`, `blk.0.ffn_gate.weight`, and
# `blk.0.ffn_up.weight` descriptors when found,
# the attention RMSNorm epsilon metadata when found, and the aligned tensor-data
# base offset when the tensor directory is non-empty.
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

.type gguf_walk_tensor_infos, @function

# Contract: advance over the GGUF tensor-info directory, retain a bounded
# snapshot of the first descriptor, retain a bounded descriptor snapshot for one
# requested tensor name when it is present, and retain the fixed first-layer
# attention RMSNorm weight, query projection, key projection, value projection,
# attention output projection, FFN RMSNorm weight, FFN gate projection, and FFN
# up projection descriptors when present.
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
	je .Ltensor_first_dim_next
	mov qword ptr [r15 + GGUF_SUMMARY_FFN_UP_TENSOR_DIMS + rdx * 8], r10

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
	je .Ltensor_dims_done
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

.Ltensor_dims_done:
	add r12, r8

	# Tensor type tags are consumed for every descriptor and retained only for a
	# requested-name or fixed attention descriptor match. The bounds check keeps
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

.section .note.GNU-stack,"",@progbits
