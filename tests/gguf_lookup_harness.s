.intel_syntax noprefix

.equ GGUF_OK, 0
.equ GGUF_ERR_TENSOR_ALIGNMENT, 12
.equ GGUF_TENSOR_SLOT_FOUND, 0
.equ GGUF_TENSOR_SLOT_NAME, 8
.equ GGUF_TENSOR_SLOT_N_DIMS, 104
.equ GGUF_TENSOR_SLOT_DIMS, 112
.equ GGUF_TENSOR_SLOT_GGML_TYPE, 144
.equ GGUF_TENSOR_SLOT_OFFSET, 152
.equ GGUF_TENSOR_SLOT_SIZE, 160

.section .rodata

ok_text:
	.ascii "gguf_lookup: ok\n"
ok_text_end:

fail1_text:
	.ascii "gguf_lookup: fixture 1 failed\n"
fail1_text_end:

fail2_text:
	.ascii "gguf_lookup: fixture 2 failed\n"
fail2_text_end:

fail3_text:
	.ascii "gguf_lookup: fixture 3 failed\n"
fail3_text_end:

target_name:
	.ascii "target.weight"
target_name_end:

missing_name:
	.ascii "missing.weight"
missing_name_end:

.balign 32
valid_tensor_infos:
	.quad valid_name0_end - valid_name0
valid_name0:
	.ascii "foo.weight"
valid_name0_end:
	.long 1
	.quad 7
	.long 42
	.quad 0

	.quad valid_name1_end - valid_name1
valid_name1:
	.ascii "target.weight"
valid_name1_end:
	.long 2
	.quad 5
	.quad 3
	.long 7
	.quad 32

.balign 32
valid_tensor_data:
	.skip 64
valid_mapping_end:

.balign 32
bad_alignment_tensor_infos:
	.quad bad_alignment_name_end - bad_alignment_name
bad_alignment_name:
	.ascii "target.weight"
bad_alignment_name_end:
	.long 1
	.quad 1
	.long 7
	.quad 1

.balign 32
bad_alignment_tensor_data:
	.skip 64
bad_alignment_mapping_end:

.section .bss

.balign 8
lookup_slot:
	.skip GGUF_TENSOR_SLOT_SIZE

.section .text

.global _start
.type _start, @function

# Contract: standalone assembly harness for gguf_lookup_tensor_info.
# Inputs: Linux process entry stack is ignored.
# Outputs: writes one pass/fail line and exits with status 0 on success, or the
# failed fixture number on exact descriptor, absent-name, or malformed-offset
# failure.
# Clobbers: all general-purpose registers may be clobbered; no caller exists.
# Ownership/lifetime: reads static synthetic tensor-info directories and writes
# a process-owned static descriptor slot. No external resources are opened.
# Error behavior: the first failing fixture prints a diagnostic to stderr.
_start:
	# Fixture 1: find the second descriptor and copy its generic slot fields.
	lea rdi, [rip + valid_tensor_infos]
	mov rsi, valid_mapping_end - valid_tensor_infos
	xor edx, edx
	mov ecx, 2
	lea r8, [rip + target_name]
	mov r9, target_name_end - target_name
	lea r10, [rip + lookup_slot]
	mov r11, valid_tensor_data - valid_tensor_infos
	call gguf_lookup_tensor_info
	cmp rax, GGUF_OK
	jne .Lfail1
	cmp qword ptr [rip + lookup_slot + GGUF_TENSOR_SLOT_FOUND], 1
	jne .Lfail1
	cmp byte ptr [rip + lookup_slot + GGUF_TENSOR_SLOT_NAME], 't'
	jne .Lfail1
	cmp byte ptr [rip + lookup_slot + GGUF_TENSOR_SLOT_NAME + 13], 0
	jne .Lfail1
	cmp qword ptr [rip + lookup_slot + GGUF_TENSOR_SLOT_N_DIMS], 2
	jne .Lfail1
	cmp qword ptr [rip + lookup_slot + GGUF_TENSOR_SLOT_DIMS], 5
	jne .Lfail1
	cmp qword ptr [rip + lookup_slot + GGUF_TENSOR_SLOT_DIMS + 8], 3
	jne .Lfail1
	cmp qword ptr [rip + lookup_slot + GGUF_TENSOR_SLOT_DIMS + 16], 0
	jne .Lfail1
	cmp qword ptr [rip + lookup_slot + GGUF_TENSOR_SLOT_GGML_TYPE], 7
	jne .Lfail1
	cmp qword ptr [rip + lookup_slot + GGUF_TENSOR_SLOT_OFFSET], 32
	jne .Lfail1

	# Fixture 2: an absent name succeeds and clears stale descriptor contents.
	lea rdi, [rip + valid_tensor_infos]
	mov rsi, valid_mapping_end - valid_tensor_infos
	xor edx, edx
	mov ecx, 2
	lea r8, [rip + missing_name]
	mov r9, missing_name_end - missing_name
	lea r10, [rip + lookup_slot]
	mov r11, valid_tensor_data - valid_tensor_infos
	call gguf_lookup_tensor_info
	cmp rax, GGUF_OK
	jne .Lfail2
	cmp qword ptr [rip + lookup_slot + GGUF_TENSOR_SLOT_FOUND], 0
	jne .Lfail2
	cmp byte ptr [rip + lookup_slot + GGUF_TENSOR_SLOT_NAME], 0
	jne .Lfail2
	cmp qword ptr [rip + lookup_slot + GGUF_TENSOR_SLOT_OFFSET], 0
	jne .Lfail2

	# Fixture 3: a matching descriptor with an unaligned relative payload offset
	# returns the loader's tensor-alignment status before any data access.
	lea rdi, [rip + bad_alignment_tensor_infos]
	mov rsi, bad_alignment_mapping_end - bad_alignment_tensor_infos
	xor edx, edx
	mov ecx, 1
	lea r8, [rip + target_name]
	mov r9, target_name_end - target_name
	lea r10, [rip + lookup_slot]
	mov r11, bad_alignment_tensor_data - bad_alignment_tensor_infos
	call gguf_lookup_tensor_info
	cmp rax, GGUF_ERR_TENSOR_ALIGNMENT
	jne .Lfail3

	mov rdi, 1
	lea rsi, [rip + ok_text]
	mov rdx, ok_text_end - ok_text
	call sys_write
	xor edi, edi
	call sys_exit

.Lfail1:
	mov edi, 2
	lea rsi, [rip + fail1_text]
	mov rdx, fail1_text_end - fail1_text
	call sys_write
	mov edi, 1
	call sys_exit

.Lfail2:
	mov edi, 2
	lea rsi, [rip + fail2_text]
	mov rdx, fail2_text_end - fail2_text
	call sys_write
	mov edi, 2
	call sys_exit

.Lfail3:
	mov edi, 2
	lea rsi, [rip + fail3_text]
	mov rdx, fail3_text_end - fail3_text
	call sys_write
	mov edi, 3
	call sys_exit

.size _start, . - _start

.section .note.GNU-stack,"",@progbits
