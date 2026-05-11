token0_layer1_attn_norm_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_post_ffn_residual_status], 1
	jne .Llayer1_attn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_norm_rms_epsilon_found], 1
	jne .Llayer1_attn_norm_smoke_done
	cmp qword ptr [rip + layer1_attn_norm_tensor_found], 1
	jne .Llayer1_attn_norm_smoke_done
	cmp qword ptr [rip + layer1_attn_norm_tensor_n_dimensions], 1
	jne .Llayer1_attn_norm_smoke_done
	cmp qword ptr [rip + layer1_attn_norm_tensor_ggml_type], GGML_TYPE_F32
	jne .Llayer1_attn_norm_smoke_done
	cmp qword ptr [rip + layer1_attn_norm_tensor_dim0], TOKEN0_LAYER1_ATTN_NORM_VALUES
	jne .Llayer1_attn_norm_smoke_done

	# Tensor offsets remain relative to the aligned tensor-data base. Check the
	# complete f32 weight span before sharing the mmap address with rmsnorm_f32.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer1_attn_norm_smoke_skip
	mov rdx, qword ptr [rip + layer1_attn_norm_tensor_offset]
	test rdx, rdx
	js .Llayer1_attn_norm_smoke_skip
	add rax, rdx
	jc .Llayer1_attn_norm_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer1_attn_norm_smoke_skip

	mov r9, TOKEN0_LAYER1_ATTN_NORM_BYTES
	mov r11, r10
	sub r11, rax
	cmp r11, r9
	jb .Llayer1_attn_norm_smoke_skip

	mov rsi, qword ptr [rip + gguf_mapping_base]
	test rsi, rsi
	jz .Llayer1_attn_norm_smoke_skip
	add rsi, rax
	jc .Llayer1_attn_norm_smoke_skip

	lea rdi, [rip + token0_post_ffn_residual]
	lea rdx, [rip + token0_layer1_attn_norm_activation]
	mov rcx, TOKEN0_LAYER1_ATTN_NORM_VALUES
	vmovss xmm0, dword ptr [rip + gguf_summary_attn_norm_rms_epsilon_f32]
	call rmsnorm_f32

	mov eax, 1
	ret

.Llayer1_attn_norm_smoke_skip:
	xor eax, eax

.Llayer1_attn_norm_smoke_done:
	ret

.size token0_layer1_attn_norm_smoke, . - token0_layer1_attn_norm_smoke

.type token0_layer1_attn_q_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-1 attention-normalized
# activation through the reusable blk.1.attn_q.weight matrix.
# Inputs: no register inputs. Reads the process-owned layer1_attn_q tensor slot,
# live mapping descriptor, token0_layer1_attn_norm_status, and
# token0_layer1_attn_norm_activation.
# Outputs: rax = 1 when the layer-1 normalized activation is available and
# blk.1.attn_q.weight is exactly a two-dimensional Q8_0 [3072 x 4096] matrix
# whose complete payload span fits inside the mapping, after q8_0_matvec_f32
# writes token0_layer1_attn_q_output; otherwise rax = 0 and no layer-1 query
# matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the static layer-1 RMSNorm activation as the shared f32
# input vector, and writes exactly TOKEN0_LAYER1_ATTN_Q_OUTPUT_BYTES into private
# static output storage on success. The mmap remains owned by _start and must be
# released separately.
# Error behavior: this is a status-only smoke gate for the next layer query
# projection, not final graph setup. Non-target synthetic GGUF fixtures and
# shape or bounds mismatches are skipped with status 0.
token0_layer1_attn_q_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer1_attn_norm_status], 1
	jne .Llayer1_attn_q_smoke_done
	cmp qword ptr [rip + layer1_attn_q_tensor_found], 1
	jne .Llayer1_attn_q_smoke_done
	cmp qword ptr [rip + layer1_attn_q_tensor_n_dimensions], 2
	jne .Llayer1_attn_q_smoke_done
	cmp qword ptr [rip + layer1_attn_q_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer1_attn_q_smoke_done
	cmp qword ptr [rip + layer1_attn_q_tensor_dim0], TOKEN0_LAYER1_ATTN_NORM_VALUES
	jne .Llayer1_attn_q_smoke_done
	cmp qword ptr [rip + layer1_attn_q_tensor_dim1], TOKEN0_LAYER1_ATTN_Q_OUTPUT_VALUES
	jne .Llayer1_attn_q_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-1 query matrix start and prove the complete row-major Q8_0 payload fits
	# inside the live mapping before passing any mmap pointer to the math helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer1_attn_q_smoke_skip
	mov rdx, qword ptr [rip + layer1_attn_q_tensor_offset]
	test rdx, rdx
	js .Llayer1_attn_q_smoke_skip
	add rax, rdx
	jc .Llayer1_attn_q_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer1_attn_q_smoke_skip

	mov r8, TOKEN0_LAYER1_ATTN_NORM_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer1_attn_q_smoke_skip
	mov rcx, TOKEN0_LAYER1_ATTN_Q_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer1_attn_q_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer1_attn_q_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer1_attn_q_smoke_skip
	add rdi, rax
	jc .Llayer1_attn_q_smoke_skip

	lea rsi, [rip + token0_layer1_attn_norm_activation]
	lea rdx, [rip + token0_layer1_attn_q_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer1_attn_q_smoke_skip:
	xor eax, eax

.Llayer1_attn_q_smoke_done:
	ret

.size token0_layer1_attn_q_matvec_smoke, . - token0_layer1_attn_q_matvec_smoke

.type token0_layer1_attn_k_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-1 attention-normalized
# activation through the reusable blk.1.attn_k.weight matrix.
# Inputs: no register inputs. Reads the process-owned layer1_attn_k tensor slot,
# live mapping descriptor, token0_layer1_attn_norm_status, and
# token0_layer1_attn_norm_activation.
# Outputs: rax = 1 when the layer-1 normalized activation is available and
# blk.1.attn_k.weight is exactly a two-dimensional Q8_0 [3072 x 1024] matrix
# whose complete payload span fits inside the mapping, after q8_0_matvec_f32
# writes token0_layer1_attn_k_output; otherwise rax = 0 and no layer-1 key
# matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the static layer-1 RMSNorm activation as the shared f32
# input vector, and writes exactly TOKEN0_LAYER1_ATTN_K_OUTPUT_BYTES into private
# static output storage on success. The mmap remains owned by _start and must be
# released separately.
# Error behavior: this is a status-only smoke gate for the next layer key
# projection, not final graph setup. Non-target synthetic GGUF fixtures and
# shape or bounds mismatches are skipped with status 0.
token0_layer1_attn_k_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer1_attn_norm_status], 1
	jne .Llayer1_attn_k_smoke_done
	cmp qword ptr [rip + layer1_attn_k_tensor_found], 1
	jne .Llayer1_attn_k_smoke_done
	cmp qword ptr [rip + layer1_attn_k_tensor_n_dimensions], 2
	jne .Llayer1_attn_k_smoke_done
	cmp qword ptr [rip + layer1_attn_k_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer1_attn_k_smoke_done
	cmp qword ptr [rip + layer1_attn_k_tensor_dim0], TOKEN0_LAYER1_ATTN_NORM_VALUES
	jne .Llayer1_attn_k_smoke_done
	cmp qword ptr [rip + layer1_attn_k_tensor_dim1], TOKEN0_LAYER1_ATTN_K_OUTPUT_VALUES
	jne .Llayer1_attn_k_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-1 key matrix start and prove the complete row-major Q8_0 payload fits
	# inside the live mapping before passing any mmap pointer to the math helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer1_attn_k_smoke_skip
	mov rdx, qword ptr [rip + layer1_attn_k_tensor_offset]
	test rdx, rdx
	js .Llayer1_attn_k_smoke_skip
	add rax, rdx
	jc .Llayer1_attn_k_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer1_attn_k_smoke_skip

	mov r8, TOKEN0_LAYER1_ATTN_NORM_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer1_attn_k_smoke_skip
	mov rcx, TOKEN0_LAYER1_ATTN_K_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer1_attn_k_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer1_attn_k_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer1_attn_k_smoke_skip
	add rdi, rax
	jc .Llayer1_attn_k_smoke_skip

	lea rsi, [rip + token0_layer1_attn_norm_activation]
	lea rdx, [rip + token0_layer1_attn_k_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer1_attn_k_smoke_skip:
	xor eax, eax

.Llayer1_attn_k_smoke_done:
	ret

.size token0_layer1_attn_k_matvec_smoke, . - token0_layer1_attn_k_matvec_smoke

.type token0_layer1_attn_v_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-1 attention-normalized
# activation through the reusable blk.1.attn_v.weight matrix.
# Inputs: no register inputs. Reads the process-owned layer1_attn_v tensor slot,
# live mapping descriptor, token0_layer1_attn_norm_status, and
# token0_layer1_attn_norm_activation.
# Outputs: rax = 1 when the layer-1 normalized activation is available and
# blk.1.attn_v.weight is exactly a two-dimensional Q8_0 [3072 x 1024] matrix
# whose complete payload span fits inside the mapping, after q8_0_matvec_f32
# writes token0_layer1_attn_v_output; otherwise rax = 0 and no layer-1 value
# matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the static layer-1 RMSNorm activation as the shared f32
# input vector, and writes exactly TOKEN0_LAYER1_ATTN_V_OUTPUT_BYTES into private
# static output storage on success. The mmap remains owned by _start and must be
# released separately.
# Error behavior: this smoke gate returns status only; summary printing is a
# separate status-gated step, and invalid inputs skip with status 0.
# Non-target synthetic GGUF fixtures and shape or bounds mismatches are skipped
# with status 0.
token0_layer1_attn_v_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer1_attn_norm_status], 1
	jne .Llayer1_attn_v_smoke_done
	cmp qword ptr [rip + layer1_attn_v_tensor_found], 1
	jne .Llayer1_attn_v_smoke_done
	cmp qword ptr [rip + layer1_attn_v_tensor_n_dimensions], 2
	jne .Llayer1_attn_v_smoke_done
	cmp qword ptr [rip + layer1_attn_v_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer1_attn_v_smoke_done
	cmp qword ptr [rip + layer1_attn_v_tensor_dim0], TOKEN0_LAYER1_ATTN_NORM_VALUES
	jne .Llayer1_attn_v_smoke_done
	cmp qword ptr [rip + layer1_attn_v_tensor_dim1], TOKEN0_LAYER1_ATTN_V_OUTPUT_VALUES
	jne .Llayer1_attn_v_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-1 value matrix start and prove the complete row-major Q8_0 payload
	# fits inside the live mapping before passing any mmap pointer to the helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer1_attn_v_smoke_skip
	mov rdx, qword ptr [rip + layer1_attn_v_tensor_offset]
	test rdx, rdx
	js .Llayer1_attn_v_smoke_skip
	add rax, rdx
	jc .Llayer1_attn_v_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer1_attn_v_smoke_skip

	mov r8, TOKEN0_LAYER1_ATTN_NORM_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer1_attn_v_smoke_skip
	mov rcx, TOKEN0_LAYER1_ATTN_V_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer1_attn_v_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer1_attn_v_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer1_attn_v_smoke_skip
	add rdi, rax
	jc .Llayer1_attn_v_smoke_skip

	lea rsi, [rip + token0_layer1_attn_norm_activation]
	lea rdx, [rip + token0_layer1_attn_v_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer1_attn_v_smoke_skip:
	xor eax, eax

.Llayer1_attn_v_smoke_done:
	ret

.size token0_layer1_attn_v_matvec_smoke, . - token0_layer1_attn_v_matvec_smoke

.type token0_layer1_attn_context_smoke, @function

# Contract: derive the token-0 layer-1 single-token attention context from the
# retained layer-1 value projection output.
# Inputs: no register inputs. Reads token0_layer1_attn_v_matvec_status,
# token0_layer1_attn_v_output, and the reusable layer-1 value and output
# projection tensor descriptors.
# Outputs: rax = 1 after writing a 4096-f32 token0_layer1_attn_context by
# repeating each 128-f32 KV-head value block four times for the associated query
# heads; otherwise rax = 0 and no layer-1 context bytes are written.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: reads only process-owned static layer-1 value-output
# storage and writes only process-owned static layer-1 context storage. The
# blk.1.attn_output.weight descriptor is used as a shape guard, but this
# function does not read any output-projection payload bytes.
# Error behavior: this smoke gate returns status only; invalid inputs and shape
# mismatches are skipped with status 0.
token0_layer1_attn_context_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer1_attn_v_matvec_status], 1
	jne .Llayer1_attn_context_done
	cmp qword ptr [rip + layer1_attn_v_tensor_dim1], TOKEN0_LAYER1_ATTN_V_OUTPUT_VALUES
	jne .Llayer1_attn_context_done
	cmp qword ptr [rip + layer1_attn_output_tensor_found], 1
	jne .Llayer1_attn_context_done
	cmp qword ptr [rip + layer1_attn_output_tensor_n_dimensions], 2
	jne .Llayer1_attn_context_done
	cmp qword ptr [rip + layer1_attn_output_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer1_attn_context_done
	cmp qword ptr [rip + layer1_attn_output_tensor_dim0], TOKEN0_LAYER1_ATTN_CONTEXT_VALUES
	jne .Llayer1_attn_context_done
	cmp qword ptr [rip + layer1_attn_output_tensor_dim1], TOKEN0_LAYER1_ATTN_NORM_VALUES
	jne .Llayer1_attn_context_done

	# With a one-token layer-local sequence, every query head attends to a single
	# key/value entry. Softmax is exactly 1, so grouped-query context
	# expansion is a pure copy from each KV head into its four query heads.
	lea rsi, [rip + token0_layer1_attn_v_output]
	lea rdi, [rip + token0_layer1_attn_context]
	mov r8, TOKEN0_ATTN_KV_HEADS

.Llayer1_attn_context_kv_head_loop:
	mov r9, TOKEN0_ATTN_QUERY_HEADS_PER_KV_HEAD

.Llayer1_attn_context_repeat_loop:
	mov rcx, TOKEN0_ATTN_HEAD_DIM_VALUES
	mov r10, rsi

.Llayer1_attn_context_copy_loop:
	mov eax, dword ptr [r10]
	mov dword ptr [rdi], eax
	add r10, 4
	add rdi, 4
	dec rcx
	jnz .Llayer1_attn_context_copy_loop

	dec r9
	jnz .Llayer1_attn_context_repeat_loop

	add rsi, TOKEN0_ATTN_HEAD_DIM_VALUES * 4
	dec r8
	jnz .Llayer1_attn_context_kv_head_loop

	mov eax, 1

.Llayer1_attn_context_done:
	ret

.size token0_layer1_attn_context_smoke, . - token0_layer1_attn_context_smoke

.type token0_layer1_attn_output_matvec_smoke, @function

# Contract: opportunistically project the token-0 layer-1 single-token attention
# context through the reusable blk.1.attn_output.weight matrix.
# Inputs: no register inputs. Reads the process-owned layer1_attn_output tensor
# slot, live mapping descriptor, token0_layer1_attn_context_status, and
# token0_layer1_attn_context.
# Outputs: rax = 1 when the layer-1 context is available and
# blk.1.attn_output.weight is exactly a two-dimensional Q8_0 [4096 x 3072]
# matrix whose complete payload span fits inside the mapping, after
# q8_0_matvec_f32 writes token0_layer1_attn_output; otherwise rax = 0 and no
# layer-1 output-projection matrix payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the static layer-1 context as the shared f32 input
# vector, and writes exactly TOKEN0_LAYER1_ATTN_OUTPUT_BYTES into private static
# output storage on success. The mmap remains owned by _start and must be
# released separately.
# Error behavior: this smoke gate returns status only; summary printing is a
# separate status-gated step, and invalid inputs skip with status 0.
# Non-target synthetic GGUF fixtures and shape or bounds mismatches are skipped
# with status 0.
token0_layer1_attn_output_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_layer1_attn_context_status], 1
	jne .Llayer1_attn_output_smoke_done
	cmp qword ptr [rip + layer1_attn_output_tensor_found], 1
	jne .Llayer1_attn_output_smoke_done
	cmp qword ptr [rip + layer1_attn_output_tensor_n_dimensions], 2
	jne .Llayer1_attn_output_smoke_done
	cmp qword ptr [rip + layer1_attn_output_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Llayer1_attn_output_smoke_done
	cmp qword ptr [rip + layer1_attn_output_tensor_dim0], TOKEN0_LAYER1_ATTN_CONTEXT_VALUES
	jne .Llayer1_attn_output_smoke_done
	cmp qword ptr [rip + layer1_attn_output_tensor_dim1], TOKEN0_LAYER1_ATTN_OUTPUT_VALUES
	jne .Llayer1_attn_output_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# layer-1 output-projection matrix start and prove the complete row-major
	# Q8_0 payload fits inside the live mapping before passing any mmap pointer
	# to the math helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Llayer1_attn_output_smoke_skip
	mov rdx, qword ptr [rip + layer1_attn_output_tensor_offset]
	test rdx, rdx
	js .Llayer1_attn_output_smoke_skip
	add rax, rdx
	jc .Llayer1_attn_output_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Llayer1_attn_output_smoke_skip

	mov r8, TOKEN0_LAYER1_ATTN_CONTEXT_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Llayer1_attn_output_smoke_skip
	mov rcx, TOKEN0_LAYER1_ATTN_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Llayer1_attn_output_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Llayer1_attn_output_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Llayer1_attn_output_smoke_skip
	add rdi, rax
	jc .Llayer1_attn_output_smoke_skip

	lea rsi, [rip + token0_layer1_attn_context]
	lea rdx, [rip + token0_layer1_attn_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Llayer1_attn_output_smoke_skip:
	xor eax, eax

.Llayer1_attn_output_smoke_done:
	ret

.size token0_layer1_attn_output_matvec_smoke, . - token0_layer1_attn_output_matvec_smoke

.type token0_layer1_post_attn_residual_smoke, @function

# Contract: derive the token-0 layer-1 post-attention residual activation.
# Inputs: no register inputs. Reads token0_post_ffn_residual_status,
# token0_layer1_attn_output_matvec_status, token0_post_ffn_residual, and
# token0_layer1_attn_output.
# Outputs: rax = 1 after writing 3072 f32 sums to
# token0_layer1_post_attn_residual; otherwise rax = 0 and no layer-1 residual
# bytes are written.
# Clobbers: caller-saved registers, xmm0, xmm1 and flags.
# Ownership/lifetime: reads only process-owned static layer-0 post-FFN residual
# and layer-1 attention output storage, writes only process-owned static
# layer-1 post-attention residual storage, and does not read any mapped tensor
# payload bytes.
# Error behavior: this is a status-only smoke gate for the layer-1 residual,
# not final layer execution. Missing prerequisites or non-target hidden width
# are skipped with status 0.
token0_layer1_post_attn_residual_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_post_ffn_residual_status], 1
	jne .Llayer1_post_attn_residual_done
	cmp qword ptr [rip + token0_layer1_attn_output_matvec_status], 1
	jne .Llayer1_post_attn_residual_done

	# The layer-1 output projection status proves the static output row was
	# written. Keep the descriptor width guard next to the add so future
	# layer-wise plumbing cannot reuse this hidden-size assumption silently.
	cmp qword ptr [rip + layer1_attn_output_tensor_dim1], TOKEN0_LAYER1_POST_ATTN_RESIDUAL_VALUES
	jne .Llayer1_post_attn_residual_done

	lea rsi, [rip + token0_post_ffn_residual]
	lea rdx, [rip + token0_layer1_attn_output]
	lea rdi, [rip + token0_layer1_post_attn_residual]
	mov rcx, TOKEN0_LAYER1_POST_ATTN_RESIDUAL_VALUES

.Llayer1_post_attn_residual_loop:
	vmovss xmm0, dword ptr [rsi]
	vmovss xmm1, dword ptr [rdx]
	vaddss xmm0, xmm0, xmm1
	vmovss dword ptr [rdi], xmm0
	add rsi, 4
	add rdx, 4
	add rdi, 4
	dec rcx
	jnz .Llayer1_post_attn_residual_loop

	mov eax, 1

.Llayer1_post_attn_residual_done:
	ret

.size token0_layer1_post_attn_residual_smoke, . - token0_layer1_post_attn_residual_smoke
