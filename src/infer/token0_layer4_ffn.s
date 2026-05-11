.intel_syntax noprefix

.equ GGML_TYPE_F32, 0
.equ TOKEN0_LAYER4_FFN_NORM_VALUES, 3072
.equ TOKEN0_LAYER4_FFN_NORM_BYTES, TOKEN0_LAYER4_FFN_NORM_VALUES * 4

.section .rodata

token0_layer4_ffn_norm_text:
	.ascii "token0_layer4_ffn_norm: "
token0_layer4_ffn_norm_text_end:

token0_layer4_ffn_norm0_f32_text:
	.ascii "token0_layer4_ffn_norm0_f32_hex: "
token0_layer4_ffn_norm0_f32_text_end:

token0_layer4_ffn_norm1_f32_text:
	.ascii "token0_layer4_ffn_norm1_f32_hex: "
token0_layer4_ffn_norm1_f32_text_end:

token0_layer4_ffn_norm2_f32_text:
	.ascii "token0_layer4_ffn_norm2_f32_hex: "
token0_layer4_ffn_norm2_f32_text_end:

token0_layer4_ffn_norm3_f32_text:
	.ascii "token0_layer4_ffn_norm3_f32_hex: "
token0_layer4_ffn_norm3_f32_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

.section .bss

.global token0_layer4_ffn_norm_status
.balign 8
token0_layer4_ffn_norm_status:
	.skip 8

.global token0_layer4_ffn_norm_activation
.balign 4
token0_layer4_ffn_norm_activation:
	.skip TOKEN0_LAYER4_FFN_NORM_BYTES

.section .text

.global run_token0_layer4_ffn_norm_status
.type run_token0_layer4_ffn_norm_status, @function

# Contract: run the token-0 layer-4 FFN RMSNorm smoke and publish its status
# line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads the live mapping handoff slots, retained
# RMSNorm epsilon metadata, the retained blk.4.ffn_norm.weight descriptor,
# token0_layer4_post_attn_residual_status, and
# token0_layer4_post_attn_residual.
# Outputs: writes token0_layer4_ffn_norm_status and, on success, fills
# token0_layer4_ffn_norm_activation with 3072 f32 RMSNorm values. Always prints
# exactly one status label/value/newline sequence to stdout and prints the
# first four exact-hex activation words only when the status is 1. The return
# register is unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2, xmm3 and flags through
# the smoke helper and summary writers.
# Ownership/lifetime: borrows the model mmap and layer-4 post-attention
# residual only for the duration of this call; owns the layer-4 FFN norm status
# and activation handoff storage for later focused layer-4 FFN work. The mmap
# remains owned by _start and must be released separately.
# Error behavior: status is 1 only after a bounded RMSNorm completes; otherwise
# status is 0, no layer-4 FFN norm payload bytes are read, and no activation
# exact-hex words are printed. Output write failures remain diagnostic-only.
run_token0_layer4_ffn_norm_status:
	call token0_layer4_ffn_norm_smoke
	mov qword ptr [rip + token0_layer4_ffn_norm_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_norm_text]
	mov rdx, token0_layer4_ffn_norm_text_end - token0_layer4_ffn_norm_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer4_ffn_norm_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer4_ffn_norm_slice
	ret

.size run_token0_layer4_ffn_norm_status, . - run_token0_layer4_ffn_norm_status

.type token0_layer4_ffn_norm_smoke, @function

# Contract: opportunistically apply the layer-4 FFN RMSNorm weights to the
# token-0 layer-4 post-attention residual activation.
# Inputs: no register inputs. Reads the process-owned layer4_ffn_norm tensor
# slot, live mapping descriptor, retained RMSNorm epsilon metadata,
# token0_layer4_post_attn_residual_status, and
# token0_layer4_post_attn_residual.
# Outputs: rax = 1 when the layer-4 post-attention residual is available, the
# epsilon metadata was captured, and blk.4.ffn_norm.weight is exactly a
# one-dimensional f32 [3072] tensor whose full payload span fits inside the
# mapping, after rmsnorm_f32 writes token0_layer4_ffn_norm_activation;
# otherwise rax = 0 and no layer-4 FFN norm payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2, xmm3 and flags.
# Ownership/lifetime: reads mapped weight bytes only during rmsnorm_f32, reads
# the retained layer-4 post-attention residual through that helper, and writes
# exactly TOKEN0_LAYER4_FFN_NORM_BYTES into private module storage on success.
# The mmap remains owned by _start and must be released separately.
# Error behavior: this is a status-only smoke gate for the layer-4
# FFN-normalized activation, not final graph setup. Non-target synthetic GGUF
# fixtures and shape or bounds mismatches are skipped with status 0.
token0_layer4_ffn_norm_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer4_post_attn_residual_status], 1
	jne .Llayer4_ffn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_norm_rms_epsilon_found], 1
	jne .Llayer4_ffn_norm_smoke_done
	cmp qword ptr [rip + layer4_ffn_norm_tensor_found], 1
	jne .Llayer4_ffn_norm_smoke_done
	cmp qword ptr [rip + layer4_ffn_norm_tensor_n_dimensions], 1
	jne .Llayer4_ffn_norm_smoke_done
	cmp qword ptr [rip + layer4_ffn_norm_tensor_ggml_type], GGML_TYPE_F32
	jne .Llayer4_ffn_norm_smoke_done
	cmp qword ptr [rip + layer4_ffn_norm_tensor_dim0], TOKEN0_LAYER4_FFN_NORM_VALUES
	jne .Llayer4_ffn_norm_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve and
	# bound the complete f32 weight span before passing the mapped address to the
	# shared RMSNorm helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer4_ffn_norm_smoke_skip
	mov rdx, qword ptr [rip + layer4_ffn_norm_tensor_offset]
	test rdx, rdx
	js .Llayer4_ffn_norm_smoke_skip
	add rax, rdx
	jc .Llayer4_ffn_norm_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer4_ffn_norm_smoke_skip

	mov r9, TOKEN0_LAYER4_FFN_NORM_BYTES
	mov r11, r10
	sub r11, rax
	cmp r11, r9
	jb .Llayer4_ffn_norm_smoke_skip

	mov rsi, qword ptr [rip + gguf_mapping_base]
	test rsi, rsi
	jz .Llayer4_ffn_norm_smoke_skip
	add rsi, rax
	jc .Llayer4_ffn_norm_smoke_skip

	lea rdi, [rip + token0_layer4_post_attn_residual]
	lea rdx, [rip + token0_layer4_ffn_norm_activation]
	mov rcx, TOKEN0_LAYER4_FFN_NORM_VALUES
	vmovss xmm0, dword ptr [rip + gguf_summary_attn_norm_rms_epsilon_f32]
	call rmsnorm_f32

	mov eax, 1
	ret

.Llayer4_ffn_norm_smoke_skip:
	xor eax, eax

.Llayer4_ffn_norm_smoke_done:
	ret

.size token0_layer4_ffn_norm_smoke, . - token0_layer4_ffn_norm_smoke

.type print_token0_layer4_ffn_norm_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-4 FFN RMSNorm
# activation when the RMSNorm smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer4_ffn_norm_status and the first
# four f32 words of token0_layer4_ffn_norm_activation.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer4_ffn_norm_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads private module-owned layer-4 FFN RMSNorm activation
# storage only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer4_ffn_norm_slice:
	cmp qword ptr [rip + token0_layer4_ffn_norm_status], 1
	jne .Lprint_layer4_ffn_norm_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_norm0_f32_text]
	mov rdx, token0_layer4_ffn_norm0_f32_text_end - token0_layer4_ffn_norm0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_norm_activation]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_norm1_f32_text]
	mov rdx, token0_layer4_ffn_norm1_f32_text_end - token0_layer4_ffn_norm1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_norm_activation + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_norm2_f32_text]
	mov rdx, token0_layer4_ffn_norm2_f32_text_end - token0_layer4_ffn_norm2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_norm_activation + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_norm3_f32_text]
	mov rdx, token0_layer4_ffn_norm3_f32_text_end - token0_layer4_ffn_norm3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_norm_activation + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer4_ffn_norm_slice_done:
	ret

.size print_token0_layer4_ffn_norm_slice, . - print_token0_layer4_ffn_norm_slice

.section .note.GNU-stack,"",@progbits
