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

gguf_validate_file:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	sub rsp, STAT_BUFFER_SIZE

	mov rsi, rdi
	mov rdi, AT_FDCWD
	mov rdx, O_RDONLY
	xor r10d, r10d
	call sys_openat
	test rax, rax
	js .Lopen_failed
	mov rbx, rax

	mov rdi, rbx
	lea rsi, [rsp]
	call sys_fstat
	test rax, rax
	js .Lfstat_failed

	mov r12, qword ptr [rsp + STAT_SIZE_OFFSET]
	cmp r12, GGUF_HEADER_SIZE
	jb .Ltoo_small

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

	cmp dword ptr [r13], GGUF_MAGIC_LE
	jne .Lbad_magic
	cmp dword ptr [r13 + 4], GGUF_VERSION_SUPPORTED
	jne .Lbad_version
	mov rax, qword ptr [r13 + 8]
	test rax, rax
	js .Lbad_count
	mov rax, qword ptr [r13 + 16]
	test rax, rax
	js .Lbad_count

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
	mov rdi, r13
	mov rsi, r12
	call sys_munmap
	jmp .Lclose_with_code

.Lmunmap_failed:
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
	mov rdi, rbx
	call sys_close
	mov eax, r14d
	jmp .Ldone

.Lopen_failed:
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
