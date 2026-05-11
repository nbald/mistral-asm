print_token0_ffn_norm_slice:
	cmp qword ptr [rip + token0_ffn_norm_status], 1
	jne .Lprint_ffn_norm_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_ffn_norm0_f32_text]
	mov rdx, token0_ffn_norm0_f32_text_end - token0_ffn_norm0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_norm_activation]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_norm1_f32_text]
	mov rdx, token0_ffn_norm1_f32_text_end - token0_ffn_norm1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_norm_activation + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_norm2_f32_text]
	mov rdx, token0_ffn_norm2_f32_text_end - token0_ffn_norm2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_norm_activation + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_norm3_f32_text]
	mov rdx, token0_ffn_norm3_f32_text_end - token0_ffn_norm3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_norm_activation + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_ffn_norm_slice_done:
	ret

.size print_token0_ffn_norm_slice, . - print_token0_ffn_norm_slice

.type print_token0_ffn_gate_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 FFN gate projection
# output when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_ffn_gate_matvec_status and the first
# four f32 words of token0_ffn_gate_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_ffn_gate_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static FFN gate output storage only
# during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_ffn_gate_output_slice:
	cmp qword ptr [rip + token0_ffn_gate_matvec_status], 1
	jne .Lprint_ffn_gate_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_ffn_gate_output0_f32_text]
	mov rdx, token0_ffn_gate_output0_f32_text_end - token0_ffn_gate_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_gate_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_gate_output1_f32_text]
	mov rdx, token0_ffn_gate_output1_f32_text_end - token0_ffn_gate_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_gate_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_gate_output2_f32_text]
	mov rdx, token0_ffn_gate_output2_f32_text_end - token0_ffn_gate_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_gate_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_gate_output3_f32_text]
	mov rdx, token0_ffn_gate_output3_f32_text_end - token0_ffn_gate_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_gate_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_ffn_gate_output_slice_done:
	ret

.size print_token0_ffn_gate_output_slice, . - print_token0_ffn_gate_output_slice

.type print_token0_ffn_up_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 FFN up projection
# output when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_ffn_up_matvec_status and the first
# four f32 words of token0_ffn_up_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_ffn_up_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static FFN up output storage only
# during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_ffn_up_output_slice:
	cmp qword ptr [rip + token0_ffn_up_matvec_status], 1
	jne .Lprint_ffn_up_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_ffn_up_output0_f32_text]
	mov rdx, token0_ffn_up_output0_f32_text_end - token0_ffn_up_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_up_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_up_output1_f32_text]
	mov rdx, token0_ffn_up_output1_f32_text_end - token0_ffn_up_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_up_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_up_output2_f32_text]
	mov rdx, token0_ffn_up_output2_f32_text_end - token0_ffn_up_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_up_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_up_output3_f32_text]
	mov rdx, token0_ffn_up_output3_f32_text_end - token0_ffn_up_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_up_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_ffn_up_output_slice_done:
	ret

.size print_token0_ffn_up_output_slice, . - print_token0_ffn_up_output_slice

.type print_token0_ffn_swiglu_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 FFN SwiGLU
# activation when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_ffn_swiglu_status and the first four
# f32 words of token0_ffn_swiglu_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_ffn_swiglu_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static FFN SwiGLU activation storage
# only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_ffn_swiglu_output_slice:
	cmp qword ptr [rip + token0_ffn_swiglu_status], 1
	jne .Lprint_ffn_swiglu_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_ffn_swiglu_output0_f32_text]
	mov rdx, token0_ffn_swiglu_output0_f32_text_end - token0_ffn_swiglu_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_swiglu_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_swiglu_output1_f32_text]
	mov rdx, token0_ffn_swiglu_output1_f32_text_end - token0_ffn_swiglu_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_swiglu_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_swiglu_output2_f32_text]
	mov rdx, token0_ffn_swiglu_output2_f32_text_end - token0_ffn_swiglu_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_swiglu_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_swiglu_output3_f32_text]
	mov rdx, token0_ffn_swiglu_output3_f32_text_end - token0_ffn_swiglu_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_swiglu_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_ffn_swiglu_output_slice_done:
	ret

.size print_token0_ffn_swiglu_output_slice, . - print_token0_ffn_swiglu_output_slice

.type print_token0_ffn_down_output_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 FFN down projection
# output when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_ffn_down_matvec_status and the first
# four f32 words of token0_ffn_down_output.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_ffn_down_matvec_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static FFN down output storage only
# during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_ffn_down_output_slice:
	cmp qword ptr [rip + token0_ffn_down_matvec_status], 1
	jne .Lprint_ffn_down_output_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_ffn_down_output0_f32_text]
	mov rdx, token0_ffn_down_output0_f32_text_end - token0_ffn_down_output0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_down_output]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_down_output1_f32_text]
	mov rdx, token0_ffn_down_output1_f32_text_end - token0_ffn_down_output1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_down_output + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_down_output2_f32_text]
	mov rdx, token0_ffn_down_output2_f32_text_end - token0_ffn_down_output2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_down_output + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_ffn_down_output3_f32_text]
	mov rdx, token0_ffn_down_output3_f32_text_end - token0_ffn_down_output3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_ffn_down_output + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_ffn_down_output_slice_done:
	ret

.size print_token0_ffn_down_output_slice, . - print_token0_ffn_down_output_slice

.type print_token0_post_ffn_residual_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 post-FFN residual
# activation when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_post_ffn_residual_status and the
# first four f32 words of token0_post_ffn_residual.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_post_ffn_residual_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static post-FFN residual storage only
# during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
print_token0_post_ffn_residual_slice:
	cmp qword ptr [rip + token0_post_ffn_residual_status], 1
	jne .Lprint_post_ffn_residual_slice_done

	mov rdi, 1
	lea rsi, [rip + token0_post_ffn_residual0_f32_text]
	mov rdx, token0_post_ffn_residual0_f32_text_end - token0_post_ffn_residual0_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_post_ffn_residual]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_post_ffn_residual1_f32_text]
	mov rdx, token0_post_ffn_residual1_f32_text_end - token0_post_ffn_residual1_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_post_ffn_residual + 4]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_post_ffn_residual2_f32_text]
	mov rdx, token0_post_ffn_residual2_f32_text_end - token0_post_ffn_residual2_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_post_ffn_residual + 8]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + token0_post_ffn_residual3_f32_text]
	mov rdx, token0_post_ffn_residual3_f32_text_end - token0_post_ffn_residual3_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + token0_post_ffn_residual + 12]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

.Lprint_post_ffn_residual_slice_done:
	ret

.size print_token0_post_ffn_residual_slice, . - print_token0_post_ffn_residual_slice

.type print_token0_layer1_attn_norm_slice, @function

# Contract: print a fixed exact-hex slice from the token-0 layer-1 attention
# RMSNorm activation when that smoke path succeeded.
# Inputs: no register inputs. Reads token0_layer1_attn_norm_status and the
# first four f32 words of token0_layer1_attn_norm_activation.
# Outputs: writes four labeled raw f32 bit patterns to stdout when
# token0_layer1_attn_norm_status is 1; writes nothing otherwise.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u32_hex.
# Ownership/lifetime: reads process-owned static layer-1 RMSNorm activation
# storage only during this call and does not retain pointers.
# Error behavior: this is summary output for oracle comparison; write failures
# are intentionally not surfaced separately.
