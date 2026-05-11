.type print_token0_attn_q_output_slice, @function

# Contract: print a fixed exact-hex slice from the first token-0 attention query
# projection output when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_attn_q_matvec_status and the first
# four f32 words of token0_attn_q_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_attn_q_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static output storage only during this
# call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_attn_q_output_slice:
	cmp qword ptr [rip + token0_attn_q_matvec_status], 1
	jne .Lprint_attn_q_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_attn_q_output0_f32_text]
	mov rdx, token0_attn_q_output0_f32_text_end - token0_attn_q_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_q_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_q_output1_f32_text]
	mov rdx, token0_attn_q_output1_f32_text_end - token0_attn_q_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_q_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_q_output2_f32_text]
	mov rdx, token0_attn_q_output2_f32_text_end - token0_attn_q_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_q_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_q_output3_f32_text]
	mov rdx, token0_attn_q_output3_f32_text_end - token0_attn_q_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_q_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_attn_q_slice_done:
	ret

.size print_token0_attn_q_output_slice, . - print_token0_attn_q_output_slice

.type print_token0_attn_k_output_slice, @function

# Contract: print a fixed exact-hex slice from the first token-0 attention key
# projection output when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_attn_k_matvec_status and the first
# four f32 words of token0_attn_k_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_attn_k_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static output storage only during this
# call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_attn_k_output_slice:
	cmp qword ptr [rip + token0_attn_k_matvec_status], 1
	jne .Lprint_attn_k_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_attn_k_output0_f32_text]
	mov rdx, token0_attn_k_output0_f32_text_end - token0_attn_k_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_k_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_k_output1_f32_text]
	mov rdx, token0_attn_k_output1_f32_text_end - token0_attn_k_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_k_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_k_output2_f32_text]
	mov rdx, token0_attn_k_output2_f32_text_end - token0_attn_k_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_k_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_k_output3_f32_text]
	mov rdx, token0_attn_k_output3_f32_text_end - token0_attn_k_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_k_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_attn_k_slice_done:
	ret

.size print_token0_attn_k_output_slice, . - print_token0_attn_k_output_slice

.type print_token0_attn_v_output_slice, @function

# Contract: print a fixed exact-hex slice from the first token-0 attention value
# projection output when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_attn_v_matvec_status and the first
# four f32 words of token0_attn_v_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_attn_v_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static output storage only during this
# call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_attn_v_output_slice:
	cmp qword ptr [rip + token0_attn_v_matvec_status], 1
	jne .Lprint_attn_v_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_attn_v_output0_f32_text]
	mov rdx, token0_attn_v_output0_f32_text_end - token0_attn_v_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_v_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_v_output1_f32_text]
	mov rdx, token0_attn_v_output1_f32_text_end - token0_attn_v_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_v_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_v_output2_f32_text]
	mov rdx, token0_attn_v_output2_f32_text_end - token0_attn_v_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_v_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_v_output3_f32_text]
	mov rdx, token0_attn_v_output3_f32_text_end - token0_attn_v_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_v_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_attn_v_slice_done:
	ret

.size print_token0_attn_v_output_slice, . - print_token0_attn_v_output_slice

.type print_token0_attn_context_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 single-token
# attention context when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_attn_context_status and the first
# four f32 words of token0_attn_context.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_attn_context_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static context storage only during
# this call and does not retain pointers.
# Error behavior: this is summary output for checking the context expansion;
# write failures are intentionally not surfaced separately.
print_token0_attn_context_slice:
	cmp qword ptr [rip + token0_attn_context_status], 1
	jne .Lprint_attn_context_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_attn_context0_f32_text]
	mov rdx, token0_attn_context0_f32_text_end - token0_attn_context0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_context]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_context1_f32_text]
	mov rdx, token0_attn_context1_f32_text_end - token0_attn_context1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_context + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_context2_f32_text]
	mov rdx, token0_attn_context2_f32_text_end - token0_attn_context2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_context + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_context3_f32_text]
	mov rdx, token0_attn_context3_f32_text_end - token0_attn_context3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_context + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_attn_context_slice_done:
	ret

.size print_token0_attn_context_slice, . - print_token0_attn_context_slice

.type print_token0_attn_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 attention output
# projection when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_attn_output_matvec_status and the
# first four f32 words of token0_attn_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_attn_output_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static output storage only during
# this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_attn_output_slice:
	cmp qword ptr [rip + token0_attn_output_matvec_status], 1
	jne .Lprint_attn_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_attn_output0_f32_text]
	mov rdx, token0_attn_output0_f32_text_end - token0_attn_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_output1_f32_text]
	mov rdx, token0_attn_output1_f32_text_end - token0_attn_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_output2_f32_text]
	mov rdx, token0_attn_output2_f32_text_end - token0_attn_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_attn_output3_f32_text]
	mov rdx, token0_attn_output3_f32_text_end - token0_attn_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_attn_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_attn_output_slice_done:
	ret

.size print_token0_attn_output_slice, . - print_token0_attn_output_slice

.type print_token0_post_attn_residual_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 post-attention
# residual when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_post_attn_residual_status and the
# first four f32 words of token0_post_attn_residual.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_post_attn_residual_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static residual storage only during
# this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_post_attn_residual_slice:
	cmp qword ptr [rip + token0_post_attn_residual_status], 1
	jne .Lprint_post_attn_residual_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_post_attn_residual0_f32_text]
	mov rdx, token0_post_attn_residual0_f32_text_end - token0_post_attn_residual0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_post_attn_residual]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_post_attn_residual1_f32_text]
	mov rdx, token0_post_attn_residual1_f32_text_end - token0_post_attn_residual1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_post_attn_residual + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_post_attn_residual2_f32_text]
	mov rdx, token0_post_attn_residual2_f32_text_end - token0_post_attn_residual2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_post_attn_residual + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_post_attn_residual3_f32_text]
	mov rdx, token0_post_attn_residual3_f32_text_end - token0_post_attn_residual3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_post_attn_residual + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_post_attn_residual_slice_done:
	ret

.size print_token0_post_attn_residual_slice, . - print_token0_post_attn_residual_slice

.type print_token0_ffn_norm_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 FFN RMSNorm
# activation when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_ffn_norm_status and the first four
# f32 words of token0_ffn_norm_activation.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_ffn_norm_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static FFN norm activation storage
# only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
