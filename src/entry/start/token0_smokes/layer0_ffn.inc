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
