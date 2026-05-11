.intel_syntax noprefix

.equ GGML_TYPE_F32, 0
.equ GGML_TYPE_Q8_0, 8
.equ Q8_0_BLOCK_BYTES, 34
.equ TOKEN0_LAYER4_ATTN_NORM_VALUES, 3072
.equ TOKEN0_LAYER4_ATTN_NORM_BYTES, TOKEN0_LAYER4_ATTN_NORM_VALUES * 4
.equ TOKEN0_LAYER4_ATTN_Q_OUTPUT_VALUES, 4096
.equ TOKEN0_LAYER4_ATTN_Q_OUTPUT_BYTES, TOKEN0_LAYER4_ATTN_Q_OUTPUT_VALUES * 4
.equ TOKEN0_LAYER4_ATTN_K_OUTPUT_VALUES, 1024
.equ TOKEN0_LAYER4_ATTN_K_OUTPUT_BYTES, TOKEN0_LAYER4_ATTN_K_OUTPUT_VALUES * 4
.equ TOKEN0_LAYER4_ATTN_V_OUTPUT_VALUES, 1024
.equ TOKEN0_LAYER4_ATTN_V_OUTPUT_BYTES, TOKEN0_LAYER4_ATTN_V_OUTPUT_VALUES * 4
.equ TOKEN0_LAYER4_ATTN_HEAD_DIM_VALUES, 128
.equ TOKEN0_LAYER4_ATTN_QUERY_HEADS_PER_KV_HEAD, 4
.equ TOKEN0_LAYER4_ATTN_KV_HEADS, TOKEN0_LAYER4_ATTN_V_OUTPUT_VALUES / TOKEN0_LAYER4_ATTN_HEAD_DIM_VALUES
.equ TOKEN0_LAYER4_ATTN_CONTEXT_VALUES, TOKEN0_LAYER4_ATTN_Q_OUTPUT_VALUES
.equ TOKEN0_LAYER4_ATTN_CONTEXT_BYTES, TOKEN0_LAYER4_ATTN_CONTEXT_VALUES * 4
.equ TOKEN0_LAYER4_ATTN_OUTPUT_VALUES, TOKEN0_LAYER4_ATTN_NORM_VALUES
.equ TOKEN0_LAYER4_ATTN_OUTPUT_BYTES, TOKEN0_LAYER4_ATTN_OUTPUT_VALUES * 4

.section .rodata

token0_layer4_attn_norm_text:
	.ascii "token0_layer4_attn_norm: "
token0_layer4_attn_norm_text_end:

token0_layer4_attn_q_matvec_text:
	.ascii "token0_layer4_attn_q_matvec: "
token0_layer4_attn_q_matvec_text_end:

token0_layer4_attn_k_matvec_text:
	.ascii "token0_layer4_attn_k_matvec: "
token0_layer4_attn_k_matvec_text_end:

token0_layer4_attn_v_matvec_text:
	.ascii "token0_layer4_attn_v_matvec: "
token0_layer4_attn_v_matvec_text_end:

token0_layer4_attn_context_text:
	.ascii "token0_layer4_attn_context: "
token0_layer4_attn_context_text_end:

token0_layer4_attn_output_matvec_text:
	.ascii "token0_layer4_attn_output_matvec: "
token0_layer4_attn_output_matvec_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

.section .bss

.global token0_layer4_attn_norm_status
.balign 8
token0_layer4_attn_norm_status:
	.skip 8

.global token0_layer4_attn_norm_activation
.balign 4
token0_layer4_attn_norm_activation:
	.skip TOKEN0_LAYER4_ATTN_NORM_BYTES

.global token0_layer4_attn_q_matvec_status
.balign 8
token0_layer4_attn_q_matvec_status:
	.skip 8

.balign 4
token0_layer4_attn_q_output:
	.skip TOKEN0_LAYER4_ATTN_Q_OUTPUT_BYTES

.global token0_layer4_attn_k_matvec_status
.balign 8
token0_layer4_attn_k_matvec_status:
	.skip 8

.balign 4
token0_layer4_attn_k_output:
	.skip TOKEN0_LAYER4_ATTN_K_OUTPUT_BYTES

.global token0_layer4_attn_v_matvec_status
.balign 8
token0_layer4_attn_v_matvec_status:
	.skip 8

.balign 4
token0_layer4_attn_v_output:
	.skip TOKEN0_LAYER4_ATTN_V_OUTPUT_BYTES

.global token0_layer4_attn_context_status
.balign 8
token0_layer4_attn_context_status:
	.skip 8

.global token0_layer4_attn_context
.balign 4
token0_layer4_attn_context:
	.skip TOKEN0_LAYER4_ATTN_CONTEXT_BYTES

.global token0_layer4_attn_output_matvec_status
.balign 8
token0_layer4_attn_output_matvec_status:
	.skip 8

.global token0_layer4_attn_output
.balign 4
token0_layer4_attn_output:
	.skip TOKEN0_LAYER4_ATTN_OUTPUT_BYTES

.section .text

.global run_token0_layer4_attn_norm_status
.type run_token0_layer4_attn_norm_status, @function

# Contract: run the token-0 layer-4 attention RMSNorm smoke and publish its
# status line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads the live mapping handoff slots, retained
# RMSNorm epsilon metadata, the retained blk.4.attn_norm.weight descriptor,
# token0_layer3_post_ffn_residual_status, and token0_layer3_post_ffn_residual.
# Outputs: writes token0_layer4_attn_norm_status and, on success, fills
# token0_layer4_attn_norm_activation. Always prints exactly one status
# label/value/newline sequence to stdout and prints the first four exact-hex
# activation words only when the status is 1. The return register is
# unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2, xmm3 and flags through
# the smoke helper and summary writers.
# Ownership/lifetime: borrows the model mmap and retained layer-3 post-FFN
# residual only during this call; owns the layer-4 attention RMSNorm status and
# activation storage for later focused inference steps. The mmap remains owned
# by _start and must be released separately.
# Error behavior: status is 1 only after the descriptor, mapping span, epsilon,
# and layer-3 residual prerequisites prove a bounded RMSNorm can complete.
# Otherwise status is 0, no layer-4 attention norm payload bytes are read, and
# no exact-hex activation words are printed. Output write failures are
# diagnostic-only.
run_token0_layer4_attn_norm_status:
	call token0_layer4_attn_norm_smoke
	mov qword ptr [rip + token0_layer4_attn_norm_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer4_attn_norm_text]
	mov rdx, token0_layer4_attn_norm_text_end - token0_layer4_attn_norm_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer4_attn_norm_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer4_attn_norm_slice
	ret

.size run_token0_layer4_attn_norm_status, . - run_token0_layer4_attn_norm_status

.global run_token0_layer4_attn_q_matvec_status
.type run_token0_layer4_attn_q_matvec_status, @function

# Contract: run the token-0 layer-4 attention query matvec smoke and publish
# its status line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads the live mapping handoff slots, the retained
# blk.4.attn_q.weight descriptor, token0_layer4_attn_norm_status, and the
# token0_layer4_attn_norm_activation buffer owned by this module.
# Outputs: writes token0_layer4_attn_q_matvec_status and, on success, fills the
# private token0_layer4_attn_q_output buffer. Always prints exactly one status
# label/value/newline sequence to stdout and prints the first four exact-hex
# query output words only when the status is 1. The return register is
# unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags through the
# smoke helper and summary writers. The matvec helper preserves the callee-saved
# registers it uses internally.
# Ownership/lifetime: borrows the model mmap and the layer-4 attention RMSNorm
# activation only during this call; owns the query status and private output
# storage in this module. The mmap remains owned by _start and must be released
# separately.
# Error behavior: status is 1 only after a bounded Q8_0 matvec completes;
# otherwise status is 0 and no layer-4 query matrix payload bytes are read.
# Output write failures are diagnostic-only in the current milestone.
run_token0_layer4_attn_q_matvec_status:
	call token0_layer4_attn_q_matvec_smoke
	mov qword ptr [rip + token0_layer4_attn_q_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer4_attn_q_matvec_text]
	mov rdx, token0_layer4_attn_q_matvec_text_end - token0_layer4_attn_q_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer4_attn_q_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer4_attn_q_output_slice
	ret

.size run_token0_layer4_attn_q_matvec_status, . - run_token0_layer4_attn_q_matvec_status

.global run_token0_layer4_attn_k_matvec_status
.type run_token0_layer4_attn_k_matvec_status, @function

# Contract: run the token-0 layer-4 attention key matvec smoke and publish its
# status line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads the live mapping handoff slots, the retained
# blk.4.attn_k.weight descriptor, token0_layer4_attn_norm_status, and the
# token0_layer4_attn_norm_activation buffer owned by this module.
# Outputs: writes token0_layer4_attn_k_matvec_status and, on success, fills the
# private token0_layer4_attn_k_output buffer. Always prints exactly one status
# label/value/newline sequence to stdout and prints the first four exact-hex key
# output words only when the status is 1. The return register is unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags through the
# smoke helper and summary writers. The matvec helper preserves the callee-saved
# registers it uses internally.
# Ownership/lifetime: borrows the model mmap and the layer-4 attention RMSNorm
# activation only during this call; owns the key status and private output
# storage in this module. The mmap remains owned by _start and must be released
# separately.
# Error behavior: status is 1 only after a bounded Q8_0 matvec completes;
# otherwise status is 0 and no layer-4 key matrix payload bytes are read.
# Output write failures are diagnostic-only in the current milestone.
run_token0_layer4_attn_k_matvec_status:
	call token0_layer4_attn_k_matvec_smoke
	mov qword ptr [rip + token0_layer4_attn_k_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer4_attn_k_matvec_text]
	mov rdx, token0_layer4_attn_k_matvec_text_end - token0_layer4_attn_k_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer4_attn_k_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer4_attn_k_output_slice
	ret

.size run_token0_layer4_attn_k_matvec_status, . - run_token0_layer4_attn_k_matvec_status

.global run_token0_layer4_attn_v_matvec_status
.type run_token0_layer4_attn_v_matvec_status, @function

# Contract: run the token-0 layer-4 attention value matvec smoke and publish
# its status line plus the fixed exact-hex oracle slice on success.
# Inputs: no register inputs. Reads the live mapping handoff slots, the retained
# blk.4.attn_v.weight descriptor, token0_layer4_attn_norm_status, and the
# token0_layer4_attn_norm_activation buffer owned by this module.
# Outputs: writes token0_layer4_attn_v_matvec_status and, on success, fills the
# private token0_layer4_attn_v_output buffer. Always prints exactly one status
# label/value/newline sequence to stdout and prints the first four exact-hex
# value output words only when the status is 1. The return register is
# unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags through the
# smoke helper and summary writers. The matvec helper preserves the callee-saved
# registers it uses internally.
# Ownership/lifetime: borrows the model mmap and the layer-4 attention RMSNorm
# activation only during this call; owns the value status and private output
# storage in this module. The mmap remains owned by _start and must be released
# separately.
# Error behavior: status is 1 only after a bounded Q8_0 matvec completes;
# otherwise status is 0 and no layer-4 value matrix payload bytes are read.
# Output write failures are diagnostic-only in the current milestone.
run_token0_layer4_attn_v_matvec_status:
	call token0_layer4_attn_v_matvec_smoke
	mov qword ptr [rip + token0_layer4_attn_v_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer4_attn_v_matvec_text]
	mov rdx, token0_layer4_attn_v_matvec_text_end - token0_layer4_attn_v_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer4_attn_v_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer4_attn_v_output_slice
	ret

.size run_token0_layer4_attn_v_matvec_status, . - run_token0_layer4_attn_v_matvec_status

.global run_token0_layer4_attn_context_status
.type run_token0_layer4_attn_context_status, @function

# Contract: run the token-0 layer-4 single-token attention context smoke and
# publish its status line without adding a public exact-hex context slice.
# Inputs: no register inputs. Reads token0_layer4_attn_q_matvec_status,
# token0_layer4_attn_k_matvec_status, token0_layer4_attn_v_matvec_status, the
# private layer-4 value projection output, and the retained blk.4 attention
# query, key, value, and output projection tensor descriptors.
# Outputs: writes token0_layer4_attn_context_status and, on success, fills the
# retained token0_layer4_attn_context buffer. Always prints exactly one status
# label/value/newline sequence to stdout. The return register is unspecified.
# Clobbers: caller-saved registers and flags through the smoke helper and
# summary writers.
# Ownership/lifetime: reads private module-owned layer-4 value projection
# storage only during this call, then owns the retained context storage for a
# later guarded output-projection step. Descriptor slots remain process-owned
# parser summaries. This function does not read model payload bytes.
# Error behavior: status is 1 only after all prerequisite statuses and tensor
# shapes match the narrow target GGUF. Otherwise status is 0, no context bytes
# are written, and no context exact-hex words are printed. Output write failures
# are diagnostic-only in the current milestone.
run_token0_layer4_attn_context_status:
	call token0_layer4_attn_context_smoke
	mov qword ptr [rip + token0_layer4_attn_context_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer4_attn_context_text]
	mov rdx, token0_layer4_attn_context_text_end - token0_layer4_attn_context_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer4_attn_context_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size run_token0_layer4_attn_context_status, . - run_token0_layer4_attn_context_status

.global run_token0_layer4_attn_output_matvec_status
.type run_token0_layer4_attn_output_matvec_status, @function

# Contract: run the token-0 layer-4 attention output-projection matvec smoke
# and publish its status line without adding a public exact-hex output slice.
# Inputs: no register inputs. Reads the live mapping handoff slots, retained
# blk.4.attn_output.weight descriptor, token0_layer4_attn_context_status, and
# token0_layer4_attn_context.
# Outputs: writes token0_layer4_attn_output_matvec_status and, on success,
# fills token0_layer4_attn_output. Always prints exactly one status
# label/value/newline sequence to stdout. The return register is unspecified.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags through the
# smoke helper and summary writers. The matvec helper preserves the callee-saved
# registers it uses internally.
# Ownership/lifetime: borrows the model mmap and retained layer-4 attention
# context only during this call; owns the output-projection status and output
# storage for a later residual step. The mmap remains owned by _start and must
# be released separately.
# Error behavior: status is 1 only after a bounded Q8_0 matvec completes.
# Otherwise status is 0, no output-projection matrix payload bytes are read,
# and no public exact-hex output words are printed. Output write failures are
# diagnostic-only in the current milestone.
run_token0_layer4_attn_output_matvec_status:
	call token0_layer4_attn_output_matvec_smoke
	mov qword ptr [rip + token0_layer4_attn_output_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer4_attn_output_matvec_text]
	mov rdx, token0_layer4_attn_output_matvec_text_end - token0_layer4_attn_output_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer4_attn_output_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size run_token0_layer4_attn_output_matvec_status, . - run_token0_layer4_attn_output_matvec_status

.include "src/infer/token0_layer4_attn_slices.inc"

.type token0_layer4_attn_norm_smoke, @function

# Contract: opportunistically apply the retained layer-4 attention RMSNorm
# weights to the token-0 layer-3 post-FFN residual activation.
# Inputs: no register inputs. Reads the process-owned layer4_attn_norm tensor
# slot, live mapping descriptor, retained RMSNorm epsilon metadata,
# token0_layer3_post_ffn_residual_status, and token0_layer3_post_ffn_residual.
# Outputs: rax = 1 when the layer-3 post-FFN residual is available, the epsilon
# metadata was captured, and blk.4.attn_norm.weight is exactly a
# one-dimensional f32 [3072] tensor whose full payload span fits inside the
# mapping, after rmsnorm_f32 writes token0_layer4_attn_norm_activation;
# otherwise rax = 0 and no layer-4 attention norm payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2, xmm3 and flags.
# Ownership/lifetime: reads mapped weight bytes only during rmsnorm_f32, reads
# the retained layer-3 post-FFN residual through that helper, and writes exactly
# TOKEN0_LAYER4_ATTN_NORM_BYTES into private module storage on success. The
# mmap remains owned by _start and must be released separately.
# Error behavior: this is a status-only smoke gate for the layer-4
# attention-normalized activation, not final graph setup. Non-target synthetic
# GGUF fixtures and shape or bounds mismatches are skipped with status 0.
token0_layer4_attn_norm_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer3_post_ffn_residual_status], 1
	jne .Llayer4_attn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_norm_rms_epsilon_found], 1
	jne .Llayer4_attn_norm_smoke_done
	cmp qword ptr [rip + layer4_attn_norm_tensor_found], 1
	jne .Llayer4_attn_norm_smoke_done
	cmp qword ptr [rip + layer4_attn_norm_tensor_n_dimensions], 1
	jne .Llayer4_attn_norm_smoke_done
	cmp qword ptr [rip + layer4_attn_norm_tensor_ggml_type], GGML_TYPE_F32
	jne .Llayer4_attn_norm_smoke_done
	cmp qword ptr [rip + layer4_attn_norm_tensor_dim0], TOKEN0_LAYER4_ATTN_NORM_VALUES
	jne .Llayer4_attn_norm_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve and
	# bound the complete f32 weight span before passing the mapped address to the
	# shared RMSNorm helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer4_attn_norm_smoke_skip
	mov rdx, qword ptr [rip + layer4_attn_norm_tensor_offset]
	test rdx, rdx
	js .Llayer4_attn_norm_smoke_skip
	add rax, rdx
	jc .Llayer4_attn_norm_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer4_attn_norm_smoke_skip

	mov r9, TOKEN0_LAYER4_ATTN_NORM_BYTES
	mov r11, r10
	sub r11, rax
	cmp r11, r9
	jb .Llayer4_attn_norm_smoke_skip

	mov rsi, qword ptr [rip + gguf_mapping_base]
	test rsi, rsi
	jz .Llayer4_attn_norm_smoke_skip
	add rsi, rax
	jc .Llayer4_attn_norm_smoke_skip

	lea rdi, [rip + token0_layer3_post_ffn_residual]
	lea rdx, [rip + token0_layer4_attn_norm_activation]
	mov rcx, TOKEN0_LAYER4_ATTN_NORM_VALUES
	vmovss xmm0, dword ptr [rip + gguf_summary_attn_norm_rms_epsilon_f32]
	call rmsnorm_f32

	mov eax, 1
	ret

.Llayer4_attn_norm_smoke_skip:
	xor eax, eax

.Llayer4_attn_norm_smoke_done:
	ret

.size token0_layer4_attn_norm_smoke, . - token0_layer4_attn_norm_smoke

.type token0_layer4_attn_q_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-4
# attention-normalized activation through the retained blk.4.attn_q.weight
# matrix.
# Inputs: no register inputs. Reads the process-owned layer4_attn_q tensor slot,
# live mapping descriptor, token0_layer4_attn_norm_status, and
# token0_layer4_attn_norm_activation.
# Outputs: rax = 1 when the layer-4 attention-normalized activation is
# available and blk.4.attn_q.weight is exactly a two-dimensional Q8_0
# [3072 x 4096] matrix whose complete payload span fits inside the mapping,
# after q8_0_matvec_f32 writes token0_layer4_attn_q_output; otherwise rax = 0
# and no layer-4 query matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the retained layer-4 attention RMSNorm activation as
# the shared f32 input vector, and writes exactly
# TOKEN0_LAYER4_ATTN_Q_OUTPUT_BYTES into private module storage on success.
# The mmap remains owned by _start and must be released separately.
# Error behavior: this is a status-only smoke gate for the layer-4 query
# projection, not final graph setup. Non-target synthetic GGUF fixtures and
# shape or bounds mismatches are skipped with status 0.
token0_layer4_attn_q_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer4_attn_norm_status], 1
	jne .Llayer4_attn_q_smoke_done
	cmp qword ptr [rip + layer4_attn_q_tensor_found], 1
	jne .Llayer4_attn_q_smoke_done
	cmp qword ptr [rip + layer4_attn_q_tensor_n_dimensions], 2
	jne .Llayer4_attn_q_smoke_done
	cmp qword ptr [rip + layer4_attn_q_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer4_attn_q_smoke_done
	cmp qword ptr [rip + layer4_attn_q_tensor_dim0], TOKEN0_LAYER4_ATTN_NORM_VALUES
	jne .Llayer4_attn_q_smoke_done
	cmp qword ptr [rip + layer4_attn_q_tensor_dim1], TOKEN0_LAYER4_ATTN_Q_OUTPUT_VALUES
	jne .Llayer4_attn_q_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-4 query matrix start and prove the complete row-major Q8_0 payload
	# fits inside the live mapping before passing any mmap pointer to math code.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer4_attn_q_smoke_skip
	mov rdx, qword ptr [rip + layer4_attn_q_tensor_offset]
	test rdx, rdx
	js .Llayer4_attn_q_smoke_skip
	add rax, rdx
	jc .Llayer4_attn_q_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer4_attn_q_smoke_skip

	mov r8, TOKEN0_LAYER4_ATTN_NORM_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer4_attn_q_smoke_skip
	mov rcx, TOKEN0_LAYER4_ATTN_Q_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer4_attn_q_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer4_attn_q_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer4_attn_q_smoke_skip
	add rdi, rax
	jc .Llayer4_attn_q_smoke_skip

	lea rsi, [rip + token0_layer4_attn_norm_activation]
	lea rdx, [rip + token0_layer4_attn_q_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer4_attn_q_smoke_skip:
	xor eax, eax

.Llayer4_attn_q_smoke_done:
	ret

.size token0_layer4_attn_q_matvec_smoke, . - token0_layer4_attn_q_matvec_smoke

.type token0_layer4_attn_k_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-4
# attention-normalized activation through the retained blk.4.attn_k.weight
# matrix.
# Inputs: no register inputs. Reads the process-owned layer4_attn_k tensor slot,
# live mapping descriptor, token0_layer4_attn_norm_status, and
# token0_layer4_attn_norm_activation.
# Outputs: rax = 1 when the layer-4 attention-normalized activation is
# available and blk.4.attn_k.weight is exactly a two-dimensional Q8_0
# [3072 x 1024] matrix whose complete payload span fits inside the mapping,
# after q8_0_matvec_f32 writes token0_layer4_attn_k_output; otherwise rax = 0
# and no layer-4 key matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the retained layer-4 attention RMSNorm activation as
# the shared f32 input vector, and writes exactly
# TOKEN0_LAYER4_ATTN_K_OUTPUT_BYTES into private module storage on success.
# The mmap remains owned by _start and must be released separately.
# Error behavior: this is a status-only smoke gate for the layer-4 key
# projection, not final graph setup. Non-target synthetic GGUF fixtures and
# shape or bounds mismatches are skipped with status 0.
token0_layer4_attn_k_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer4_attn_norm_status], 1
	jne .Llayer4_attn_k_smoke_done
	cmp qword ptr [rip + layer4_attn_k_tensor_found], 1
	jne .Llayer4_attn_k_smoke_done
	cmp qword ptr [rip + layer4_attn_k_tensor_n_dimensions], 2
	jne .Llayer4_attn_k_smoke_done
	cmp qword ptr [rip + layer4_attn_k_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer4_attn_k_smoke_done
	cmp qword ptr [rip + layer4_attn_k_tensor_dim0], TOKEN0_LAYER4_ATTN_NORM_VALUES
	jne .Llayer4_attn_k_smoke_done
	cmp qword ptr [rip + layer4_attn_k_tensor_dim1], TOKEN0_LAYER4_ATTN_K_OUTPUT_VALUES
	jne .Llayer4_attn_k_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-4 key matrix start and prove the complete row-major Q8_0 payload fits
	# inside the live mapping before passing any mmap pointer to math code.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer4_attn_k_smoke_skip
	mov rdx, qword ptr [rip + layer4_attn_k_tensor_offset]
	test rdx, rdx
	js .Llayer4_attn_k_smoke_skip
	add rax, rdx
	jc .Llayer4_attn_k_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer4_attn_k_smoke_skip

	mov r8, TOKEN0_LAYER4_ATTN_NORM_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer4_attn_k_smoke_skip
	mov rcx, TOKEN0_LAYER4_ATTN_K_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer4_attn_k_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer4_attn_k_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer4_attn_k_smoke_skip
	add rdi, rax
	jc .Llayer4_attn_k_smoke_skip

	lea rsi, [rip + token0_layer4_attn_norm_activation]
	lea rdx, [rip + token0_layer4_attn_k_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer4_attn_k_smoke_skip:
	xor eax, eax

.Llayer4_attn_k_smoke_done:
	ret

.size token0_layer4_attn_k_matvec_smoke, . - token0_layer4_attn_k_matvec_smoke

.type token0_layer4_attn_v_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-4
# attention-normalized activation through the retained blk.4.attn_v.weight
# matrix.
# Inputs: no register inputs. Reads the process-owned layer4_attn_v tensor slot,
# live mapping descriptor, token0_layer4_attn_norm_status, and
# token0_layer4_attn_norm_activation.
# Outputs: rax = 1 when the layer-4 attention-normalized activation is
# available and blk.4.attn_v.weight is exactly a two-dimensional Q8_0
# [3072 x 1024] matrix whose complete payload span fits inside the mapping,
# after q8_0_matvec_f32 writes token0_layer4_attn_v_output; otherwise rax = 0
# and no layer-4 value matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the retained layer-4 attention RMSNorm activation as
# the shared f32 input vector, and writes exactly
# TOKEN0_LAYER4_ATTN_V_OUTPUT_BYTES into private module storage on success.
# The mmap remains owned by _start and must be released separately.
# Error behavior: this is a status-only smoke gate for the layer-4 value
# projection, not final graph setup. Non-target synthetic GGUF fixtures and
# shape or bounds mismatches are skipped with status 0.
token0_layer4_attn_v_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer4_attn_norm_status], 1
	jne .Llayer4_attn_v_smoke_done
	cmp qword ptr [rip + layer4_attn_v_tensor_found], 1
	jne .Llayer4_attn_v_smoke_done
	cmp qword ptr [rip + layer4_attn_v_tensor_n_dimensions], 2
	jne .Llayer4_attn_v_smoke_done
	cmp qword ptr [rip + layer4_attn_v_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer4_attn_v_smoke_done
	cmp qword ptr [rip + layer4_attn_v_tensor_dim0], TOKEN0_LAYER4_ATTN_NORM_VALUES
	jne .Llayer4_attn_v_smoke_done
	cmp qword ptr [rip + layer4_attn_v_tensor_dim1], TOKEN0_LAYER4_ATTN_V_OUTPUT_VALUES
	jne .Llayer4_attn_v_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-4 value matrix start and prove the complete row-major Q8_0 payload
	# fits inside the live mapping before passing any mmap pointer to math code.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer4_attn_v_smoke_skip
	mov rdx, qword ptr [rip + layer4_attn_v_tensor_offset]
	test rdx, rdx
	js .Llayer4_attn_v_smoke_skip
	add rax, rdx
	jc .Llayer4_attn_v_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer4_attn_v_smoke_skip

	mov r8, TOKEN0_LAYER4_ATTN_NORM_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer4_attn_v_smoke_skip
	mov rcx, TOKEN0_LAYER4_ATTN_V_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer4_attn_v_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer4_attn_v_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer4_attn_v_smoke_skip
	add rdi, rax
	jc .Llayer4_attn_v_smoke_skip

	lea rsi, [rip + token0_layer4_attn_norm_activation]
	lea rdx, [rip + token0_layer4_attn_v_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer4_attn_v_smoke_skip:
	xor eax, eax

.Llayer4_attn_v_smoke_done:
	ret

.size token0_layer4_attn_v_matvec_smoke, . - token0_layer4_attn_v_matvec_smoke

.type token0_layer4_attn_context_smoke, @function

# Contract: derive the token-0 layer-4 single-token attention context from the
# retained layer-4 value projection output.
# Inputs: no register inputs. Reads the layer-4 query/key/value matvec
# statuses, token0_layer4_attn_v_output, and retained layer-4 query, key, value,
# and output projection tensor descriptors.
# Outputs: rax = 1 after writing a 4096-f32 token0_layer4_attn_context by
# repeating each 128-f32 KV-head value block four times for the associated query
# heads; otherwise rax = 0 and no context bytes are written.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: reads only process-owned static layer-4 value-output
# storage and writes only process-owned static layer-4 context storage. The
# query/key descriptors prove the prerequisite projection shapes, while the
# blk.4.attn_output.weight descriptor is used as a shape guard for the eventual
# consumer. This function does not read any output-projection payload bytes.
# Error behavior: this smoke gate returns status only; invalid inputs and shape
# mismatches are skipped with status 0.
token0_layer4_attn_context_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer4_attn_q_matvec_status], 1
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + token0_layer4_attn_k_matvec_status], 1
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + token0_layer4_attn_v_matvec_status], 1
	jne .Llayer4_attn_context_done

	cmp qword ptr [rip + layer4_attn_q_tensor_found], 1
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_q_tensor_n_dimensions], 2
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_q_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_q_tensor_dim0], TOKEN0_LAYER4_ATTN_NORM_VALUES
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_q_tensor_dim1], TOKEN0_LAYER4_ATTN_Q_OUTPUT_VALUES
	jne .Llayer4_attn_context_done

	cmp qword ptr [rip + layer4_attn_k_tensor_found], 1
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_k_tensor_n_dimensions], 2
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_k_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_k_tensor_dim0], TOKEN0_LAYER4_ATTN_NORM_VALUES
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_k_tensor_dim1], TOKEN0_LAYER4_ATTN_K_OUTPUT_VALUES
	jne .Llayer4_attn_context_done

	cmp qword ptr [rip + layer4_attn_v_tensor_found], 1
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_v_tensor_n_dimensions], 2
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_v_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_v_tensor_dim0], TOKEN0_LAYER4_ATTN_NORM_VALUES
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_v_tensor_dim1], TOKEN0_LAYER4_ATTN_V_OUTPUT_VALUES
	jne .Llayer4_attn_context_done

	cmp qword ptr [rip + layer4_attn_output_tensor_found], 1
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_output_tensor_n_dimensions], 2
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_output_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_output_tensor_dim0], TOKEN0_LAYER4_ATTN_CONTEXT_VALUES
	jne .Llayer4_attn_context_done
	cmp qword ptr [rip + layer4_attn_output_tensor_dim1], TOKEN0_LAYER4_ATTN_NORM_VALUES
	jne .Llayer4_attn_context_done

	# With one token in the layer-local sequence, every query head has exactly
	# one key/value entry. Softmax is therefore 1, so grouped-query attention is
	# the value vector repeated from each KV head into its four query heads.
	lea rsi, [rip + token0_layer4_attn_v_output]
	lea rdi, [rip + token0_layer4_attn_context]
	mov r8, TOKEN0_LAYER4_ATTN_KV_HEADS

.Llayer4_attn_context_kv_head_loop:
	mov r9, TOKEN0_LAYER4_ATTN_QUERY_HEADS_PER_KV_HEAD

.Llayer4_attn_context_repeat_loop:
	mov rcx, TOKEN0_LAYER4_ATTN_HEAD_DIM_VALUES
	mov r10, rsi

.Llayer4_attn_context_copy_loop:
	mov eax, dword ptr [r10]
	mov dword ptr [rdi], eax
	add r10, 4
	add rdi, 4
	dec rcx
	jnz .Llayer4_attn_context_copy_loop

	dec r9
	jnz .Llayer4_attn_context_repeat_loop

	add rsi, TOKEN0_LAYER4_ATTN_HEAD_DIM_VALUES * 4
	dec r8
	jnz .Llayer4_attn_context_kv_head_loop

	mov eax, 1

.Llayer4_attn_context_done:
	ret

.size token0_layer4_attn_context_smoke, . - token0_layer4_attn_context_smoke

.type token0_layer4_attn_output_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-4 single-token
# attention context through the retained blk.4.attn_output.weight matrix.
# Inputs: no register inputs. Reads the process-owned layer4_attn_output tensor
# slot, live mapping descriptor, token0_layer4_attn_context_status, and
# token0_layer4_attn_context.
# Outputs: rax = 1 when the layer-4 context is available and
# blk.4.attn_output.weight is exactly a two-dimensional Q8_0 [4096 x 3072]
# matrix whose complete payload span fits inside the mapping, after
# q8_0_matvec_f32 writes token0_layer4_attn_output; otherwise rax = 0 and no
# layer-4 output-projection matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the retained layer-4 context as the shared f32 input
# vector, and writes exactly TOKEN0_LAYER4_ATTN_OUTPUT_BYTES into static output
# storage on success. The mmap remains owned by _start and must be released
# separately.
# Error behavior: this smoke gate returns status only; invalid prerequisites,
# non-target synthetic GGUF fixtures, shape mismatches, and bounds failures
# skip with status 0.
token0_layer4_attn_output_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer4_attn_context_status], 1
	jne .Llayer4_attn_output_smoke_done
	cmp qword ptr [rip + layer4_attn_output_tensor_found], 1
	jne .Llayer4_attn_output_smoke_done
	cmp qword ptr [rip + layer4_attn_output_tensor_n_dimensions], 2
	jne .Llayer4_attn_output_smoke_done
	cmp qword ptr [rip + layer4_attn_output_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer4_attn_output_smoke_done
	cmp qword ptr [rip + layer4_attn_output_tensor_dim0], TOKEN0_LAYER4_ATTN_CONTEXT_VALUES
	jne .Llayer4_attn_output_smoke_done
	cmp qword ptr [rip + layer4_attn_output_tensor_dim1], TOKEN0_LAYER4_ATTN_OUTPUT_VALUES
	jne .Llayer4_attn_output_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-4 output-projection matrix start and prove the full row-major Q8_0
	# payload fits inside the live mapping before passing any mmap pointer to
	# the shared matvec helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer4_attn_output_smoke_skip
	mov rdx, qword ptr [rip + layer4_attn_output_tensor_offset]
	test rdx, rdx
	js .Llayer4_attn_output_smoke_skip
	add rax, rdx
	jc .Llayer4_attn_output_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer4_attn_output_smoke_skip

	mov r8, TOKEN0_LAYER4_ATTN_CONTEXT_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer4_attn_output_smoke_skip
	mov rcx, TOKEN0_LAYER4_ATTN_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer4_attn_output_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer4_attn_output_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer4_attn_output_smoke_skip
	add rdi, rax
	jc .Llayer4_attn_output_smoke_skip

	lea rsi, [rip + token0_layer4_attn_context]
	lea rdx, [rip + token0_layer4_attn_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer4_attn_output_smoke_skip:
	xor eax, eax

.Llayer4_attn_output_smoke_done:
	ret

.size token0_layer4_attn_output_matvec_smoke, . - token0_layer4_attn_output_matvec_smoke

.section .note.GNU-stack,"",@progbits
