print_token0_layer1_attn_norm_slice:
	cmp qword ptr [rip + token0_layer1_attn_norm_status], 1
	jne .Lprint_layer1_attn_norm_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_norm0_f32_text]
	mov rdx, token0_layer1_attn_norm0_f32_text_end - token0_layer1_attn_norm0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_norm_activation]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_norm1_f32_text]
	mov rdx, token0_layer1_attn_norm1_f32_text_end - token0_layer1_attn_norm1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_norm_activation + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_norm2_f32_text]
	mov rdx, token0_layer1_attn_norm2_f32_text_end - token0_layer1_attn_norm2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_norm_activation + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_norm3_f32_text]
	mov rdx, token0_layer1_attn_norm3_f32_text_end - token0_layer1_attn_norm3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_norm_activation + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer1_attn_norm_slice_done:
	ret

.size print_token0_layer1_attn_norm_slice, . - print_token0_layer1_attn_norm_slice

.type print_token0_layer1_attn_q_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-1 attention
# query projection when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer1_attn_q_matvec_status and the
# first four f32 words of token0_layer1_attn_q_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer1_attn_q_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static layer-1 query projection
# storage only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer1_attn_q_output_slice:
	cmp qword ptr [rip + token0_layer1_attn_q_matvec_status], 1
	jne .Lprint_layer1_attn_q_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_q_output0_f32_text]
	mov rdx, token0_layer1_attn_q_output0_f32_text_end - token0_layer1_attn_q_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_q_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_q_output1_f32_text]
	mov rdx, token0_layer1_attn_q_output1_f32_text_end - token0_layer1_attn_q_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_q_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_q_output2_f32_text]
	mov rdx, token0_layer1_attn_q_output2_f32_text_end - token0_layer1_attn_q_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_q_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_q_output3_f32_text]
	mov rdx, token0_layer1_attn_q_output3_f32_text_end - token0_layer1_attn_q_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_q_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer1_attn_q_output_slice_done:
	ret

.size print_token0_layer1_attn_q_output_slice, . - print_token0_layer1_attn_q_output_slice

.type print_token0_layer1_attn_k_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-1 attention
# key projection when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer1_attn_k_matvec_status and the
# first four f32 words of token0_layer1_attn_k_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer1_attn_k_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static layer-1 key projection storage
# only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer1_attn_k_output_slice:
	cmp qword ptr [rip + token0_layer1_attn_k_matvec_status], 1
	jne .Lprint_layer1_attn_k_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_k_output0_f32_text]
	mov rdx, token0_layer1_attn_k_output0_f32_text_end - token0_layer1_attn_k_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_k_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_k_output1_f32_text]
	mov rdx, token0_layer1_attn_k_output1_f32_text_end - token0_layer1_attn_k_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_k_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_k_output2_f32_text]
	mov rdx, token0_layer1_attn_k_output2_f32_text_end - token0_layer1_attn_k_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_k_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_k_output3_f32_text]
	mov rdx, token0_layer1_attn_k_output3_f32_text_end - token0_layer1_attn_k_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_k_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer1_attn_k_output_slice_done:
	ret

.size print_token0_layer1_attn_k_output_slice, . - print_token0_layer1_attn_k_output_slice

.type print_token0_layer1_attn_v_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-1 attention
# value projection when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer1_attn_v_matvec_status and the
# first four f32 words of token0_layer1_attn_v_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer1_attn_v_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static layer-1 value projection
# storage only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer1_attn_v_output_slice:
	cmp qword ptr [rip + token0_layer1_attn_v_matvec_status], 1
	jne .Lprint_layer1_attn_v_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_v_output0_f32_text]
	mov rdx, token0_layer1_attn_v_output0_f32_text_end - token0_layer1_attn_v_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_v_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_v_output1_f32_text]
	mov rdx, token0_layer1_attn_v_output1_f32_text_end - token0_layer1_attn_v_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_v_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_v_output2_f32_text]
	mov rdx, token0_layer1_attn_v_output2_f32_text_end - token0_layer1_attn_v_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_v_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_v_output3_f32_text]
	mov rdx, token0_layer1_attn_v_output3_f32_text_end - token0_layer1_attn_v_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_v_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer1_attn_v_output_slice_done:
	ret

.size print_token0_layer1_attn_v_output_slice, . - print_token0_layer1_attn_v_output_slice

.type print_token0_layer1_attn_context_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-1 attention
# context when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer1_attn_context_status and the
# first four f32 words of token0_layer1_attn_context.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer1_attn_context_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static layer-1 context storage only
# during this call and does not retain pointers.
# Error behavior: this is summary output for checking the context expansion;
# write failures are intentionally not surfaced separately.
print_token0_layer1_attn_context_slice:
	cmp qword ptr [rip + token0_layer1_attn_context_status], 1
	jne .Lprint_layer1_attn_context_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_context0_f32_text]
	mov rdx, token0_layer1_attn_context0_f32_text_end - token0_layer1_attn_context0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_context]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_context1_f32_text]
	mov rdx, token0_layer1_attn_context1_f32_text_end - token0_layer1_attn_context1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_context + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_context2_f32_text]
	mov rdx, token0_layer1_attn_context2_f32_text_end - token0_layer1_attn_context2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_context + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_context3_f32_text]
	mov rdx, token0_layer1_attn_context3_f32_text_end - token0_layer1_attn_context3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_context + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer1_attn_context_slice_done:
	ret

.size print_token0_layer1_attn_context_slice, . - print_token0_layer1_attn_context_slice

.type print_token0_layer1_attn_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-1 attention
# output projection when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer1_attn_output_matvec_status and
# the first four f32 words of token0_layer1_attn_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer1_attn_output_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static layer-1 output-projection
# storage only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer1_attn_output_slice:
	cmp qword ptr [rip + token0_layer1_attn_output_matvec_status], 1
	jne .Lprint_layer1_attn_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_output0_f32_text]
	mov rdx, token0_layer1_attn_output0_f32_text_end - token0_layer1_attn_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_output1_f32_text]
	mov rdx, token0_layer1_attn_output1_f32_text_end - token0_layer1_attn_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_output2_f32_text]
	mov rdx, token0_layer1_attn_output2_f32_text_end - token0_layer1_attn_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_output3_f32_text]
	mov rdx, token0_layer1_attn_output3_f32_text_end - token0_layer1_attn_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_attn_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer1_attn_output_slice_done:
	ret

.size print_token0_layer1_attn_output_slice, . - print_token0_layer1_attn_output_slice

.type print_token0_layer1_post_attn_residual_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-1
# post-attention residual when that residual smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer1_post_attn_residual_status and
# the first four f32 words of token0_layer1_post_attn_residual.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer1_post_attn_residual_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static layer-1 post-attention
# residual storage only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_layer1_post_attn_residual_slice:
	cmp qword ptr [rip + token0_layer1_post_attn_residual_status], 1
	jne .Lprint_layer1_post_attn_residual_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_layer1_post_attn_residual0_f32_text]
	mov rdx, token0_layer1_post_attn_residual0_f32_text_end - token0_layer1_post_attn_residual0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_post_attn_residual]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_post_attn_residual1_f32_text]
	mov rdx, token0_layer1_post_attn_residual1_f32_text_end - token0_layer1_post_attn_residual1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_post_attn_residual + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_post_attn_residual2_f32_text]
	mov rdx, token0_layer1_post_attn_residual2_f32_text_end - token0_layer1_post_attn_residual2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_post_attn_residual + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_layer1_post_attn_residual3_f32_text]
	mov rdx, token0_layer1_post_attn_residual3_f32_text_end - token0_layer1_post_attn_residual3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_layer1_post_attn_residual + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_layer1_post_attn_residual_slice_done:
	ret

.size print_token0_layer1_post_attn_residual_slice, . - print_token0_layer1_post_attn_residual_slice
