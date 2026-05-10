.type dequant_token0_embedding_smoke, @function

# Contract: opportunistically dequantize token ID 0 from the retained
# token_embd.weight descriptor into static f32 activation storage.
# Inputs: no register inputs. Reads the process-owned GGUF summary and live
# mapping descriptor populated by gguf_validate_file.
# Outputs: rax = 1 when a Q8_0 two-dimensional token_embd.weight descriptor is
# target-shaped enough to dequantize token 0 into token_embedding_activation;
# rax = 0 when the descriptor is absent, not Q8_0, not a whole Q8_0 row shape,
# too wide for the static activation buffer, or does not leave one full row
# inside the mapping.
# Clobbers: caller-saved registers, xmm0, xmm1 and flags.
# Ownership/lifetime: reads the mapped tensor payload only during the helper
# call and writes at most TOKEN_EMBEDDING_ACTIVATION_BYTES into static process
# storage. The mmap remains owned by _start and must be released separately.
# Error behavior: this is a smoke gate, not the final graph setup validator.
# Non-target synthetic GGUF fixtures are skipped with status 0; a successful
# return proves q8_0_dequant_token_embedding accepted the guarded token-0 row.
dequant_token0_embedding_smoke:
	xor eax, eax
	cmp qword ptr [rip + gguf_summary_lookup_tensor_found], 1
	jne .Lembedding_smoke_done
	cmp qword ptr [rip + gguf_summary_lookup_tensor_n_dimensions], 2
	jne .Lembedding_smoke_done
	cmp qword ptr [rip + gguf_summary_lookup_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Lembedding_smoke_done

	mov r8, qword ptr [rip + gguf_summary_lookup_tensor_dim0]
	test r8, r8
	jz .Lembedding_smoke_done
	js .Lembedding_smoke_done
	test r8, Q8_0_BLOCK_SIZE - 1
	jne .Lembedding_smoke_done
	cmp r8, TOKEN_EMBEDDING_ACTIVATION_VALUES
	ja .Lembedding_smoke_done

	mov rcx, qword ptr [rip + gguf_summary_lookup_tensor_dim1]
	test rcx, rcx
	jz .Lembedding_smoke_done
	js .Lembedding_smoke_done

	# Tensor offsets are file-relative only after adding the aligned tensor-data
	# base. Reject wraparound before converting that file offset into an mmap
	# pointer.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Lembedding_smoke_skip
	mov rdx, qword ptr [rip + gguf_summary_lookup_tensor_offset]
	test rdx, rdx
	js .Lembedding_smoke_skip
	add rax, rdx
	jc .Lembedding_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Lembedding_smoke_skip

	# One token row must fit inside the mapping before the math helper may touch
	# payload bytes. The helper still owns row-shape and token-id validation.
	mov r9, r8
	shr r9, 5
	imul r9, r9, Q8_0_BLOCK_BYTES
	jo .Lembedding_smoke_skip
	mov r11, r10
	sub r11, rax
	cmp r11, r9
	jb .Lembedding_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Lembedding_smoke_skip
	add rdi, rax
	jc .Lembedding_smoke_skip
	lea rsi, [rip + token_embedding_activation]
	xor edx, edx
	call q8_0_dequant_token_embedding
	test eax, eax
	jnz .Lembedding_smoke_skip

	mov eax, 1
	ret

.Lembedding_smoke_skip:
	xor eax, eax

.Lembedding_smoke_done:
	ret

.size dequant_token0_embedding_smoke, . - dequant_token0_embedding_smoke

.type token0_attn_norm_smoke, @function

# Contract: opportunistically apply the retained first-layer attention RMSNorm
# weights to the token-0 embedding activation produced by
# dequant_token0_embedding_smoke.
# Inputs: no register inputs. Reads the process-owned GGUF summary, live mapping
# descriptor, token0_embedding_dequant_status, and token_embedding_activation.
# Outputs: rax = 1 when token 0 was dequantized, the RMSNorm epsilon metadata
# was captured, and a one-dimensional f32 blk.0.attn_norm.weight span with
# matching width fits in the mapping, after rmsnorm_f32 writes
# token0_attn_norm_activation; otherwise rax = 0 and no RMSNorm payload bytes
# are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2, xmm3 and flags.
# Ownership/lifetime: reads mapped weight bytes only during rmsnorm_f32, reads
# the static token embedding activation twice through that helper, and writes at
# most TOKEN_EMBEDDING_ACTIVATION_BYTES into separate static output storage. The
# mmap remains owned by _start and must be released separately.
# Error behavior: this is a smoke gate for the first normalized activation, not
# final graph setup. Non-target synthetic GGUF fixtures and shape mismatches are
# skipped with status 0.
token0_attn_norm_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_embedding_dequant_status], 1
	jne .Lattn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_norm_rms_epsilon_found], 1
	jne .Lattn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_norm_tensor_found], 1
	jne .Lattn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_norm_tensor_n_dimensions], 1
	jne .Lattn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_norm_tensor_ggml_type], GGML_TYPE_F32
	jne .Lattn_norm_smoke_done

	mov r8, qword ptr [rip + gguf_summary_attn_norm_tensor_dim0]
	test r8, r8
	jz .Lattn_norm_smoke_done
	js .Lattn_norm_smoke_done
	cmp r8, TOKEN_EMBEDDING_ACTIVATION_VALUES
	ja .Lattn_norm_smoke_done

	# RMSNorm consumes the full activation row produced from token_embd.weight.
	# Require the retained embedding and norm descriptors to agree on width so a
	# malformed synthetic file cannot normalize an uninitialized tail.
	cmp r8, qword ptr [rip + gguf_summary_lookup_tensor_dim0]
	jne .Lattn_norm_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve and
	# bound the f32 weight span before giving the math helper any mmap pointer.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Lattn_norm_smoke_skip
	mov rdx, qword ptr [rip + gguf_summary_attn_norm_tensor_offset]
	test rdx, rdx
	js .Lattn_norm_smoke_skip
	add rax, rdx
	jc .Lattn_norm_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Lattn_norm_smoke_skip

	# The static width cap above makes count * sizeof(f32) overflow impossible.
	mov r9, r8
	shl r9, 2
	mov r11, r10
	sub r11, rax
	cmp r11, r9
	jb .Lattn_norm_smoke_skip

	mov rsi, qword ptr [rip + gguf_mapping_base]
	test rsi, rsi
	jz .Lattn_norm_smoke_skip
	add rsi, rax
	jc .Lattn_norm_smoke_skip

	lea rdi, [rip + token_embedding_activation]
	lea rdx, [rip + token0_attn_norm_activation]
	mov rcx, r8
	vmovss xmm0, dword ptr [rip + gguf_summary_attn_norm_rms_epsilon_f32]
	call rmsnorm_f32

	mov eax, 1
	ret

.Lattn_norm_smoke_skip:
	xor eax, eax

.Lattn_norm_smoke_done:
	ret

.size token0_attn_norm_smoke, . - token0_attn_norm_smoke

.type token0_attn_q_matvec_smoke, @function

# Contract: opportunistically project the token-0 first attention-normalized
# activation through the retained blk.0.attn_q.weight matrix.
# Inputs: no register inputs. Reads the process-owned GGUF summary, live mapping
# descriptor, token0_attn_norm_status, and token0_attn_norm_activation.
# Outputs: rax = 1 when token0_attn_norm_activation is available and a
# two-dimensional Q8_0 blk.0.attn_q.weight matrix with matching input width and
# exact target output row count fits inside the mapping, after q8_0_matvec_f32
# writes token0_attn_q_output; otherwise rax = 0 and no query matrix payload is
# read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during q8_0_matvec_f32,
# reads the static normalized activation as the shared f32 input vector, and
# writes exactly TOKEN0_ATTN_Q_OUTPUT_BYTES into static output storage. The
# mmap remains owned by _start and must be released separately.
# Error behavior: this is a smoke gate for the first attention query projection,
# not final graph setup. Non-target synthetic GGUF fixtures and shape mismatches
# are skipped with status 0.
token0_attn_q_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_attn_norm_status], 1
	jne .Lattn_q_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_q_tensor_found], 1
	jne .Lattn_q_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_q_tensor_n_dimensions], 2
	jne .Lattn_q_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_q_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Lattn_q_smoke_done

	mov r8, qword ptr [rip + gguf_summary_attn_q_tensor_dim0]
	test r8, r8
	jz .Lattn_q_smoke_done
	js .Lattn_q_smoke_done
	test r8, Q8_0_BLOCK_SIZE - 1
	jne .Lattn_q_smoke_done
	cmp r8, TOKEN_EMBEDDING_ACTIVATION_VALUES
	ja .Lattn_q_smoke_done

	# The query projection consumes the same normalized hidden row produced by the
	# RMSNorm smoke. Require the matrix input dimension to match that row exactly
	# before deriving Q8_0 row strides.
	cmp r8, qword ptr [rip + gguf_summary_attn_norm_tensor_dim0]
	jne .Lattn_q_smoke_done

	mov rcx, qword ptr [rip + gguf_summary_attn_q_tensor_dim1]
	test rcx, rcx
	jz .Lattn_q_smoke_done
	js .Lattn_q_smoke_done
	cmp rcx, TOKEN0_ATTN_Q_OUTPUT_VALUES
	jne .Lattn_q_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# matrix start and prove the full row-major Q8_0 matrix fits in the live mmap
	# before handing any payload pointer to the math helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Lattn_q_smoke_skip
	mov rdx, qword ptr [rip + gguf_summary_attn_q_tensor_offset]
	test rdx, rdx
	js .Lattn_q_smoke_skip
	add rax, rdx
	jc .Lattn_q_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Lattn_q_smoke_skip

	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Lattn_q_smoke_skip
	mov rdx, rcx
	imul rdx, r11
	jo .Lattn_q_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Lattn_q_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Lattn_q_smoke_skip
	add rdi, rax
	jc .Lattn_q_smoke_skip

	lea rsi, [rip + token0_attn_norm_activation]
	lea rdx, [rip + token0_attn_q_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Lattn_q_smoke_skip:
	xor eax, eax

.Lattn_q_smoke_done:
	ret

.size token0_attn_q_matvec_smoke, . - token0_attn_q_matvec_smoke

.type token0_attn_k_matvec_smoke, @function

# Contract: opportunistically project the token-0 first attention-normalized
# activation through the retained blk.0.attn_k.weight matrix.
# Inputs: no register inputs. Reads the process-owned GGUF summary, live mapping
# descriptor, token0_attn_norm_status, and token0_attn_norm_activation.
# Outputs: rax = 1 when token0_attn_norm_activation is available and a
# two-dimensional Q8_0 blk.0.attn_k.weight matrix with matching input width and
# exact target output row count fits inside the mapping, after q8_0_matvec_f32
# writes token0_attn_k_output; otherwise rax = 0 and no key matrix payload is
# read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during q8_0_matvec_f32,
# reads the static normalized activation as the shared f32 input vector, and
# writes exactly TOKEN0_ATTN_K_OUTPUT_BYTES into static output storage. The
# mmap remains owned by _start and must be released separately.
# Error behavior: this is a smoke gate for the first attention key projection,
# not final graph setup. Non-target synthetic GGUF fixtures and shape mismatches
# are skipped with status 0.
token0_attn_k_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_attn_norm_status], 1
	jne .Lattn_k_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_k_tensor_found], 1
	jne .Lattn_k_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_k_tensor_n_dimensions], 2
	jne .Lattn_k_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_k_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Lattn_k_smoke_done

	mov r8, qword ptr [rip + gguf_summary_attn_k_tensor_dim0]
	test r8, r8
	jz .Lattn_k_smoke_done
	js .Lattn_k_smoke_done
	test r8, Q8_0_BLOCK_SIZE - 1
	jne .Lattn_k_smoke_done
	cmp r8, TOKEN_EMBEDDING_ACTIVATION_VALUES
	ja .Lattn_k_smoke_done

	# The key projection consumes the same normalized hidden row produced by the
	# RMSNorm smoke. Require the matrix input dimension to match that row exactly
	# before deriving Q8_0 row strides.
	cmp r8, qword ptr [rip + gguf_summary_attn_norm_tensor_dim0]
	jne .Lattn_k_smoke_done

	mov rcx, qword ptr [rip + gguf_summary_attn_k_tensor_dim1]
	test rcx, rcx
	jz .Lattn_k_smoke_done
	js .Lattn_k_smoke_done
	cmp rcx, TOKEN0_ATTN_K_OUTPUT_VALUES
	jne .Lattn_k_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# matrix start and prove the full row-major Q8_0 matrix fits in the live mmap
	# before handing any payload pointer to the math helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Lattn_k_smoke_skip
	mov rdx, qword ptr [rip + gguf_summary_attn_k_tensor_offset]
	test rdx, rdx
	js .Lattn_k_smoke_skip
	add rax, rdx
	jc .Lattn_k_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Lattn_k_smoke_skip

	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Lattn_k_smoke_skip
	mov rdx, rcx
	imul rdx, r11
	jo .Lattn_k_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Lattn_k_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Lattn_k_smoke_skip
	add rdi, rax
	jc .Lattn_k_smoke_skip

	lea rsi, [rip + token0_attn_norm_activation]
	lea rdx, [rip + token0_attn_k_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Lattn_k_smoke_skip:
	xor eax, eax

.Lattn_k_smoke_done:
	ret

.size token0_attn_k_matvec_smoke, . - token0_attn_k_matvec_smoke

.type token0_attn_v_matvec_smoke, @function

# Contract: opportunistically project the token-0 first attention-normalized
# activation through the retained blk.0.attn_v.weight matrix.
# Inputs: no register inputs. Reads the process-owned GGUF summary, live mapping
# descriptor, token0_attn_norm_status, and token0_attn_norm_activation.
# Outputs: rax = 1 when token0_attn_norm_activation is available and a
# two-dimensional Q8_0 blk.0.attn_v.weight matrix with matching input width and
# exact target output row count fits inside the mapping, after q8_0_matvec_f32
# writes token0_attn_v_output; otherwise rax = 0 and no value matrix payload is
# read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during q8_0_matvec_f32,
# reads the static normalized activation as the shared f32 input vector, and
# writes exactly TOKEN0_ATTN_V_OUTPUT_BYTES into static output storage. The
# mmap remains owned by _start and must be released separately.
# Error behavior: this is a smoke gate for the first attention value projection,
# not final graph setup. Non-target synthetic GGUF fixtures and shape mismatches
# are skipped with status 0.
token0_attn_v_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_attn_norm_status], 1
	jne .Lattn_v_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_v_tensor_found], 1
	jne .Lattn_v_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_v_tensor_n_dimensions], 2
	jne .Lattn_v_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_v_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Lattn_v_smoke_done

	mov r8, qword ptr [rip + gguf_summary_attn_v_tensor_dim0]
	test r8, r8
	jz .Lattn_v_smoke_done
	js .Lattn_v_smoke_done
	test r8, Q8_0_BLOCK_SIZE - 1
	jne .Lattn_v_smoke_done
	cmp r8, TOKEN_EMBEDDING_ACTIVATION_VALUES
	ja .Lattn_v_smoke_done

	# The value projection consumes the same normalized hidden row produced by the
	# RMSNorm smoke. Require the matrix input dimension to match that row exactly
	# before deriving Q8_0 row strides.
	cmp r8, qword ptr [rip + gguf_summary_attn_norm_tensor_dim0]
	jne .Lattn_v_smoke_done

	mov rcx, qword ptr [rip + gguf_summary_attn_v_tensor_dim1]
	test rcx, rcx
	jz .Lattn_v_smoke_done
	js .Lattn_v_smoke_done
	cmp rcx, TOKEN0_ATTN_V_OUTPUT_VALUES
	jne .Lattn_v_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# matrix start and prove the full row-major Q8_0 matrix fits in the live mmap
	# before handing any payload pointer to the math helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Lattn_v_smoke_skip
	mov rdx, qword ptr [rip + gguf_summary_attn_v_tensor_offset]
	test rdx, rdx
	js .Lattn_v_smoke_skip
	add rax, rdx
	jc .Lattn_v_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Lattn_v_smoke_skip

	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Lattn_v_smoke_skip
	mov rdx, rcx
	imul rdx, r11
	jo .Lattn_v_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Lattn_v_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Lattn_v_smoke_skip
	add rdi, rax
	jc .Lattn_v_smoke_skip

	lea rsi, [rip + token0_attn_norm_activation]
	lea rdx, [rip + token0_attn_v_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Lattn_v_smoke_skip:
	xor eax, eax

.Lattn_v_smoke_done:
	ret

.size token0_attn_v_matvec_smoke, . - token0_attn_v_matvec_smoke

.type token0_attn_context_smoke, @function

# Contract: derive the token-0 single-token attention context from the retained
# first value projection output.
# Inputs: no register inputs. Reads token0_attn_v_matvec_status,
# token0_attn_v_output, and the retained value and output projection tensor
# descriptors.
# Outputs: rax = 1 after writing a 4096-f32 token0_attn_context by repeating
# each 128-f32 KV-head value block four times for the associated query heads;
# otherwise rax = 0 and no context bytes are written.
# Clobbers: caller-saved registers and flags.
# Ownership/lifetime: reads only process-owned static value-output storage and
# writes only process-owned static context storage. The output projection
# descriptor is used as a shape guard, but this function does not read any
# blk.0.attn_output.weight payload bytes.
# Error behavior: this is a smoke gate for the first single-token attention
# context, not final attention setup. Shape mismatches are skipped with status 0.
token0_attn_context_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_attn_v_matvec_status], 1
	jne .Lattn_context_done
	cmp qword ptr [rip + gguf_summary_attn_v_tensor_dim1], TOKEN0_ATTN_V_OUTPUT_VALUES
	jne .Lattn_context_done
	cmp qword ptr [rip + gguf_summary_attn_output_tensor_found], 1
	jne .Lattn_context_done
	cmp qword ptr [rip + gguf_summary_attn_output_tensor_n_dimensions], 2
	jne .Lattn_context_done
	cmp qword ptr [rip + gguf_summary_attn_output_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Lattn_context_done
	cmp qword ptr [rip + gguf_summary_attn_output_tensor_dim0], TOKEN0_ATTN_CONTEXT_VALUES
	jne .Lattn_context_done
	cmp qword ptr [rip + gguf_summary_attn_output_tensor_dim1], TOKEN_EMBEDDING_ACTIVATION_VALUES
	jne .Lattn_context_done

	# With a one-token sequence, each attention row has one score, so softmax is
	# exactly 1. The context is therefore the value vector, expanded from the
	# model's grouped-query layout: eight KV heads, four query heads per KV head,
	# and 128 f32 values per head.
	lea rsi, [rip + token0_attn_v_output]
	lea rdi, [rip + token0_attn_context]
	mov r8, TOKEN0_ATTN_KV_HEADS

.Lattn_context_kv_head_loop:
	mov r9, TOKEN0_ATTN_QUERY_HEADS_PER_KV_HEAD

.Lattn_context_repeat_loop:
	mov rcx, TOKEN0_ATTN_HEAD_DIM_VALUES
	mov r10, rsi

.Lattn_context_copy_loop:
	mov eax, dword ptr [r10]
	mov dword ptr [rdi], eax
	add r10, 4
	add rdi, 4
	dec rcx
	jnz .Lattn_context_copy_loop

	dec r9
	jnz .Lattn_context_repeat_loop

	add rsi, TOKEN0_ATTN_HEAD_DIM_VALUES * 4
	dec r8
	jnz .Lattn_context_kv_head_loop

	mov eax, 1

.Lattn_context_done:
	ret

.size token0_attn_context_smoke, . - token0_attn_context_smoke

.type token0_attn_output_matvec_smoke, @function

# Contract: opportunistically project the token-0 single-token attention context
# through the retained blk.0.attn_output.weight matrix.
# Inputs: no register inputs. Reads the process-owned GGUF summary, live mapping
# descriptor, token0_attn_context_status, and token0_attn_context.
# Outputs: rax = 1 when token0_attn_context is available and a two-dimensional
# Q8_0 blk.0.attn_output.weight matrix with exact 4096-value input width,
# exact 3072-row output shape, and bounded payload bytes fits inside the
# mapping, after q8_0_matvec_f32 writes token0_attn_output; otherwise rax = 0
# and no output-projection matrix payload is read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the static attention context as the shared f32 input
# vector, and writes exactly TOKEN0_ATTN_OUTPUT_BYTES into static output
# storage on success. The mmap remains owned by _start and must be released
# separately.
# Error behavior: this is a smoke gate for the first attention output
# projection, not final graph setup. Non-target synthetic GGUF fixtures and
# shape mismatches are skipped with status 0.
token0_attn_output_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_attn_context_status], 1
	jne .Lattn_output_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_output_tensor_found], 1
	jne .Lattn_output_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_output_tensor_n_dimensions], 2
	jne .Lattn_output_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_output_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Lattn_output_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_output_tensor_dim0], TOKEN0_ATTN_CONTEXT_VALUES
	jne .Lattn_output_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_output_tensor_dim1], TOKEN0_ATTN_OUTPUT_VALUES
	jne .Lattn_output_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# output projection start and prove the complete row-major Q8_0 matrix fits
	# in the live mapping before handing any payload pointer to the math helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Lattn_output_smoke_skip
	mov rdx, qword ptr [rip + gguf_summary_attn_output_tensor_offset]
	test rdx, rdx
	js .Lattn_output_smoke_skip
	add rax, rdx
	jc .Lattn_output_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Lattn_output_smoke_skip

	mov r8, TOKEN0_ATTN_CONTEXT_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Lattn_output_smoke_skip
	mov rcx, TOKEN0_ATTN_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Lattn_output_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Lattn_output_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Lattn_output_smoke_skip
	add rdi, rax
	jc .Lattn_output_smoke_skip

	lea rsi, [rip + token0_attn_context]
	lea rdx, [rip + token0_attn_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Lattn_output_smoke_skip:
	xor eax, eax

.Lattn_output_smoke_done:
	ret

.size token0_attn_output_matvec_smoke, . - token0_attn_output_matvec_smoke

.type token0_post_attn_residual_smoke, @function

# Contract: derive the token-0 post-attention residual activation.
# Inputs: no register inputs. Reads token0_embedding_dequant_status,
# token0_attn_output_matvec_status, token_embedding_activation, and
# token0_attn_output.
# Outputs: rax = 1 after writing 3072 f32 sums to
# token0_post_attn_residual; otherwise rax = 0 and no residual bytes are
# written.
# Clobbers: caller-saved registers, xmm0, xmm1 and flags.
# Ownership/lifetime: reads only process-owned static activation and attention
# output storage, writes only process-owned static residual storage, and does
# not read any mapped tensor payload bytes.
# Error behavior: this is a smoke gate for the first post-attention residual,
# not final layer execution. Missing prerequisites or non-target hidden width
# are skipped with status 0.
token0_post_attn_residual_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_embedding_dequant_status], 1
	jne .Lpost_attn_residual_done
	cmp qword ptr [rip + token0_attn_output_matvec_status], 1
	jne .Lpost_attn_residual_done

	# The embedding smoke can accept narrower synthetic rows. The residual add
	# consumes a complete hidden row, so require the target 3072-f32 width before
	# reading the static activation tail.
	cmp qword ptr [rip + gguf_summary_lookup_tensor_dim0], TOKEN0_POST_ATTN_RESIDUAL_VALUES
	jne .Lpost_attn_residual_done

	lea rsi, [rip + token_embedding_activation]
	lea rdx, [rip + token0_attn_output]
	lea rdi, [rip + token0_post_attn_residual]
	mov rcx, TOKEN0_POST_ATTN_RESIDUAL_VALUES

.Lpost_attn_residual_loop:
	vmovss xmm0, dword ptr [rsi]
	vmovss xmm1, dword ptr [rdx]
	vaddss xmm0, xmm0, xmm1
	vmovss dword ptr [rdi], xmm0
	add rsi, 4
	add rdx, 4
	add rdi, 4
	dec rcx
	jnz .Lpost_attn_residual_loop

	mov eax, 1

.Lpost_attn_residual_done:
	ret

.size token0_post_attn_residual_smoke, . - token0_post_attn_residual_smoke

.type token0_ffn_norm_smoke, @function

# Contract: opportunistically apply the retained first-layer FFN RMSNorm weights
# to the token-0 post-attention residual activation.
# Inputs: no register inputs. Reads the process-owned GGUF summary, live mapping
# descriptor, token0_post_attn_residual_status, and token0_post_attn_residual.
# Outputs: rax = 1 when the residual is available, the RMSNorm epsilon metadata
# was captured, and blk.0.ffn_norm.weight is exactly a one-dimensional f32
# [3072] tensor whose full payload span fits inside the mapping, after
# rmsnorm_f32 writes token0_ffn_norm_activation; otherwise rax = 0 and no FFN
# norm payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2, xmm3 and flags.
# Ownership/lifetime: reads mapped weight bytes only during rmsnorm_f32, reads
# the static post-attention residual twice through that helper, and writes
# exactly TOKEN0_FFN_NORM_BYTES into separate static output storage on success.
# The mmap remains owned by _start and must be released separately.
# Error behavior: this is a smoke gate for the first FFN-normalized activation,
# not final graph setup. Non-target synthetic GGUF fixtures and shape or bounds
# mismatches are skipped with status 0.
token0_ffn_norm_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_post_attn_residual_status], 1
	jne .Lffn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_attn_norm_rms_epsilon_found], 1
	jne .Lffn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_norm_tensor_found], 1
	jne .Lffn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_norm_tensor_n_dimensions], 1
	jne .Lffn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_norm_tensor_ggml_type], GGML_TYPE_F32
	jne .Lffn_norm_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_norm_tensor_dim0], TOKEN0_FFN_NORM_VALUES
	jne .Lffn_norm_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve and
	# bound the complete 3072-f32 FFN norm span before passing any mmap pointer to
	# the shared RMSNorm helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Lffn_norm_smoke_skip
	mov rdx, qword ptr [rip + gguf_summary_ffn_norm_tensor_offset]
	test rdx, rdx
	js .Lffn_norm_smoke_skip
	add rax, rdx
	jc .Lffn_norm_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Lffn_norm_smoke_skip

	mov r9, TOKEN0_FFN_NORM_BYTES
	mov r11, r10
	sub r11, rax
	cmp r11, r9
	jb .Lffn_norm_smoke_skip

	mov rsi, qword ptr [rip + gguf_mapping_base]
	test rsi, rsi
	jz .Lffn_norm_smoke_skip
	add rsi, rax
	jc .Lffn_norm_smoke_skip

	lea rdi, [rip + token0_post_attn_residual]
	lea rdx, [rip + token0_ffn_norm_activation]
	mov rcx, TOKEN0_FFN_NORM_VALUES
	vmovss xmm0, dword ptr [rip + gguf_summary_attn_norm_rms_epsilon_f32]
	call rmsnorm_f32

	mov eax, 1
	ret

.Lffn_norm_smoke_skip:
	xor eax, eax

.Lffn_norm_smoke_done:
	ret

.size token0_ffn_norm_smoke, . - token0_ffn_norm_smoke

.type token0_ffn_gate_matvec_smoke, @function

# Contract: opportunistically project the token-0 FFN-normalized activation
# through the retained blk.0.ffn_gate.weight matrix.
# Inputs: no register inputs. Reads the process-owned GGUF summary, live mapping
# descriptor, token0_ffn_norm_status, and token0_ffn_norm_activation.
# Outputs: rax = 1 when token0_ffn_norm_activation is available and
# blk.0.ffn_gate.weight is exactly a two-dimensional Q8_0 [3072 x 9216] matrix
# whose complete payload span fits inside the mapping, after q8_0_matvec_f32
# writes token0_ffn_gate_output; otherwise rax = 0 and no FFN gate matrix
# payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the static FFN-normalized activation as the shared f32
# input vector, and writes exactly TOKEN0_FFN_GATE_OUTPUT_BYTES into static
# output storage on success. The mmap remains owned by _start and must be
# released separately.
# Error behavior: this is a smoke gate for the first FFN gate projection, not
# final FFN setup. Non-target synthetic GGUF fixtures and shape or bounds
# mismatches are skipped with status 0.
token0_ffn_gate_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_ffn_norm_status], 1
	jne .Lffn_gate_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_gate_tensor_found], 1
	jne .Lffn_gate_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_gate_tensor_n_dimensions], 2
	jne .Lffn_gate_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_gate_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Lffn_gate_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_gate_tensor_dim0], TOKEN0_FFN_NORM_VALUES
	jne .Lffn_gate_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_gate_tensor_dim1], TOKEN0_FFN_GATE_OUTPUT_VALUES
	jne .Lffn_gate_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# FFN gate projection start and prove the complete row-major Q8_0 matrix fits
	# in the live mapping before handing any payload pointer to the math helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Lffn_gate_smoke_skip
	mov rdx, qword ptr [rip + gguf_summary_ffn_gate_tensor_offset]
	test rdx, rdx
	js .Lffn_gate_smoke_skip
	add rax, rdx
	jc .Lffn_gate_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Lffn_gate_smoke_skip

	mov r8, TOKEN0_FFN_NORM_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Lffn_gate_smoke_skip
	mov rcx, TOKEN0_FFN_GATE_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Lffn_gate_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Lffn_gate_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Lffn_gate_smoke_skip
	add rdi, rax
	jc .Lffn_gate_smoke_skip

	lea rsi, [rip + token0_ffn_norm_activation]
	lea rdx, [rip + token0_ffn_gate_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Lffn_gate_smoke_skip:
	xor eax, eax

.Lffn_gate_smoke_done:
	ret

.size token0_ffn_gate_matvec_smoke, . - token0_ffn_gate_matvec_smoke

.type token0_ffn_up_matvec_smoke, @function

# Contract: opportunistically project the token-0 FFN-normalized activation
# through the retained blk.0.ffn_up.weight matrix.
# Inputs: no register inputs. Reads the process-owned GGUF summary, live mapping
# descriptor, token0_ffn_norm_status, and token0_ffn_norm_activation.
# Outputs: rax = 1 when token0_ffn_norm_activation is available and
# blk.0.ffn_up.weight is exactly a two-dimensional Q8_0 [3072 x 9216] matrix
# whose complete payload span fits inside the mapping, after q8_0_matvec_f32
# writes token0_ffn_up_output; otherwise rax = 0 and no FFN up matrix payload
# bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the static FFN-normalized activation as the shared f32
# input vector, and writes exactly TOKEN0_FFN_UP_OUTPUT_BYTES into static output
# storage on success. The mmap remains owned by _start and must be released
# separately.
# Error behavior: this is a smoke gate for the first FFN up projection, not
# final FFN setup. Non-target synthetic GGUF fixtures and shape or bounds
# mismatches are skipped with status 0.
token0_ffn_up_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_ffn_norm_status], 1
	jne .Lffn_up_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_up_tensor_found], 1
	jne .Lffn_up_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_up_tensor_n_dimensions], 2
	jne .Lffn_up_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_up_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Lffn_up_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_up_tensor_dim0], TOKEN0_FFN_NORM_VALUES
	jne .Lffn_up_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_up_tensor_dim1], TOKEN0_FFN_UP_OUTPUT_VALUES
	jne .Lffn_up_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# FFN up projection start and prove the complete row-major Q8_0 matrix fits
	# in the live mapping before handing any payload pointer to the math helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Lffn_up_smoke_skip
	mov rdx, qword ptr [rip + gguf_summary_ffn_up_tensor_offset]
	test rdx, rdx
	js .Lffn_up_smoke_skip
	add rax, rdx
	jc .Lffn_up_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Lffn_up_smoke_skip

	mov r8, TOKEN0_FFN_NORM_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Lffn_up_smoke_skip
	mov rcx, TOKEN0_FFN_UP_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Lffn_up_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Lffn_up_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Lffn_up_smoke_skip
	add rdi, rax
	jc .Lffn_up_smoke_skip

	lea rsi, [rip + token0_ffn_norm_activation]
	lea rdx, [rip + token0_ffn_up_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Lffn_up_smoke_skip:
	xor eax, eax

.Lffn_up_smoke_done:
	ret

.size token0_ffn_up_matvec_smoke, . - token0_ffn_up_matvec_smoke

.type token0_ffn_swiglu_smoke, @function

# Contract: derive the token-0 first FFN SwiGLU activation from the retained
# gate and up projection outputs.
# Inputs: no register inputs. Reads token0_ffn_gate_matvec_status,
# token0_ffn_up_matvec_status, token0_ffn_gate_output, token0_ffn_up_output,
# and the retained FFN gate/up/down tensor descriptors.
# Outputs: rax = 1 after writing 9216 f32 values to token0_ffn_swiglu_output,
# each equal to silu(token0_ffn_gate_output[i]) * token0_ffn_up_output[i];
# otherwise rax = 0 and no activation bytes are written.
# Clobbers: caller-saved registers, x87 stack registers, x87 status, and flags.
# Ownership/lifetime: reads only process-owned static gate and up projection
# outputs and writes only process-owned static activation storage. The retained
# blk.0.ffn_down.weight descriptor is used as a shape guard for the consumer of
# this activation, but this function reads no mapped tensor payload bytes.
# Error behavior: this is a smoke gate for the first FFN activation, not final
# graph setup. Missing prerequisites or non-target FFN widths are skipped with
# status 0.
token0_ffn_swiglu_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_ffn_gate_matvec_status], 1
	jne .Lffn_swiglu_done
	cmp qword ptr [rip + token0_ffn_up_matvec_status], 1
	jne .Lffn_swiglu_done
	cmp qword ptr [rip + gguf_summary_ffn_gate_tensor_dim1], TOKEN0_FFN_SWIGLU_VALUES
	jne .Lffn_swiglu_done
	cmp qword ptr [rip + gguf_summary_ffn_up_tensor_dim1], TOKEN0_FFN_SWIGLU_VALUES
	jne .Lffn_swiglu_done
	cmp qword ptr [rip + gguf_summary_ffn_down_tensor_found], 1
	jne .Lffn_swiglu_done
	cmp qword ptr [rip + gguf_summary_ffn_down_tensor_n_dimensions], 2
	jne .Lffn_swiglu_done
	cmp qword ptr [rip + gguf_summary_ffn_down_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Lffn_swiglu_done
	cmp qword ptr [rip + gguf_summary_ffn_down_tensor_dim0], TOKEN0_FFN_SWIGLU_VALUES
	jne .Lffn_swiglu_done
	cmp qword ptr [rip + gguf_summary_ffn_down_tensor_dim1], TOKEN0_FFN_NORM_VALUES
	jne .Lffn_swiglu_done

	# The activation is pure static math: gate and up projections were already
	# bounded by their own smoke gates. The down descriptor only proves that the
	# produced width is the width the next Q8_0 matvec will consume.
	lea rdi, [rip + token0_ffn_gate_output]
	lea rsi, [rip + token0_ffn_up_output]
	lea rdx, [rip + token0_ffn_swiglu_output]
	mov ecx, TOKEN0_FFN_SWIGLU_VALUES
	call swiglu_f32

	mov eax, 1

.Lffn_swiglu_done:
	ret

.size token0_ffn_swiglu_smoke, . - token0_ffn_swiglu_smoke

.type token0_ffn_down_matvec_smoke, @function

# Contract: opportunistically project the token-0 FFN SwiGLU activation through
# the retained blk.0.ffn_down.weight matrix.
# Inputs: no register inputs. Reads the process-owned GGUF summary, live mapping
# descriptor, token0_ffn_swiglu_status, and token0_ffn_swiglu_output.
# Outputs: rax = 1 when token0_ffn_swiglu_output is available and
# blk.0.ffn_down.weight is exactly a two-dimensional Q8_0 [9216 x 3072] matrix
# whose complete payload span fits inside the mapping, after q8_0_matvec_f32
# writes token0_ffn_down_output; otherwise rax = 0 and no FFN down matrix
# payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2 and flags. The matvec
# helper preserves any callee-saved registers it uses internally.
# Ownership/lifetime: reads mapped Q8_0 matrix bytes only during
# q8_0_matvec_f32, reads the static SwiGLU activation as the shared f32 input
# vector, and writes exactly TOKEN0_FFN_DOWN_OUTPUT_BYTES into static output
# storage on success. The mmap remains owned by _start and must be released
# separately.
# Error behavior: this is a smoke gate for the first FFN down projection, not
# final FFN setup. Non-target synthetic GGUF fixtures and shape or bounds
# mismatches are skipped with status 0.
token0_ffn_down_matvec_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_ffn_swiglu_status], 1
	jne .Lffn_down_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_down_tensor_found], 1
	jne .Lffn_down_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_down_tensor_n_dimensions], 2
	jne .Lffn_down_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_down_tensor_ggml_type], GGML_TYPE_Q8_0
	jne .Lffn_down_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_down_tensor_dim0], TOKEN0_FFN_SWIGLU_VALUES
	jne .Lffn_down_smoke_done
	cmp qword ptr [rip + gguf_summary_ffn_down_tensor_dim1], TOKEN0_FFN_DOWN_OUTPUT_VALUES
	jne .Lffn_down_smoke_done

	# Tensor offsets are relative to the aligned tensor-data base. Resolve the
	# FFN down projection start and prove the complete row-major Q8_0 matrix fits
	# in the live mapping before handing any payload pointer to the math helper.
	mov rax, qword ptr [rip + gguf_summary_tensor_data_offset]
	test rax, rax
	js .Lffn_down_smoke_skip
	mov rdx, qword ptr [rip + gguf_summary_ffn_down_tensor_offset]
	test rdx, rdx
	js .Lffn_down_smoke_skip
	add rax, rdx
	jc .Lffn_down_smoke_skip

	mov r10, qword ptr [rip + gguf_mapping_size]
	cmp rax, r10
	jae .Lffn_down_smoke_skip

	mov r8, TOKEN0_FFN_SWIGLU_VALUES
	mov r9, r8
	shr r9, 5
	mov r11, r9
	imul r11, r11, Q8_0_BLOCK_BYTES
	jo .Lffn_down_smoke_skip
	mov rcx, TOKEN0_FFN_DOWN_OUTPUT_VALUES
	mov rdx, rcx
	imul rdx, r11
	jo .Lffn_down_smoke_skip

	mov r11, r10
	sub r11, rax
	cmp r11, rdx
	jb .Lffn_down_smoke_skip

	mov rdi, qword ptr [rip + gguf_mapping_base]
	test rdi, rdi
	jz .Lffn_down_smoke_skip
	add rdi, rax
	jc .Lffn_down_smoke_skip

	lea rsi, [rip + token0_ffn_swiglu_output]
	lea rdx, [rip + token0_ffn_down_output]
	mov r8, r9
	call q8_0_matvec_f32

	mov eax, 1
	ret

.Lffn_down_smoke_skip:
	xor eax, eax

.Lffn_down_smoke_done:
	ret

.size token0_ffn_down_matvec_smoke, . - token0_ffn_down_matvec_smoke

.type token0_post_ffn_residual_smoke, @function

# Contract: derive the token-0 post-FFN residual activation.
# Inputs: no register inputs. Reads token0_post_attn_residual_status,
# token0_ffn_down_matvec_status, token0_post_attn_residual, and
# token0_ffn_down_output.
# Outputs: rax = 1 after writing 3072 f32 sums to
# token0_post_ffn_residual; otherwise rax = 0 and no post-FFN residual bytes
# are written.
# Clobbers: caller-saved registers, xmm0, xmm1 and flags.
# Ownership/lifetime: reads only process-owned static post-attention residual
# and FFN down output storage, writes only process-owned static post-FFN
# residual storage, and does not read any mapped tensor payload bytes.
# Error behavior: this is a smoke gate for the first post-FFN residual, not
# final layer execution. Missing prerequisites or non-target hidden width are
# skipped with status 0.
token0_post_ffn_residual_smoke:
	xor eax, eax
	cmp qword ptr [rip + token0_ffn_down_matvec_status], 1
	jne .Lpost_ffn_residual_done
	cmp qword ptr [rip + token0_post_attn_residual_status], 1
	jne .Lpost_ffn_residual_done

	# The FFN down matvec status proves the static output row was written. Keep
	# this direct width check next to the add so later wider/narrower smoke paths
	# cannot accidentally reuse a stale hidden-size assumption.
	cmp qword ptr [rip + gguf_summary_ffn_down_tensor_dim1], TOKEN0_POST_FFN_RESIDUAL_VALUES
	jne .Lpost_ffn_residual_done

	lea rsi, [rip + token0_post_attn_residual]
	lea rdx, [rip + token0_ffn_down_output]
	lea rdi, [rip + token0_post_ffn_residual]
	mov rcx, TOKEN0_POST_FFN_RESIDUAL_VALUES

.Lpost_ffn_residual_loop:
	vmovss xmm0, dword ptr [rsi]
	vmovss xmm1, dword ptr [rdx]
	vaddss xmm0, xmm0, xmm1
	vmovss dword ptr [rdi], xmm0
	add rsi, 4
	add rdx, 4
	add rdi, 4
	dec rcx
	jnz .Lpost_ffn_residual_loop

	mov eax, 1

.Lpost_ffn_residual_done:
	ret

.size token0_post_ffn_residual_smoke, . - token0_post_ffn_residual_smoke

.type token0_layer1_attn_norm_smoke, @function

# Contract: opportunistically apply the reusable layer-1 attention RMSNorm
# weights to the token-0 post-FFN residual activation.
# Inputs: no register inputs. Reads the process-owned layer1_attn_norm tensor
# slot, live mapping descriptor, retained RMSNorm epsilon metadata,
# token0_post_ffn_residual_status, and token0_post_ffn_residual.
# Outputs: rax = 1 when the post-FFN residual is available, the epsilon metadata
# was captured, and blk.1.attn_norm.weight is exactly a one-dimensional f32
# [3072] tensor whose full payload span fits inside the mapping, after
# rmsnorm_f32 writes token0_layer1_attn_norm_activation; otherwise rax = 0 and no
# layer-1 RMSNorm payload bytes are read.
# Clobbers: caller-saved registers, xmm0, xmm1, xmm2, xmm3 and flags.
# Ownership/lifetime: reads mapped weight bytes only during rmsnorm_f32, reads
# the static post-FFN residual twice through that helper, and writes exactly
# TOKEN0_LAYER1_ATTN_NORM_BYTES into separate static output storage on success.
# The mmap remains owned by _start and must be released separately.
# Error behavior: this is a status-only smoke gate for the next layer's
# attention-normalized activation, not final graph setup. Non-target synthetic
# GGUF fixtures and shape or bounds mismatches are skipped with status 0.
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

