.intel_syntax noprefix

.equ GGML_TYPE_F32, 0
.equ GGML_TYPE_Q8_0, 8
.equ Q8_0_BLOCK_BYTES, 34
.equ TOKEN0_LAYER2_FFN_NORM_VALUES, 3072
.equ TOKEN0_LAYER2_FFN_NORM_BYTES, TOKEN0_LAYER2_FFN_NORM_VALUES * 4
.equ TOKEN0_LAYER2_FFN_GATE_OUTPUT_VALUES, 9216
.equ TOKEN0_LAYER2_FFN_GATE_OUTPUT_BYTES, TOKEN0_LAYER2_FFN_GATE_OUTPUT_VALUES * 4
.equ TOKEN0_LAYER2_FFN_UP_OUTPUT_VALUES, 9216
.equ TOKEN0_LAYER2_FFN_UP_OUTPUT_BYTES, TOKEN0_LAYER2_FFN_UP_OUTPUT_VALUES * 4

.section .rodata

token0_layer2_ffn_norm_text:
	.ascii "token0_layer2_ffn_norm: "
token0_layer2_ffn_norm_text_end:

token0_layer2_ffn_gate_matvec_text:
	.ascii "token0_layer2_ffn_gate_matvec: "
token0_layer2_ffn_gate_matvec_text_end:

token0_layer2_ffn_up_matvec_text:
	.ascii "token0_layer2_ffn_up_matvec: "
token0_layer2_ffn_up_matvec_text_end:

token0_layer2_ffn_gate_output0_f32_text:
	.ascii "token0_layer2_ffn_gate_output0_f32_hex: "
token0_layer2_ffn_gate_output0_f32_text_end:

token0_layer2_ffn_gate_output1_f32_text:
	.ascii "token0_layer2_ffn_gate_output1_f32_hex: "
token0_layer2_ffn_gate_output1_f32_text_end:

token0_layer2_ffn_gate_output2_f32_text:
	.ascii "token0_layer2_ffn_gate_output2_f32_hex: "
token0_layer2_ffn_gate_output2_f32_text_end:

token0_layer2_ffn_gate_output3_f32_text:
	.ascii "token0_layer2_ffn_gate_output3_f32_hex: "
token0_layer2_ffn_gate_output3_f32_text_end:

token0_layer2_ffn_up_output0_f32_text:
	.ascii "token0_layer2_ffn_up_output0_f32_hex: "
token0_layer2_ffn_up_output0_f32_text_end:

token0_layer2_ffn_up_output1_f32_text:
	.ascii "token0_layer2_ffn_up_output1_f32_hex: "
token0_layer2_ffn_up_output1_f32_text_end:

token0_layer2_ffn_up_output2_f32_text:
	.ascii "token0_layer2_ffn_up_output2_f32_hex: "
token0_layer2_ffn_up_output2_f32_text_end:

token0_layer2_ffn_up_output3_f32_text:
	.ascii "token0_layer2_ffn_up_output3_f32_hex: "
token0_layer2_ffn_up_output3_f32_text_end:

token0_layer2_ffn_norm0_f32_text:
	.ascii "token0_layer2_ffn_norm0_f32_hex: "
token0_layer2_ffn_norm0_f32_text_end:

token0_layer2_ffn_norm1_f32_text:
	.ascii "token0_layer2_ffn_norm1_f32_hex: "
token0_layer2_ffn_norm1_f32_text_end:

token0_layer2_ffn_norm2_f32_text:
	.ascii "token0_layer2_ffn_norm2_f32_hex: "
token0_layer2_ffn_norm2_f32_text_end:

token0_layer2_ffn_norm3_f32_text:
	.ascii "token0_layer2_ffn_norm3_f32_hex: "
token0_layer2_ffn_norm3_f32_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

.section .bss

.global token0_layer2_ffn_norm_status
.balign 8
token0_layer2_ffn_norm_status:
	.skip 8

.global token0_layer2_ffn_norm_activation
.balign 4
token0_layer2_ffn_norm_activation:
	.skip TOKEN0_LAYER2_FFN_NORM_BYTES

.global token0_layer2_ffn_gate_matvec_status
.balign 8
token0_layer2_ffn_gate_matvec_status:
	.skip 8

.balign 4
token0_layer2_ffn_gate_output:
	.skip TOKEN0_LAYER2_FFN_GATE_OUTPUT_BYTES

.global token0_layer2_ffn_up_matvec_status
.balign 8
token0_layer2_ffn_up_matvec_status:
	.skip 8

.balign 4
token0_layer2_ffn_up_output:
	.skip TOKEN0_LAYER2_FFN_UP_OUTPUT_BYTES

.section .text

.global run_token0_layer2_ffn_norm_status
.type run_token0_layer2_ffn_norm_status, @function

# Contract: run the token-0 layer-2 FFN RMSNorm smoke and publish its status
# line.
# Inputs: no register inputs. Reads the live mapping handoff slots, retained
# RMSNorm epsilon metadata, blk.2.ffn_norm.weight descriptor,
# token0_layer2_post_attn_residual_status, and
# token0_layer2_post_attn_residual.
# Outputs: writes token0_layer2_ffn_norm_status and, on success, fills
# token0_layer2_ffn_norm_activation with 3072 f32 RMSNorm values. Always prints
# exactly one status label/value/newline sequence to stdout, then prints the
# first four exact-hex RMSNorm activation words only when the status is 1. The
# return register is unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2, xmm3 and flags through
# the smoke helper and summary writers.
# Ownership/lifetime: borrows the model mmap and layer-2 post-attention
# residual only for the duration of this call; writes the module-owned layer-2
# FFN norm status and activation handoff slots. The mmap remains owned by
# _start and must be released separately.
# Error behavior: status is 1 only after a bounded RMSNorm completes; otherwise
# status is 0, no layer-2 FFN norm payload bytes are read, and no activation
# exact-hex words are printed. Output write failures remain diagnostic-only and
# are not surfaced separately.
run_token0_layer2_ffn_norm_status:
	call token0_layer2_ffn_norm_smoke
	mov qword ptr [rip + token0_layer2_ffn_norm_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_norm_text]
	mov rdx, token0_layer2_ffn_norm_text_end - token0_layer2_ffn_norm_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer2_ffn_norm_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer2_ffn_norm_slice
	ret

.size run_token0_layer2_ffn_norm_status, . - run_token0_layer2_ffn_norm_status

.type token0_layer2_ffn_norm_smoke, @function

# Contract: opportunistically apply the reusable layer-2 FFN RMSNorm weights to
# the token-0 layer-2 post-attention residual activation.
# Inputs: no register inputs. Reads the process-owned layer2_ffn_norm tensor
# slot, live mapping descriptor, retained RMSNorm epsilon metadata,
# token0_layer2_post_attn_residual_status, and
# token0_layer2_post_attn_residual.
# Outputs: rax = 1 when the layer-2 post-attention residual is available, the
# epsilon metadata was captured, and blk.2.ffn_norm.weight is exactly a
# one-dimensional f32 [3072] tensor whose full payload span fits inside the
# mapping, after rmsnorm_f32 writes token0_layer2_ffn_norm_activation;
# otherwise rax = 0 and no layer-2 FFN norm payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2, xmm3 and flags.
# Ownership/lifetime: reads mapped weight bytes only during rmsnorm_f32, reads
# the retained layer-2 post-attention residual twice through that helper, and
# writes exactly TOKEN0_LAYER2_FFN_NORM_BYTES into private module storage on
# success. The mmap remains owned by _start and must be released separately.
# Error behavior: this is a status-only smoke gate for the layer-2
# FFN-normalized activation, not final graph setup. Non-target synthetic GGUF
# fixtures and shape or bounds mismatches are skipped with status 0.
token0_layer2_ffn_norm_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer2_post_attn_residual_status], 1
	jne .Llayer2_ffn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_norm_rms_epsilon_found], 1
	jne .Llayer2_ffn_norm_smoke_done
	cmp qword ptr [rip + layer2_ffn_norm_tensor_found], 1
	jne .Llayer2_ffn_norm_smoke_done
	cmp qword ptr [rip + layer2_ffn_norm_tensor_n_dimensions], 1
	jne .Llayer2_ffn_norm_smoke_done
	cmp qword ptr [rip + layer2_ffn_norm_tensor_ggml_type], GGML_TYPE_F32
	jne .Llayer2_ffn_norm_smoke_done
	cmp qword ptr [rip + layer2_ffn_norm_tensor_dim0], TOKEN0_LAYER2_FFN_NORM_VALUES
	jne .Llayer2_ffn_norm_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve and
	# bound the complete f32 weight span before passing the mapped address to the
	# shared RMSNorm helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer2_ffn_norm_smoke_skip
	mov rdx, qword ptr [rip + layer2_ffn_norm_tensor_offset]
	test rdx, rdx
	js .Llayer2_ffn_norm_smoke_skip
	add rax, rdx
	jc .Llayer2_ffn_norm_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer2_ffn_norm_smoke_skip

	mov r9, TOKEN0_LAYER2_FFN_NORM_BYTES
	mov r11, r10
	sub r11, rax
	cmp r11, r9
	jb .Llayer2_ffn_norm_smoke_skip

	mov rsi, qword ptr [rip + gguf_mapping_base]
	test rsi, rsi
	jz .Llayer2_ffn_norm_smoke_skip
	add rsi, rax
	jc .Llayer2_ffn_norm_smoke_skip

	lea rdi, [rip + token0_layer2_post_attn_residual]
	lea rdx, [rip + token0_layer2_ffn_norm_activation]
	mov rcx, TOKEN0_LAYER2_FFN_NORM_VALUES
	vmovss xmm0, dword ptr [rip + gguf_summary_attn_norm_rms_epsilon_f32]
	call rmsnorm_f32

	mov eax, 1
	ret

.Llayer2_ffn_norm_smoke_skip:
	xor eax, eax

.Llayer2_ffn_norm_smoke_done:
	ret

.size token0_layer2_ffn_norm_smoke, . - token0_layer2_ffn_norm_smoke

.type print_token0_layer2_ffn_norm_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-2 FFN RMSNorm
# activation when the RMSNorm smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer2_ffn_norm_status and the first
# four f32 words of token0_layer2_ffn_norm_activation.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer2_ffn_norm_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads private module-owned layer-2 FFN RMSNorm activation
# storage only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer2_ffn_norm_slice:
	cmp qword ptr [rip + token0_layer2_ffn_norm_status], 1
	jne .Lprint_layer2_ffn_norm_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_norm0_f32_text]
	mov rdx, token0_layer2_ffn_norm0_f32_text_end - token0_layer2_ffn_norm0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_ffn_norm_activation]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_norm1_f32_text]
	mov rdx, token0_layer2_ffn_norm1_f32_text_end - token0_layer2_ffn_norm1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_ffn_norm_activation + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_norm2_f32_text]
	mov rdx, token0_layer2_ffn_norm2_f32_text_end - token0_layer2_ffn_norm2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_ffn_norm_activation + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_norm3_f32_text]
	mov rdx, token0_layer2_ffn_norm3_f32_text_end - token0_layer2_ffn_norm3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_ffn_norm_activation + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer2_ffn_norm_slice_done:
	ret

.size print_token0_layer2_ffn_norm_slice, . - print_token0_layer2_ffn_norm_slice

.global run_token0_layer2_ffn_gate_matvec_status
.type run_token0_layer2_ffn_gate_matvec_status, @function

# Contract: run the token-0 layer-2 FFN gate matvec smoke and publish its
# status line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads the live mapping handoff slots, the retained
# blk.2.ffn_gate.weight descriptor, token0_layer2_ffn_norm_status, and the
# token0_layer2_ffn_norm_activation buffer owned by this module.
# Outputs: writes token0_layer2_ffn_gate_matvec_status and, on success, fills
# the private token0_layer2_ffn_gate_output buffer. Always prints exactly one
# status label/value/newline sequence to stdout and prints the first four
# exact-hex output words only when the status is 1. The return register is
# unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: borrows the model mmap and the layer-2 FFN-normalized
# activation only for the duration of this call; owns the status and gate output
# storage in this module. The mmap remains owned by _start and must be released
# separately.
# Error behavior: status is 1 only after a bounded Q8_0 matvec completes;
# otherwise status is 0, no layer-2 FFN gate payload bytes are read, and no
# exact-hex output words are printed. Output write errors are not reported
# separately because current milestone output is diagnostic summary text.
run_token0_layer2_ffn_gate_matvec_status:
	call token0_layer2_ffn_gate_matvec_smoke
	mov qword ptr [rip + token0_layer2_ffn_gate_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_gate_matvec_text]
	mov rdx, token0_layer2_ffn_gate_matvec_text_end - token0_layer2_ffn_gate_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer2_ffn_gate_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer2_ffn_gate_output_slice
	ret

.size run_token0_layer2_ffn_gate_matvec_status, . - run_token0_layer2_ffn_gate_matvec_status

.type print_token0_layer2_ffn_gate_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-2 FFN gate
# projection output when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer2_ffn_gate_matvec_status and
# the first four f32 words of token0_layer2_ffn_gate_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer2_ffn_gate_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads private module-owned layer-2 FFN gate output storage
# only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer2_ffn_gate_output_slice:
	cmp qword ptr [rip + token0_layer2_ffn_gate_matvec_status], 1
	jne .Lprint_layer2_ffn_gate_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_gate_output0_f32_text]
	mov rdx, token0_layer2_ffn_gate_output0_f32_text_end - token0_layer2_ffn_gate_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_ffn_gate_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_gate_output1_f32_text]
	mov rdx, token0_layer2_ffn_gate_output1_f32_text_end - token0_layer2_ffn_gate_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_ffn_gate_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_gate_output2_f32_text]
	mov rdx, token0_layer2_ffn_gate_output2_f32_text_end - token0_layer2_ffn_gate_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_ffn_gate_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_gate_output3_f32_text]
	mov rdx, token0_layer2_ffn_gate_output3_f32_text_end - token0_layer2_ffn_gate_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_ffn_gate_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer2_ffn_gate_output_slice_done:
	ret

.size print_token0_layer2_ffn_gate_output_slice, . - print_token0_layer2_ffn_gate_output_slice

.type token0_layer2_ffn_gate_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-2 FFN-normalized
# activation through the reusable blk.2.ffn_gate.weight matrix.
# Inputs: no register inputs. Reads the process-owned layer2_ffn_gate tensor
# slot, live mapping descriptor, token0_layer2_ffn_norm_status, and
# token0_layer2_ffn_norm_activation.
# Outputs: rax = 1 when the layer-2 FFN-normalized activation is available and
# blk.2.ffn_gate.weight is exactly a two-dimensional Q8_0 [3072 x 9216] matrix
# whose complete payload span fits inside the mapping, after q8_0_matvec_f32
# writes token0_layer2_ffn_gate_output; otherwise rax = 0 and no layer-2 FFN
# gate matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the retained layer-2 FFN-normalized activation as the
# shared f32 input vector, and writes exactly
# TOKEN0_LAYER2_FFN_GATE_OUTPUT_BYTES into private module storage on success.
# Error behavior: this is a status-only smoke gate for the layer-2 FFN gate
# projection, not final graph setup. Non-target synthetic GGUF fixtures and
# shape or bounds mismatches are skipped with status 0.
token0_layer2_ffn_gate_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer2_ffn_norm_status], 1
	jne .Llayer2_ffn_gate_smoke_done
	cmp qword ptr [rip + layer2_ffn_gate_tensor_found], 1
	jne .Llayer2_ffn_gate_smoke_done
	cmp qword ptr [rip + layer2_ffn_gate_tensor_n_dimensions], 2
	jne .Llayer2_ffn_gate_smoke_done
	cmp qword ptr [rip + layer2_ffn_gate_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer2_ffn_gate_smoke_done
	cmp qword ptr [rip + layer2_ffn_gate_tensor_dim0], TOKEN0_LAYER2_FFN_NORM_VALUES
	jne .Llayer2_ffn_gate_smoke_done
	cmp qword ptr [rip + layer2_ffn_gate_tensor_dim1], TOKEN0_LAYER2_FFN_GATE_OUTPUT_VALUES
	jne .Llayer2_ffn_gate_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-2 FFN gate matrix start and prove the complete row-major Q8_0 payload
	# fits inside the live mapping before passing any mmap pointer to math code.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer2_ffn_gate_smoke_skip
	mov rdx, qword ptr [rip + layer2_ffn_gate_tensor_offset]
	test rdx, rdx
	js .Llayer2_ffn_gate_smoke_skip
	add rax, rdx
	jc .Llayer2_ffn_gate_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer2_ffn_gate_smoke_skip

	mov r8, TOKEN0_LAYER2_FFN_NORM_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer2_ffn_gate_smoke_skip
	mov rcx, TOKEN0_LAYER2_FFN_GATE_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer2_ffn_gate_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer2_ffn_gate_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer2_ffn_gate_smoke_skip
	add rdi, rax
	jc .Llayer2_ffn_gate_smoke_skip

	lea rsi, [rip + token0_layer2_ffn_norm_activation]
	lea rdx, [rip + token0_layer2_ffn_gate_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer2_ffn_gate_smoke_skip:
	xor eax, eax

.Llayer2_ffn_gate_smoke_done:
	ret

.size token0_layer2_ffn_gate_matvec_smoke, . - token0_layer2_ffn_gate_matvec_smoke

.global run_token0_layer2_ffn_up_matvec_status
.type run_token0_layer2_ffn_up_matvec_status, @function

# Contract: run the token-0 layer-2 FFN up matvec smoke and publish its status
# line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads the live mapping handoff slots, the retained
# blk.2.ffn_up.weight descriptor, token0_layer2_ffn_norm_status, and the
# token0_layer2_ffn_norm_activation buffer owned by this module.
# Outputs: writes token0_layer2_ffn_up_matvec_status and, on success, fills the
# private token0_layer2_ffn_up_output buffer. Always prints exactly one status
# label/value/newline sequence to stdout and prints the first four exact-hex
# output words only when the status is 1. The return register is unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: borrows the model mmap and the layer-2 FFN-normalized
# activation only for the duration of this call; owns the status and up output
# storage in this module. The mmap remains owned by _start and must be released
# separately.
# Error behavior: status is 1 only after a bounded Q8_0 matvec completes;
# otherwise status is 0, no layer-2 FFN up payload bytes are read, and no
# exact-hex output words are printed. Output write errors are not reported
# separately because current milestone output is diagnostic summary text.
run_token0_layer2_ffn_up_matvec_status:
	call token0_layer2_ffn_up_matvec_smoke
	mov qword ptr [rip + token0_layer2_ffn_up_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_up_matvec_text]
	mov rdx, token0_layer2_ffn_up_matvec_text_end - token0_layer2_ffn_up_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer2_ffn_up_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer2_ffn_up_output_slice
	ret

.size run_token0_layer2_ffn_up_matvec_status, . - run_token0_layer2_ffn_up_matvec_status

.type print_token0_layer2_ffn_up_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-2 FFN up
# projection output when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer2_ffn_up_matvec_status and the
# first four f32 words of token0_layer2_ffn_up_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer2_ffn_up_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads private module-owned layer-2 FFN up output storage
# only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer2_ffn_up_output_slice:
	cmp qword ptr [rip + token0_layer2_ffn_up_matvec_status], 1
	jne .Lprint_layer2_ffn_up_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_up_output0_f32_text]
	mov rdx, token0_layer2_ffn_up_output0_f32_text_end - token0_layer2_ffn_up_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_ffn_up_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_up_output1_f32_text]
	mov rdx, token0_layer2_ffn_up_output1_f32_text_end - token0_layer2_ffn_up_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_ffn_up_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_up_output2_f32_text]
	mov rdx, token0_layer2_ffn_up_output2_f32_text_end - token0_layer2_ffn_up_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_ffn_up_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer2_ffn_up_output3_f32_text]
	mov rdx, token0_layer2_ffn_up_output3_f32_text_end - token0_layer2_ffn_up_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer2_ffn_up_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer2_ffn_up_output_slice_done:
	ret

.size print_token0_layer2_ffn_up_output_slice, . - print_token0_layer2_ffn_up_output_slice

.type token0_layer2_ffn_up_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-2 FFN-normalized
# activation through the reusable blk.2.ffn_up.weight matrix.
# Inputs: no register inputs. Reads the process-owned layer2_ffn_up tensor slot,
# live mapping descriptor, token0_layer2_ffn_norm_status, and
# token0_layer2_ffn_norm_activation.
# Outputs: rax = 1 when the layer-2 FFN-normalized activation is available and
# blk.2.ffn_up.weight is exactly a two-dimensional Q8_0 [3072 x 9216] matrix
# whose complete payload span fits inside the mapping, after q8_0_matvec_f32
# writes token0_layer2_ffn_up_output; otherwise rax = 0 and no layer-2 FFN up
# matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the retained layer-2 FFN-normalized activation as the
# shared f32 input vector, and writes exactly
# TOKEN0_LAYER2_FFN_UP_OUTPUT_BYTES into private module storage on success.
# Error behavior: this is a status-only smoke gate for the layer-2 FFN up
# projection, not final graph setup. Non-target synthetic GGUF fixtures and
# shape or bounds mismatches are skipped with status 0.
token0_layer2_ffn_up_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer2_ffn_norm_status], 1
	jne .Llayer2_ffn_up_smoke_done
	cmp qword ptr [rip + layer2_ffn_up_tensor_found], 1
	jne .Llayer2_ffn_up_smoke_done
	cmp qword ptr [rip + layer2_ffn_up_tensor_n_dimensions], 2
	jne .Llayer2_ffn_up_smoke_done
	cmp qword ptr [rip + layer2_ffn_up_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer2_ffn_up_smoke_done
	cmp qword ptr [rip + layer2_ffn_up_tensor_dim0], TOKEN0_LAYER2_FFN_NORM_VALUES
	jne .Llayer2_ffn_up_smoke_done
	cmp qword ptr [rip + layer2_ffn_up_tensor_dim1], TOKEN0_LAYER2_FFN_UP_OUTPUT_VALUES
	jne .Llayer2_ffn_up_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-2 FFN up matrix start and prove the complete row-major Q8_0 payload
	# fits inside the live mapping before passing any mmap pointer to math code.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer2_ffn_up_smoke_skip
	mov rdx, qword ptr [rip + layer2_ffn_up_tensor_offset]
	test rdx, rdx
	js .Llayer2_ffn_up_smoke_skip
	add rax, rdx
	jc .Llayer2_ffn_up_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer2_ffn_up_smoke_skip

	mov r8, TOKEN0_LAYER2_FFN_NORM_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer2_ffn_up_smoke_skip
	mov rcx, TOKEN0_LAYER2_FFN_UP_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer2_ffn_up_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer2_ffn_up_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer2_ffn_up_smoke_skip
	add rdi, rax
	jc .Llayer2_ffn_up_smoke_skip

	lea rsi, [rip + token0_layer2_ffn_norm_activation]
	lea rdx, [rip + token0_layer2_ffn_up_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer2_ffn_up_smoke_skip:
	xor eax, eax

.Llayer2_ffn_up_smoke_done:
	ret

.size token0_layer2_ffn_up_matvec_smoke, . - token0_layer2_ffn_up_matvec_smoke

.section .note.GNU-stack,"",@progbits
