
usage_error_text:
	.ascii "mistral-asm: use --help or provide a GGUF file\n"
usage_error_text_end:

gguf_ok_text:
	.ascii "GGUF summary\n"
gguf_ok_text_end:

tensor_count_text:
	.ascii "tensor_count: "
tensor_count_text_end:

metadata_count_text:
	.ascii "metadata_kv_count: "
metadata_count_text_end:

architecture_text:
	.ascii "architecture: "
architecture_text_end:

context_length_text:
	.ascii "context_length: "
context_length_text_end:

block_count_text:
	.ascii "block_count: "
block_count_text_end:

vocab_size_text:
	.ascii "vocab_size: "
vocab_size_text_end:

attn_norm_rms_epsilon_found_text:
	.ascii "attn_norm_rms_epsilon_found: "
attn_norm_rms_epsilon_found_text_end:

attn_norm_rms_epsilon_f32_text:
	.ascii "attn_norm_rms_epsilon_f32_hex: "
attn_norm_rms_epsilon_f32_text_end:

tensor_data_offset_text:
	.ascii "tensor_data_offset: "
tensor_data_offset_text_end:

tensor_infos_offset_text:
	.ascii "tensor_infos_offset: "
tensor_infos_offset_text_end:

first_tensor_name_text:
	.ascii "first_tensor_name: "
first_tensor_name_text_end:

first_tensor_n_dimensions_text:
	.ascii "first_tensor_n_dimensions: "
first_tensor_n_dimensions_text_end:

first_tensor_dim0_text:
	.ascii "first_tensor_dim0: "
first_tensor_dim0_text_end:

first_tensor_dim1_text:
	.ascii "first_tensor_dim1: "
first_tensor_dim1_text_end:

first_tensor_dim2_text:
	.ascii "first_tensor_dim2: "
first_tensor_dim2_text_end:

first_tensor_dim3_text:
	.ascii "first_tensor_dim3: "
first_tensor_dim3_text_end:

first_tensor_ggml_type_text:
	.ascii "first_tensor_ggml_type: "
first_tensor_ggml_type_text_end:

first_tensor_offset_text:
	.ascii "first_tensor_offset: "
first_tensor_offset_text_end:

lookup_tensor_found_text:
	.ascii "lookup_tensor_found: "
lookup_tensor_found_text_end:

lookup_tensor_name_text:
	.ascii "lookup_tensor_name: "
lookup_tensor_name_text_end:

lookup_tensor_n_dimensions_text:
	.ascii "lookup_tensor_n_dimensions: "
lookup_tensor_n_dimensions_text_end:

lookup_tensor_dim0_text:
	.ascii "lookup_tensor_dim0: "
lookup_tensor_dim0_text_end:

lookup_tensor_dim1_text:
	.ascii "lookup_tensor_dim1: "
lookup_tensor_dim1_text_end:

lookup_tensor_dim2_text:
	.ascii "lookup_tensor_dim2: "
lookup_tensor_dim2_text_end:

lookup_tensor_dim3_text:
	.ascii "lookup_tensor_dim3: "
lookup_tensor_dim3_text_end:

lookup_tensor_ggml_type_text:
	.ascii "lookup_tensor_ggml_type: "
lookup_tensor_ggml_type_text_end:

lookup_tensor_offset_text:
	.ascii "lookup_tensor_offset: "
lookup_tensor_offset_text_end:

layer1_attn_norm_tensor_found_text:
	.ascii "layer1_attn_norm_tensor_found: "
layer1_attn_norm_tensor_found_text_end:

layer1_attn_norm_tensor_n_dimensions_text:
	.ascii "layer1_attn_norm_tensor_n_dimensions: "
layer1_attn_norm_tensor_n_dimensions_text_end:

layer1_attn_norm_tensor_dim0_text:
	.ascii "layer1_attn_norm_tensor_dim0: "
layer1_attn_norm_tensor_dim0_text_end:

layer1_attn_norm_tensor_ggml_type_text:
	.ascii "layer1_attn_norm_tensor_ggml_type: "
layer1_attn_norm_tensor_ggml_type_text_end:

layer1_attn_norm_tensor_offset_text:
	.ascii "layer1_attn_norm_tensor_offset: "
layer1_attn_norm_tensor_offset_text_end:

layer1_attn_q_tensor_found_text:
	.ascii "layer1_attn_q_tensor_found: "
layer1_attn_q_tensor_found_text_end:

layer1_attn_q_tensor_n_dimensions_text:
	.ascii "layer1_attn_q_tensor_n_dimensions: "
layer1_attn_q_tensor_n_dimensions_text_end:

layer1_attn_q_tensor_dim0_text:
	.ascii "layer1_attn_q_tensor_dim0: "
layer1_attn_q_tensor_dim0_text_end:

layer1_attn_q_tensor_dim1_text:
	.ascii "layer1_attn_q_tensor_dim1: "
layer1_attn_q_tensor_dim1_text_end:

layer1_attn_q_tensor_ggml_type_text:
	.ascii "layer1_attn_q_tensor_ggml_type: "
layer1_attn_q_tensor_ggml_type_text_end:

layer1_attn_q_tensor_offset_text:
	.ascii "layer1_attn_q_tensor_offset: "
layer1_attn_q_tensor_offset_text_end:

layer1_attn_k_tensor_found_text:
	.ascii "layer1_attn_k_tensor_found: "
layer1_attn_k_tensor_found_text_end:

layer1_attn_k_tensor_n_dimensions_text:
	.ascii "layer1_attn_k_tensor_n_dimensions: "
layer1_attn_k_tensor_n_dimensions_text_end:

layer1_attn_k_tensor_dim0_text:
	.ascii "layer1_attn_k_tensor_dim0: "
layer1_attn_k_tensor_dim0_text_end:

layer1_attn_k_tensor_dim1_text:
	.ascii "layer1_attn_k_tensor_dim1: "
layer1_attn_k_tensor_dim1_text_end:

layer1_attn_k_tensor_ggml_type_text:
	.ascii "layer1_attn_k_tensor_ggml_type: "
layer1_attn_k_tensor_ggml_type_text_end:

layer1_attn_k_tensor_offset_text:
	.ascii "layer1_attn_k_tensor_offset: "
layer1_attn_k_tensor_offset_text_end:

layer1_attn_v_tensor_found_text:
	.ascii "layer1_attn_v_tensor_found: "
layer1_attn_v_tensor_found_text_end:

layer1_attn_v_tensor_n_dimensions_text:
	.ascii "layer1_attn_v_tensor_n_dimensions: "
layer1_attn_v_tensor_n_dimensions_text_end:

layer1_attn_v_tensor_dim0_text:
	.ascii "layer1_attn_v_tensor_dim0: "
layer1_attn_v_tensor_dim0_text_end:

layer1_attn_v_tensor_dim1_text:
	.ascii "layer1_attn_v_tensor_dim1: "
layer1_attn_v_tensor_dim1_text_end:

layer1_attn_v_tensor_ggml_type_text:
	.ascii "layer1_attn_v_tensor_ggml_type: "
layer1_attn_v_tensor_ggml_type_text_end:

layer1_attn_v_tensor_offset_text:
	.ascii "layer1_attn_v_tensor_offset: "
layer1_attn_v_tensor_offset_text_end:

layer1_attn_output_tensor_found_text:
	.ascii "layer1_attn_output_tensor_found: "
layer1_attn_output_tensor_found_text_end:

layer1_attn_output_tensor_n_dims_text:
	.ascii "layer1_attn_output_tensor_n_dimensions: "
layer1_attn_output_tensor_n_dims_text_end:

layer1_attn_output_tensor_dim0_text:
	.ascii "layer1_attn_output_tensor_dim0: "
layer1_attn_output_tensor_dim0_text_end:

layer1_attn_output_tensor_dim1_text:
	.ascii "layer1_attn_output_tensor_dim1: "
layer1_attn_output_tensor_dim1_text_end:

layer1_attn_output_tensor_ggml_type_text:
	.ascii "layer1_attn_output_tensor_ggml_type: "
layer1_attn_output_tensor_ggml_type_text_end:

layer1_attn_output_tensor_offset_text:
	.ascii "layer1_attn_output_tensor_offset: "
layer1_attn_output_tensor_offset_text_end:

layer1_ffn_norm_tensor_found_text:
	.ascii "layer1_ffn_norm_tensor_found: "
layer1_ffn_norm_tensor_found_text_end:

layer1_ffn_norm_tensor_n_dimensions_text:
	.ascii "layer1_ffn_norm_tensor_n_dimensions: "
layer1_ffn_norm_tensor_n_dimensions_text_end:

layer1_ffn_norm_tensor_dim0_text:
	.ascii "layer1_ffn_norm_tensor_dim0: "
layer1_ffn_norm_tensor_dim0_text_end:

layer1_ffn_norm_tensor_ggml_type_text:
	.ascii "layer1_ffn_norm_tensor_ggml_type: "
layer1_ffn_norm_tensor_ggml_type_text_end:

layer1_ffn_norm_tensor_offset_text:
	.ascii "layer1_ffn_norm_tensor_offset: "
layer1_ffn_norm_tensor_offset_text_end:

layer1_ffn_gate_tensor_found_text:
	.ascii "layer1_ffn_gate_tensor_found: "
layer1_ffn_gate_tensor_found_text_end:

layer1_ffn_gate_tensor_n_dimensions_text:
	.ascii "layer1_ffn_gate_tensor_n_dimensions: "
layer1_ffn_gate_tensor_n_dimensions_text_end:

layer1_ffn_gate_tensor_dim0_text:
	.ascii "layer1_ffn_gate_tensor_dim0: "
layer1_ffn_gate_tensor_dim0_text_end:

layer1_ffn_gate_tensor_dim1_text:
	.ascii "layer1_ffn_gate_tensor_dim1: "
layer1_ffn_gate_tensor_dim1_text_end:

layer1_ffn_gate_tensor_ggml_type_text:
	.ascii "layer1_ffn_gate_tensor_ggml_type: "
layer1_ffn_gate_tensor_ggml_type_text_end:

layer1_ffn_gate_tensor_offset_text:
	.ascii "layer1_ffn_gate_tensor_offset: "
layer1_ffn_gate_tensor_offset_text_end:

layer1_ffn_up_tensor_found_text:
	.ascii "layer1_ffn_up_tensor_found: "
layer1_ffn_up_tensor_found_text_end:

layer1_ffn_up_tensor_n_dimensions_text:
	.ascii "layer1_ffn_up_tensor_n_dimensions: "
layer1_ffn_up_tensor_n_dimensions_text_end:

layer1_ffn_up_tensor_dim0_text:
	.ascii "layer1_ffn_up_tensor_dim0: "
layer1_ffn_up_tensor_dim0_text_end:

layer1_ffn_up_tensor_dim1_text:
	.ascii "layer1_ffn_up_tensor_dim1: "
layer1_ffn_up_tensor_dim1_text_end:

layer1_ffn_up_tensor_ggml_type_text:
	.ascii "layer1_ffn_up_tensor_ggml_type: "
layer1_ffn_up_tensor_ggml_type_text_end:

layer1_ffn_up_tensor_offset_text:
	.ascii "layer1_ffn_up_tensor_offset: "
layer1_ffn_up_tensor_offset_text_end:

layer1_ffn_down_tensor_found_text:
	.ascii "layer1_ffn_down_tensor_found: "
layer1_ffn_down_tensor_found_text_end:

layer1_ffn_down_tensor_n_dimensions_text:
	.ascii "layer1_ffn_down_tensor_n_dimensions: "
layer1_ffn_down_tensor_n_dimensions_text_end:

layer1_ffn_down_tensor_dim0_text:
	.ascii "layer1_ffn_down_tensor_dim0: "
layer1_ffn_down_tensor_dim0_text_end:

layer1_ffn_down_tensor_dim1_text:
	.ascii "layer1_ffn_down_tensor_dim1: "
layer1_ffn_down_tensor_dim1_text_end:

layer1_ffn_down_tensor_ggml_type_text:
	.ascii "layer1_ffn_down_tensor_ggml_type: "
layer1_ffn_down_tensor_ggml_type_text_end:

layer1_ffn_down_tensor_offset_text:
	.ascii "layer1_ffn_down_tensor_offset: "
layer1_ffn_down_tensor_offset_text_end:

layer2_attn_norm_tensor_found_text:
	.ascii "layer2_attn_norm_tensor_found: "
layer2_attn_norm_tensor_found_text_end:

layer2_attn_norm_tensor_n_dimensions_text:
	.ascii "layer2_attn_norm_tensor_n_dimensions: "
layer2_attn_norm_tensor_n_dimensions_text_end:

layer2_attn_norm_tensor_dim0_text:
	.ascii "layer2_attn_norm_tensor_dim0: "
layer2_attn_norm_tensor_dim0_text_end:

layer2_attn_norm_tensor_ggml_type_text:
	.ascii "layer2_attn_norm_tensor_ggml_type: "
layer2_attn_norm_tensor_ggml_type_text_end:

layer2_attn_norm_tensor_offset_text:
	.ascii "layer2_attn_norm_tensor_offset: "
layer2_attn_norm_tensor_offset_text_end:
