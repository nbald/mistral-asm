.intel_syntax noprefix

.equ GGML_TYPE_F32, 0
.equ GGML_TYPE_Q8_0, 8
.equ Q8_0_BLOCK_BYTES, 34
.equ TOKEN0_LAYER4_FFN_NORM_VALUES, 3072
.equ TOKEN0_LAYER4_FFN_NORM_BYTES, TOKEN0_LAYER4_FFN_NORM_VALUES * 4
.equ TOKEN0_LAYER4_FFN_GATE_OUTPUT_VALUES, 9216
.equ TOKEN0_LAYER4_FFN_GATE_OUTPUT_BYTES, TOKEN0_LAYER4_FFN_GATE_OUTPUT_VALUES * 4
.equ TOKEN0_LAYER4_FFN_UP_OUTPUT_VALUES, 9216
.equ TOKEN0_LAYER4_FFN_UP_OUTPUT_BYTES, TOKEN0_LAYER4_FFN_UP_OUTPUT_VALUES * 4
.equ TOKEN0_LAYER4_FFN_SWIGLU_VALUES, 9216
.equ TOKEN0_LAYER4_FFN_SWIGLU_BYTES, TOKEN0_LAYER4_FFN_SWIGLU_VALUES * 4

.section .rodata

token0_layer4_ffn_norm_text:
	.ascii "token0_layer4_ffn_norm: "
token0_layer4_ffn_norm_text_end:

token0_layer4_ffn_gate_matvec_text:
	.ascii "token0_layer4_ffn_gate_matvec: "
token0_layer4_ffn_gate_matvec_text_end:

token0_layer4_ffn_up_matvec_text:
	.ascii "token0_layer4_ffn_up_matvec: "
token0_layer4_ffn_up_matvec_text_end:

token0_layer4_ffn_swiglu_text:
	.ascii "token0_layer4_ffn_swiglu: "
token0_layer4_ffn_swiglu_text_end:

token0_layer4_ffn_gate_output0_f32_text:
	.ascii "token0_layer4_ffn_gate_output0_f32_hex: "
token0_layer4_ffn_gate_output0_f32_text_end:

token0_layer4_ffn_gate_output1_f32_text:
	.ascii "token0_layer4_ffn_gate_output1_f32_hex: "
token0_layer4_ffn_gate_output1_f32_text_end:

token0_layer4_ffn_gate_output2_f32_text:
	.ascii "token0_layer4_ffn_gate_output2_f32_hex: "
token0_layer4_ffn_gate_output2_f32_text_end:

token0_layer4_ffn_gate_output3_f32_text:
	.ascii "token0_layer4_ffn_gate_output3_f32_hex: "
token0_layer4_ffn_gate_output3_f32_text_end:

token0_layer4_ffn_up_output0_f32_text:
	.ascii "token0_layer4_ffn_up_output0_f32_hex: "
token0_layer4_ffn_up_output0_f32_text_end:

token0_layer4_ffn_up_output1_f32_text:
	.ascii "token0_layer4_ffn_up_output1_f32_hex: "
token0_layer4_ffn_up_output1_f32_text_end:

token0_layer4_ffn_up_output2_f32_text:
	.ascii "token0_layer4_ffn_up_output2_f32_hex: "
token0_layer4_ffn_up_output2_f32_text_end:

token0_layer4_ffn_up_output3_f32_text:
	.ascii "token0_layer4_ffn_up_output3_f32_hex: "
token0_layer4_ffn_up_output3_f32_text_end:

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

.global token0_layer4_ffn_gate_matvec_status
.balign 8
token0_layer4_ffn_gate_matvec_status:
	.skip 8

.balign 4
token0_layer4_ffn_gate_output:
	.skip TOKEN0_LAYER4_FFN_GATE_OUTPUT_BYTES

.global token0_layer4_ffn_up_matvec_status
.balign 8
token0_layer4_ffn_up_matvec_status:
	.skip 8

.balign 4
token0_layer4_ffn_up_output:
	.skip TOKEN0_LAYER4_FFN_UP_OUTPUT_BYTES

.global token0_layer4_ffn_swiglu_status
.balign 8
token0_layer4_ffn_swiglu_status:
	.skip 8

.global token0_layer4_ffn_swiglu_output
.balign 4
token0_layer4_ffn_swiglu_output:
	.skip TOKEN0_LAYER4_FFN_SWIGLU_BYTES

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

.global run_token0_layer4_ffn_gate_matvec_status
.type run_token0_layer4_ffn_gate_matvec_status, @function

# Contract: run the token-0 layer-4 FFN gate matvec smoke and publish its
# status line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads the live mapping handoff slots, the retained
# blk.4.ffn_gate.weight descriptor, token0_layer4_ffn_norm_status, and
# token0_layer4_ffn_norm_activation.
# Outputs: writes token0_layer4_ffn_gate_matvec_status and, on success, fills
# the private token0_layer4_ffn_gate_output buffer with 9216 f32 values for
# later focused layer-4 FFN work. Always prints exactly one status
# label/value/newline sequence to stdout and prints the first four exact-hex
# output words only when the status is 1. The return register is unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: borrows the model mmap and the layer-4 FFN-normalized
# activation only for the duration of this call; owns the layer-4 FFN gate
# status and output storage in this module. The mmap remains owned by _start
# and must be released separately.
# Error behavior: status is 1 only after a bounded Q8_0 matvec completes;
# otherwise status is 0, no layer-4 FFN gate payload bytes are read, and no
# exact-hex output words are printed. Output write failures remain
# diagnostic-only.
run_token0_layer4_ffn_gate_matvec_status:
	call token0_layer4_ffn_gate_matvec_smoke
	mov qword ptr [rip + token0_layer4_ffn_gate_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_gate_matvec_text]
	mov rdx, token0_layer4_ffn_gate_matvec_text_end - token0_layer4_ffn_gate_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer4_ffn_gate_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer4_ffn_gate_output_slice
	ret

.size run_token0_layer4_ffn_gate_matvec_status, . - run_token0_layer4_ffn_gate_matvec_status

.type print_token0_layer4_ffn_gate_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-4 FFN gate
# projection output when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer4_ffn_gate_matvec_status and
# the first four f32 words of token0_layer4_ffn_gate_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer4_ffn_gate_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads private module-owned layer-4 FFN gate output storage
# only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer4_ffn_gate_output_slice:
	cmp qword ptr [rip + token0_layer4_ffn_gate_matvec_status], 1
	jne .Lprint_layer4_ffn_gate_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_gate_output0_f32_text]
	mov rdx, token0_layer4_ffn_gate_output0_f32_text_end - token0_layer4_ffn_gate_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_gate_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_gate_output1_f32_text]
	mov rdx, token0_layer4_ffn_gate_output1_f32_text_end - token0_layer4_ffn_gate_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_gate_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_gate_output2_f32_text]
	mov rdx, token0_layer4_ffn_gate_output2_f32_text_end - token0_layer4_ffn_gate_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_gate_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_gate_output3_f32_text]
	mov rdx, token0_layer4_ffn_gate_output3_f32_text_end - token0_layer4_ffn_gate_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_gate_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer4_ffn_gate_output_slice_done:
	ret

.size print_token0_layer4_ffn_gate_output_slice, . - print_token0_layer4_ffn_gate_output_slice

.type token0_layer4_ffn_gate_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-4 FFN-normalized
# activation through blk.4.ffn_gate.weight.
# Inputs: no register inputs. Reads the process-owned layer4_ffn_gate tensor
# slot, live mapping descriptor, token0_layer4_ffn_norm_status, and
# token0_layer4_ffn_norm_activation.
# Outputs: rax = 1 when the layer-4 FFN-normalized activation is available and
# blk.4.ffn_gate.weight is exactly a two-dimensional Q8_0 [3072 x 9216] matrix
# whose complete payload span fits inside the mapping, after q8_0_matvec_f32
# writes token0_layer4_ffn_gate_output; otherwise rax = 0 and no layer-4 FFN
# gate matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the retained layer-4 FFN-normalized activation as the
# shared f32 input vector, and writes exactly
# TOKEN0_LAYER4_FFN_GATE_OUTPUT_BYTES into private module storage on success.
# Error behavior: this is a status-only smoke gate for the layer-4 FFN gate
# projection, not final graph setup. Non-target synthetic GGUF fixtures and
# shape or bounds mismatches are skipped with status 0.
token0_layer4_ffn_gate_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer4_ffn_norm_status], 1
	jne .Llayer4_ffn_gate_smoke_done
	cmp qword ptr [rip + layer4_ffn_gate_tensor_found], 1
	jne .Llayer4_ffn_gate_smoke_done
	cmp qword ptr [rip + layer4_ffn_gate_tensor_n_dimensions], 2
	jne .Llayer4_ffn_gate_smoke_done
	cmp qword ptr [rip + layer4_ffn_gate_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer4_ffn_gate_smoke_done
	cmp qword ptr [rip + layer4_ffn_gate_tensor_dim0], TOKEN0_LAYER4_FFN_NORM_VALUES
	jne .Llayer4_ffn_gate_smoke_done
	cmp qword ptr [rip + layer4_ffn_gate_tensor_dim1], TOKEN0_LAYER4_FFN_GATE_OUTPUT_VALUES
	jne .Llayer4_ffn_gate_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-4 FFN gate matrix start and prove the complete row-major Q8_0
	# payload fits inside the live mapping before passing any mmap pointer to
	# math code.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer4_ffn_gate_smoke_skip
	mov rdx, qword ptr [rip + layer4_ffn_gate_tensor_offset]
	test rdx, rdx
	js .Llayer4_ffn_gate_smoke_skip
	add rax, rdx
	jc .Llayer4_ffn_gate_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer4_ffn_gate_smoke_skip

	mov r8, TOKEN0_LAYER4_FFN_NORM_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer4_ffn_gate_smoke_skip
	mov rcx, TOKEN0_LAYER4_FFN_GATE_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer4_ffn_gate_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer4_ffn_gate_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer4_ffn_gate_smoke_skip
	add rdi, rax
	jc .Llayer4_ffn_gate_smoke_skip

	lea rsi, [rip + token0_layer4_ffn_norm_activation]
	lea rdx, [rip + token0_layer4_ffn_gate_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer4_ffn_gate_smoke_skip:
	xor eax, eax

.Llayer4_ffn_gate_smoke_done:
	ret

.size token0_layer4_ffn_gate_matvec_smoke, . - token0_layer4_ffn_gate_matvec_smoke

.global run_token0_layer4_ffn_up_matvec_status
.type run_token0_layer4_ffn_up_matvec_status, @function

# Contract: run the token-0 layer-4 FFN up matvec smoke and publish its status
# line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads the live mapping handoff slots, the retained
# blk.4.ffn_up.weight descriptor, token0_layer4_ffn_norm_status, and
# token0_layer4_ffn_norm_activation.
# Outputs: writes token0_layer4_ffn_up_matvec_status and, on success, fills the
# private token0_layer4_ffn_up_output buffer with 9216 f32 values. Always prints
# exactly one status label/value/newline sequence to stdout and prints the first
# four exact-hex output words only when the status is 1. The return register is
# unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: borrows the model mmap and the layer-4 FFN-normalized
# activation only for the duration of this call; owns the layer-4 FFN up status
# and output storage in this module. The mmap remains owned by _start and must
# be released separately.
# Error behavior: status is 1 only after a bounded Q8_0 matvec completes;
# otherwise status is 0, no layer-4 FFN up payload bytes are read, and no
# exact-hex output words are printed. Output write failures remain
# diagnostic-only.
run_token0_layer4_ffn_up_matvec_status:
	call token0_layer4_ffn_up_matvec_smoke
	mov qword ptr [rip + token0_layer4_ffn_up_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_up_matvec_text]
	mov rdx, token0_layer4_ffn_up_matvec_text_end - token0_layer4_ffn_up_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer4_ffn_up_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer4_ffn_up_output_slice
	ret

.size run_token0_layer4_ffn_up_matvec_status, . - run_token0_layer4_ffn_up_matvec_status

.type print_token0_layer4_ffn_up_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-4 FFN up
# projection output when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer4_ffn_up_matvec_status and the
# first four f32 words of token0_layer4_ffn_up_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer4_ffn_up_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads private module-owned layer-4 FFN up output storage
# only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer4_ffn_up_output_slice:
	cmp qword ptr [rip + token0_layer4_ffn_up_matvec_status], 1
	jne .Lprint_layer4_ffn_up_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_up_output0_f32_text]
	mov rdx, token0_layer4_ffn_up_output0_f32_text_end - token0_layer4_ffn_up_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_up_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_up_output1_f32_text]
	mov rdx, token0_layer4_ffn_up_output1_f32_text_end - token0_layer4_ffn_up_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_up_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_up_output2_f32_text]
	mov rdx, token0_layer4_ffn_up_output2_f32_text_end - token0_layer4_ffn_up_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_up_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_up_output3_f32_text]
	mov rdx, token0_layer4_ffn_up_output3_f32_text_end - token0_layer4_ffn_up_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer4_ffn_up_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer4_ffn_up_output_slice_done:
	ret

.size print_token0_layer4_ffn_up_output_slice, . - print_token0_layer4_ffn_up_output_slice

.type token0_layer4_ffn_up_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-4 FFN-normalized
# activation through blk.4.ffn_up.weight.
# Inputs: no register inputs. Reads the process-owned layer4_ffn_up tensor slot,
# live mapping descriptor, token0_layer4_ffn_norm_status, and
# token0_layer4_ffn_norm_activation.
# Outputs: rax = 1 when the layer-4 FFN-normalized activation is available and
# blk.4.ffn_up.weight is exactly a two-dimensional Q8_0 [3072 x 9216] matrix
# whose complete payload span fits inside the mapping, after q8_0_matvec_f32
# writes token0_layer4_ffn_up_output; otherwise rax = 0 and no layer-4 FFN up
# matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the retained layer-4 FFN-normalized activation as the
# shared f32 input vector, and writes exactly
# TOKEN0_LAYER4_FFN_UP_OUTPUT_BYTES into private module storage on success.
# Error behavior: this is a status-only smoke gate for the layer-4 FFN up
# projection, not final graph setup. Non-target synthetic GGUF fixtures and
# shape or bounds mismatches are skipped with status 0.
token0_layer4_ffn_up_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer4_ffn_norm_status], 1
	jne .Llayer4_ffn_up_smoke_done
	cmp qword ptr [rip + layer4_ffn_up_tensor_found], 1
	jne .Llayer4_ffn_up_smoke_done
	cmp qword ptr [rip + layer4_ffn_up_tensor_n_dimensions], 2
	jne .Llayer4_ffn_up_smoke_done
	cmp qword ptr [rip + layer4_ffn_up_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer4_ffn_up_smoke_done
	cmp qword ptr [rip + layer4_ffn_up_tensor_dim0], TOKEN0_LAYER4_FFN_NORM_VALUES
	jne .Llayer4_ffn_up_smoke_done
	cmp qword ptr [rip + layer4_ffn_up_tensor_dim1], TOKEN0_LAYER4_FFN_UP_OUTPUT_VALUES
	jne .Llayer4_ffn_up_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-4 FFN up matrix start and prove the complete row-major Q8_0 payload
	# fits inside the live mapping before passing any mmap pointer to math code.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer4_ffn_up_smoke_skip
	mov rdx, qword ptr [rip + layer4_ffn_up_tensor_offset]
	test rdx, rdx
	js .Llayer4_ffn_up_smoke_skip
	add rax, rdx
	jc .Llayer4_ffn_up_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer4_ffn_up_smoke_skip

	mov r8, TOKEN0_LAYER4_FFN_NORM_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer4_ffn_up_smoke_skip
	mov rcx, TOKEN0_LAYER4_FFN_UP_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer4_ffn_up_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer4_ffn_up_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer4_ffn_up_smoke_skip
	add rdi, rax
	jc .Llayer4_ffn_up_smoke_skip

	lea rsi, [rip + token0_layer4_ffn_norm_activation]
	lea rdx, [rip + token0_layer4_ffn_up_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer4_ffn_up_smoke_skip:
	xor eax, eax

.Llayer4_ffn_up_smoke_done:
	ret

.size token0_layer4_ffn_up_matvec_smoke, . - token0_layer4_ffn_up_matvec_smoke

.global run_token0_layer4_ffn_swiglu_status
.type run_token0_layer4_ffn_swiglu_status, @function

# Contract: run the token-0 layer-4 FFN SwiGLU activation smoke and publish
# its status line only.
# Inputs: no register inputs. Reads token0_layer4_ffn_gate_matvec_status,
# token0_layer4_ffn_up_matvec_status, token0_layer4_ffn_gate_output, and
# token0_layer4_ffn_up_output.
# Outputs: writes token0_layer4_ffn_swiglu_status and, on success, fills the
# module-owned token0_layer4_ffn_swiglu_output buffer with 9216 f32 values.
# Always prints exactly one status label/value/newline sequence to stdout. The
# return register is unspecified.
# Clobbers: caller-saved registers, x87 stack registers, x87 status, and flags
# through the shared scalar SwiGLU helper and summary writers.
# Ownership/lifetime: reads only module-owned gate and up projection buffers
# and writes only module-owned SwiGLU output storage. The model mmap is not read
# by this pure activation step, and the activation buffer is retained as a
# handoff for later focused layer-4 FFN down work.
# Error behavior: status is 1 only after both prerequisite projection statuses
# are available and the shared SwiGLU helper completes; otherwise status is 0.
# No exact-hex SwiGLU output labels are published in this status-only step, and
# output write errors remain diagnostic-only.
run_token0_layer4_ffn_swiglu_status:
	call token0_layer4_ffn_swiglu_smoke
	mov qword ptr [rip + token0_layer4_ffn_swiglu_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer4_ffn_swiglu_text]
	mov rdx, token0_layer4_ffn_swiglu_text_end - token0_layer4_ffn_swiglu_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer4_ffn_swiglu_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size run_token0_layer4_ffn_swiglu_status, . - run_token0_layer4_ffn_swiglu_status

.type token0_layer4_ffn_swiglu_smoke, @function

# Contract: derive the token-0 layer-4 FFN SwiGLU activation from retained gate
# and up projection outputs.
# Inputs: no register inputs. Reads token0_layer4_ffn_gate_matvec_status,
# token0_layer4_ffn_up_matvec_status, token0_layer4_ffn_gate_output, and
# token0_layer4_ffn_up_output.
# Outputs: rax = 1 after writing TOKEN0_LAYER4_FFN_SWIGLU_VALUES f32 values to
# token0_layer4_ffn_swiglu_output, each equal to
# silu(token0_layer4_ffn_gate_output[i]) * token0_layer4_ffn_up_output[i];
# otherwise rax = 0 and no activation bytes are written.
# Clobbers: caller-saved registers, x87 stack registers, x87 status, and flags.
# Ownership/lifetime: reads only private module-owned gate and up projection
# outputs and writes only private module-owned activation storage. This function
# reads no mapped tensor payload bytes.
# Error behavior: this is a smoke gate for the layer-4 FFN activation, not final
# graph setup. Missing prerequisite projection statuses are skipped with status
# 0.
token0_layer4_ffn_swiglu_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer4_ffn_gate_matvec_status], 1
	jne .Llayer4_ffn_swiglu_done
	cmp qword ptr [rip + token0_layer4_ffn_up_matvec_status], 1
	jne .Llayer4_ffn_swiglu_done

	# Projection statuses prove both retained buffers have the target 9216-f32
	# width, so the activation step combines private storage only.
	lea rdi, [rip + token0_layer4_ffn_gate_output]
	lea rsi, [rip + token0_layer4_ffn_up_output]
	lea rdx, [rip + token0_layer4_ffn_swiglu_output]
	mov ecx, TOKEN0_LAYER4_FFN_SWIGLU_VALUES
	call swiglu_f32

	mov eax, 1

.Llayer4_ffn_swiglu_done:
	ret

.size token0_layer4_ffn_swiglu_smoke, . - token0_layer4_ffn_swiglu_smoke

.section .note.GNU-stack,"",@progbits
