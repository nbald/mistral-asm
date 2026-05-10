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

.equ GGUF_OK, 0
.equ GGUF_ERR_OPEN, 1
.equ GGUF_ERR_FSTAT, 2
.equ GGUF_ERR_TOO_SMALL, 3
.equ GGUF_ERR_MMAP, 4
.equ GGUF_ERR_BAD_MAGIC, 5
.equ GGUF_ERR_BAD_VERSION, 6
.equ GGUF_ERR_MUNMAP, 7
.equ GGUF_ERR_BAD_COUNT, 8

.section .text

.global gguf_validate_file
.type gguf_validate_file, @function

# Contract: validate the fixed 24-byte GGUF header for the narrow first loader.
# Inputs: rdi = pointer to a NUL-terminated model path.
# Outputs: rax = GGUF_OK on success or one of the GGUF_ERR_* status codes above.
# Clobbers: caller-saved registers and flags. Preserves callee-saved registers
# it uses (rbx, r12, r13, r14, rbp).
# Ownership/lifetime: opens the model read-only, mmaps the whole file privately,
# and releases any descriptor/mapping before returning. The caller never owns the
# descriptor or mapping.
# Error behavior: syscall failures are collapsed into stable loader status codes;
# malformed magic/version/count fields are reported separately.
gguf_validate_file:
	push rbp
	mov rbp, rsp
	# rbx tracks the open file descriptor, r12 the file size, r13 the mapping
	# base, and r14d the status to return after cleanup.
	push rbx
	push r12
	push r13
	push r14
	# Linux x86-64 struct stat is 144 bytes on the target ABI. Reserve 160 bytes
	# to keep a round size and read st_size at STAT_SIZE_OFFSET below.
	sub rsp, STAT_BUFFER_SIZE

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
	mov rax, qword ptr [r13 + 16]
	test rax, rax
	js .Lbad_count

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
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

.size gguf_validate_file, . - gguf_validate_file

.section .note.GNU-stack,"",@progbits
