.type print_layer3_attn_norm_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.3.attn_norm.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info while the model mapping is valid.
# Outputs: writes found flag, dimension count, first dimension, ggml_type, and
# relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads retained static descriptor fields only; it does not
# retain or dereference mapped-file pointers.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer3_attn_norm_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer3_attn_norm_tensor_found_text]
	mov rdx, layer3_attn_norm_tensor_found_text_end - layer3_attn_norm_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_norm_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_norm_tensor_n_dimensions_text]
	mov rdx, layer3_attn_norm_tensor_n_dimensions_text_end - layer3_attn_norm_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_norm_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_norm_tensor_dim0_text]
	mov rdx, layer3_attn_norm_tensor_dim0_text_end - layer3_attn_norm_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_norm_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_norm_tensor_ggml_type_text]
	mov rdx, layer3_attn_norm_tensor_ggml_type_text_end - layer3_attn_norm_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_norm_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_norm_tensor_offset_text]
	mov rdx, layer3_attn_norm_tensor_offset_text_end - layer3_attn_norm_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_norm_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer3_attn_norm_lookup_summary, . - print_layer3_attn_norm_lookup_summary

.type print_layer3_attn_q_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.3.attn_q.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info while the model mapping is valid.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads retained static descriptor fields only; it does not
# retain or dereference mapped-file pointers or inspect Q8_0 payload bytes.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer3_attn_q_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer3_attn_q_tensor_found_text]
	mov rdx, layer3_attn_q_tensor_found_text_end - layer3_attn_q_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_q_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_q_tensor_n_dimensions_text]
	mov rdx, layer3_attn_q_tensor_n_dimensions_text_end - layer3_attn_q_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_q_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_q_tensor_dim0_text]
	mov rdx, layer3_attn_q_tensor_dim0_text_end - layer3_attn_q_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_q_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_q_tensor_dim1_text]
	mov rdx, layer3_attn_q_tensor_dim1_text_end - layer3_attn_q_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_q_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_q_tensor_ggml_type_text]
	mov rdx, layer3_attn_q_tensor_ggml_type_text_end - layer3_attn_q_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_q_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_q_tensor_offset_text]
	mov rdx, layer3_attn_q_tensor_offset_text_end - layer3_attn_q_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_q_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer3_attn_q_lookup_summary, . - print_layer3_attn_q_lookup_summary

.type print_layer3_attn_k_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.3.attn_k.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info while the model mapping is valid.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads retained static descriptor fields only; it does not
# retain or dereference mapped-file pointers or inspect Q8_0 payload bytes.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer3_attn_k_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer3_attn_k_tensor_found_text]
	mov rdx, layer3_attn_k_tensor_found_text_end - layer3_attn_k_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_k_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_k_tensor_n_dimensions_text]
	mov rdx, layer3_attn_k_tensor_n_dimensions_text_end - layer3_attn_k_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_k_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_k_tensor_dim0_text]
	mov rdx, layer3_attn_k_tensor_dim0_text_end - layer3_attn_k_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_k_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_k_tensor_dim1_text]
	mov rdx, layer3_attn_k_tensor_dim1_text_end - layer3_attn_k_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_k_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_k_tensor_ggml_type_text]
	mov rdx, layer3_attn_k_tensor_ggml_type_text_end - layer3_attn_k_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_k_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_k_tensor_offset_text]
	mov rdx, layer3_attn_k_tensor_offset_text_end - layer3_attn_k_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_k_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer3_attn_k_lookup_summary, . - print_layer3_attn_k_lookup_summary

.type print_layer3_attn_v_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.3.attn_v.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info while the model mapping is valid.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads retained static descriptor fields only; it does not
# retain or dereference mapped-file pointers or inspect Q8_0 payload bytes.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer3_attn_v_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer3_attn_v_tensor_found_text]
	mov rdx, layer3_attn_v_tensor_found_text_end - layer3_attn_v_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_v_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_v_tensor_n_dimensions_text]
	mov rdx, layer3_attn_v_tensor_n_dimensions_text_end - layer3_attn_v_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_v_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_v_tensor_dim0_text]
	mov rdx, layer3_attn_v_tensor_dim0_text_end - layer3_attn_v_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_v_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_v_tensor_dim1_text]
	mov rdx, layer3_attn_v_tensor_dim1_text_end - layer3_attn_v_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_v_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_v_tensor_ggml_type_text]
	mov rdx, layer3_attn_v_tensor_ggml_type_text_end - layer3_attn_v_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_v_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_v_tensor_offset_text]
	mov rdx, layer3_attn_v_tensor_offset_text_end - layer3_attn_v_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_v_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer3_attn_v_lookup_summary, . - print_layer3_attn_v_lookup_summary

.type print_layer3_attn_output_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.3.attn_output.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info while the model mapping is valid.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads retained static descriptor fields only; it does not
# retain or dereference mapped-file pointers or inspect Q8_0 payload bytes.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer3_attn_output_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer3_attn_output_tensor_found_text]
	mov rdx, layer3_attn_output_tensor_found_text_end - layer3_attn_output_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_output_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_output_tensor_n_dimensions_text]
	mov rdx, layer3_attn_output_tensor_n_dimensions_text_end - layer3_attn_output_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_output_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_output_tensor_dim0_text]
	mov rdx, layer3_attn_output_tensor_dim0_text_end - layer3_attn_output_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_output_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_output_tensor_dim1_text]
	mov rdx, layer3_attn_output_tensor_dim1_text_end - layer3_attn_output_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_output_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_output_tensor_ggml_type_text]
	mov rdx, layer3_attn_output_tensor_ggml_type_text_end - layer3_attn_output_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_output_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_attn_output_tensor_offset_text]
	mov rdx, layer3_attn_output_tensor_offset_text_end - layer3_attn_output_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_attn_output_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer3_attn_output_lookup_summary, . - print_layer3_attn_output_lookup_summary

.type print_layer3_ffn_norm_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.3.ffn_norm.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info while the model mapping is valid.
# Outputs: writes found flag, dimension count, first dimension, ggml_type, and
# relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads retained static descriptor fields only; it does not
# retain or dereference mapped-file pointers or inspect f32 payload bytes.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer3_ffn_norm_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer3_ffn_norm_tensor_found_text]
	mov rdx, layer3_ffn_norm_tensor_found_text_end - layer3_ffn_norm_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_norm_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_norm_tensor_n_dimensions_text]
	mov rdx, layer3_ffn_norm_tensor_n_dimensions_text_end - layer3_ffn_norm_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_norm_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_norm_tensor_dim0_text]
	mov rdx, layer3_ffn_norm_tensor_dim0_text_end - layer3_ffn_norm_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_norm_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_norm_tensor_ggml_type_text]
	mov rdx, layer3_ffn_norm_tensor_ggml_type_text_end - layer3_ffn_norm_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_norm_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_norm_tensor_offset_text]
	mov rdx, layer3_ffn_norm_tensor_offset_text_end - layer3_ffn_norm_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_norm_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer3_ffn_norm_lookup_summary, . - print_layer3_ffn_norm_lookup_summary

.type print_layer3_ffn_gate_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.3.ffn_gate.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info while the model mapping is valid.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads retained static descriptor fields only; it does not
# retain or dereference mapped-file pointers or inspect Q8_0 payload bytes.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer3_ffn_gate_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer3_ffn_gate_tensor_found_text]
	mov rdx, layer3_ffn_gate_tensor_found_text_end - layer3_ffn_gate_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_gate_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_gate_tensor_n_dimensions_text]
	mov rdx, layer3_ffn_gate_tensor_n_dimensions_text_end - layer3_ffn_gate_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_gate_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_gate_tensor_dim0_text]
	mov rdx, layer3_ffn_gate_tensor_dim0_text_end - layer3_ffn_gate_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_gate_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_gate_tensor_dim1_text]
	mov rdx, layer3_ffn_gate_tensor_dim1_text_end - layer3_ffn_gate_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_gate_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_gate_tensor_ggml_type_text]
	mov rdx, layer3_ffn_gate_tensor_ggml_type_text_end - layer3_ffn_gate_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_gate_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_gate_tensor_offset_text]
	mov rdx, layer3_ffn_gate_tensor_offset_text_end - layer3_ffn_gate_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_gate_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer3_ffn_gate_lookup_summary, . - print_layer3_ffn_gate_lookup_summary

.type print_layer3_ffn_up_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.3.ffn_up.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info while the model mapping is valid.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads retained static descriptor fields only; it does not
# retain or dereference mapped-file pointers or inspect Q8_0 payload bytes.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer3_ffn_up_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer3_ffn_up_tensor_found_text]
	mov rdx, layer3_ffn_up_tensor_found_text_end - layer3_ffn_up_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_up_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_up_tensor_n_dimensions_text]
	mov rdx, layer3_ffn_up_tensor_n_dimensions_text_end - layer3_ffn_up_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_up_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_up_tensor_dim0_text]
	mov rdx, layer3_ffn_up_tensor_dim0_text_end - layer3_ffn_up_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_up_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_up_tensor_dim1_text]
	mov rdx, layer3_ffn_up_tensor_dim1_text_end - layer3_ffn_up_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_up_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_up_tensor_ggml_type_text]
	mov rdx, layer3_ffn_up_tensor_ggml_type_text_end - layer3_ffn_up_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_up_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_up_tensor_offset_text]
	mov rdx, layer3_ffn_up_tensor_offset_text_end - layer3_ffn_up_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_up_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer3_ffn_up_lookup_summary, . - print_layer3_ffn_up_lookup_summary

.type print_layer3_ffn_down_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.3.ffn_down.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info while the model mapping is valid.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads retained static descriptor fields only; it does not
# retain or dereference mapped-file pointers or inspect Q8_0 payload bytes.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer3_ffn_down_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer3_ffn_down_tensor_found_text]
	mov rdx, layer3_ffn_down_tensor_found_text_end - layer3_ffn_down_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_down_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_down_tensor_n_dimensions_text]
	mov rdx, layer3_ffn_down_tensor_n_dimensions_text_end - layer3_ffn_down_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_down_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_down_tensor_dim0_text]
	mov rdx, layer3_ffn_down_tensor_dim0_text_end - layer3_ffn_down_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_down_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_down_tensor_dim1_text]
	mov rdx, layer3_ffn_down_tensor_dim1_text_end - layer3_ffn_down_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_down_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_down_tensor_ggml_type_text]
	mov rdx, layer3_ffn_down_tensor_ggml_type_text_end - layer3_ffn_down_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_down_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer3_ffn_down_tensor_offset_text]
	mov rdx, layer3_ffn_down_tensor_offset_text_end - layer3_ffn_down_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer3_ffn_down_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer3_ffn_down_lookup_summary, . - print_layer3_ffn_down_lookup_summary
