.section .rodata

help_arg:
	.ascii "--help"
help_arg_end:

help_text:
	.ascii "mistral-asm\n"
	.ascii "\n"
	.ascii "Usage:\n"
	.ascii "  mistral-asm --help\n"
	.ascii "  mistral-asm <model.gguf>\n"
	.ascii "\n"
	.ascii "Current milestone: GGUF tensor summary with token embedding, "
	.ascii "RMSNorm, attention query/key/value smoke, context, "
	.ascii "output projection, residual smoke, FFN RMSNorm smoke, "
	.ascii "FFN gate/up matvec smoke, SwiGLU activation smoke, "
	.ascii "FFN down matvec smoke, post-FFN residual smoke, "
	.ascii "reusable descriptor lookup smoke, "
	.ascii "and layer-1 attention RMSNorm/query/key/value/context/output "
	.ascii "smoke plus layer-1 post-attention residual smoke and "
	.ascii "FFN RMSNorm status and FFN gate/up matvec status.\n"
help_text_end:

lookup_tensor_request:
	.ascii "token_embd.weight"
lookup_tensor_request_end:

layer1_attn_norm_tensor_request:
	.ascii "blk.1.attn_norm.weight"
layer1_attn_norm_tensor_request_end:

layer1_attn_q_tensor_request:
	.ascii "blk.1.attn_q.weight"
layer1_attn_q_tensor_request_end:

layer1_attn_k_tensor_request:
	.ascii "blk.1.attn_k.weight"
layer1_attn_k_tensor_request_end:

layer1_attn_v_tensor_request:
	.ascii "blk.1.attn_v.weight"
layer1_attn_v_tensor_request_end:

layer1_attn_output_tensor_request:
	.ascii "blk.1.attn_output.weight"
layer1_attn_output_tensor_request_end:

layer1_ffn_norm_tensor_request:
	.ascii "blk.1.ffn_norm.weight"
layer1_ffn_norm_tensor_request_end:

layer1_ffn_gate_tensor_request:
	.ascii "blk.1.ffn_gate.weight"
layer1_ffn_gate_tensor_request_end:

layer1_ffn_up_tensor_request:
	.ascii "blk.1.ffn_up.weight"
layer1_ffn_up_tensor_request_end:

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

attn_norm_tensor_found_text:
	.ascii "attn_norm_tensor_found: "
attn_norm_tensor_found_text_end:

attn_norm_tensor_name_text:
	.ascii "attn_norm_tensor_name: "
attn_norm_tensor_name_text_end:

attn_norm_tensor_n_dimensions_text:
	.ascii "attn_norm_tensor_n_dimensions: "
attn_norm_tensor_n_dimensions_text_end:

attn_norm_tensor_dim0_text:
	.ascii "attn_norm_tensor_dim0: "
attn_norm_tensor_dim0_text_end:

attn_norm_tensor_dim1_text:
	.ascii "attn_norm_tensor_dim1: "
attn_norm_tensor_dim1_text_end:

attn_norm_tensor_dim2_text:
	.ascii "attn_norm_tensor_dim2: "
attn_norm_tensor_dim2_text_end:

attn_norm_tensor_dim3_text:
	.ascii "attn_norm_tensor_dim3: "
attn_norm_tensor_dim3_text_end:

attn_norm_tensor_ggml_type_text:
	.ascii "attn_norm_tensor_ggml_type: "
attn_norm_tensor_ggml_type_text_end:

attn_norm_tensor_offset_text:
	.ascii "attn_norm_tensor_offset: "
attn_norm_tensor_offset_text_end:

attn_q_tensor_found_text:
	.ascii "attn_q_tensor_found: "
attn_q_tensor_found_text_end:

attn_q_tensor_name_text:
	.ascii "attn_q_tensor_name: "
attn_q_tensor_name_text_end:

attn_q_tensor_n_dimensions_text:
	.ascii "attn_q_tensor_n_dimensions: "
attn_q_tensor_n_dimensions_text_end:

attn_q_tensor_dim0_text:
	.ascii "attn_q_tensor_dim0: "
attn_q_tensor_dim0_text_end:

attn_q_tensor_dim1_text:
	.ascii "attn_q_tensor_dim1: "
attn_q_tensor_dim1_text_end:

attn_q_tensor_dim2_text:
	.ascii "attn_q_tensor_dim2: "
attn_q_tensor_dim2_text_end:

attn_q_tensor_dim3_text:
	.ascii "attn_q_tensor_dim3: "
attn_q_tensor_dim3_text_end:

attn_q_tensor_ggml_type_text:
	.ascii "attn_q_tensor_ggml_type: "
attn_q_tensor_ggml_type_text_end:

attn_q_tensor_offset_text:
	.ascii "attn_q_tensor_offset: "
attn_q_tensor_offset_text_end:

attn_k_tensor_found_text:
	.ascii "attn_k_tensor_found: "
attn_k_tensor_found_text_end:

attn_k_tensor_name_text:
	.ascii "attn_k_tensor_name: "
attn_k_tensor_name_text_end:

attn_k_tensor_n_dimensions_text:
	.ascii "attn_k_tensor_n_dimensions: "
attn_k_tensor_n_dimensions_text_end:

attn_k_tensor_dim0_text:
	.ascii "attn_k_tensor_dim0: "
attn_k_tensor_dim0_text_end:

attn_k_tensor_dim1_text:
	.ascii "attn_k_tensor_dim1: "
attn_k_tensor_dim1_text_end:

attn_k_tensor_dim2_text:
	.ascii "attn_k_tensor_dim2: "
attn_k_tensor_dim2_text_end:

attn_k_tensor_dim3_text:
	.ascii "attn_k_tensor_dim3: "
attn_k_tensor_dim3_text_end:

attn_k_tensor_ggml_type_text:
	.ascii "attn_k_tensor_ggml_type: "
attn_k_tensor_ggml_type_text_end:

attn_k_tensor_offset_text:
	.ascii "attn_k_tensor_offset: "
attn_k_tensor_offset_text_end:

attn_v_tensor_found_text:
	.ascii "attn_v_tensor_found: "
attn_v_tensor_found_text_end:

attn_v_tensor_name_text:
	.ascii "attn_v_tensor_name: "
attn_v_tensor_name_text_end:

attn_v_tensor_n_dimensions_text:
	.ascii "attn_v_tensor_n_dimensions: "
attn_v_tensor_n_dimensions_text_end:

attn_v_tensor_dim0_text:
	.ascii "attn_v_tensor_dim0: "
attn_v_tensor_dim0_text_end:

attn_v_tensor_dim1_text:
	.ascii "attn_v_tensor_dim1: "
attn_v_tensor_dim1_text_end:

attn_v_tensor_dim2_text:
	.ascii "attn_v_tensor_dim2: "
attn_v_tensor_dim2_text_end:

attn_v_tensor_dim3_text:
	.ascii "attn_v_tensor_dim3: "
attn_v_tensor_dim3_text_end:

attn_v_tensor_ggml_type_text:
	.ascii "attn_v_tensor_ggml_type: "
attn_v_tensor_ggml_type_text_end:

attn_v_tensor_offset_text:
	.ascii "attn_v_tensor_offset: "
attn_v_tensor_offset_text_end:

attn_output_tensor_found_text:
	.ascii "attn_output_tensor_found: "
attn_output_tensor_found_text_end:

attn_output_tensor_name_text:
	.ascii "attn_output_tensor_name: "
attn_output_tensor_name_text_end:

attn_output_tensor_n_dimensions_text:
	.ascii "attn_output_tensor_n_dimensions: "
attn_output_tensor_n_dimensions_text_end:

attn_output_tensor_dim0_text:
	.ascii "attn_output_tensor_dim0: "
attn_output_tensor_dim0_text_end:

attn_output_tensor_dim1_text:
	.ascii "attn_output_tensor_dim1: "
attn_output_tensor_dim1_text_end:

attn_output_tensor_dim2_text:
	.ascii "attn_output_tensor_dim2: "
attn_output_tensor_dim2_text_end:

attn_output_tensor_dim3_text:
	.ascii "attn_output_tensor_dim3: "
attn_output_tensor_dim3_text_end:

attn_output_tensor_ggml_type_text:
	.ascii "attn_output_tensor_ggml_type: "
attn_output_tensor_ggml_type_text_end:

attn_output_tensor_offset_text:
	.ascii "attn_output_tensor_offset: "
attn_output_tensor_offset_text_end:

ffn_norm_tensor_found_text:
	.ascii "ffn_norm_tensor_found: "
ffn_norm_tensor_found_text_end:

ffn_norm_tensor_name_text:
	.ascii "ffn_norm_tensor_name: "
ffn_norm_tensor_name_text_end:

ffn_norm_tensor_n_dimensions_text:
	.ascii "ffn_norm_tensor_n_dimensions: "
ffn_norm_tensor_n_dimensions_text_end:

ffn_norm_tensor_dim0_text:
	.ascii "ffn_norm_tensor_dim0: "
ffn_norm_tensor_dim0_text_end:

ffn_norm_tensor_dim1_text:
	.ascii "ffn_norm_tensor_dim1: "
ffn_norm_tensor_dim1_text_end:

ffn_norm_tensor_dim2_text:
	.ascii "ffn_norm_tensor_dim2: "
ffn_norm_tensor_dim2_text_end:

ffn_norm_tensor_dim3_text:
	.ascii "ffn_norm_tensor_dim3: "
ffn_norm_tensor_dim3_text_end:

ffn_norm_tensor_ggml_type_text:
	.ascii "ffn_norm_tensor_ggml_type: "
ffn_norm_tensor_ggml_type_text_end:

ffn_norm_tensor_offset_text:
	.ascii "ffn_norm_tensor_offset: "
ffn_norm_tensor_offset_text_end:

ffn_gate_tensor_found_text:
	.ascii "ffn_gate_tensor_found: "
ffn_gate_tensor_found_text_end:

ffn_gate_tensor_name_text:
	.ascii "ffn_gate_tensor_name: "
ffn_gate_tensor_name_text_end:

ffn_gate_tensor_n_dimensions_text:
	.ascii "ffn_gate_tensor_n_dimensions: "
ffn_gate_tensor_n_dimensions_text_end:

ffn_gate_tensor_dim0_text:
	.ascii "ffn_gate_tensor_dim0: "
ffn_gate_tensor_dim0_text_end:

ffn_gate_tensor_dim1_text:
	.ascii "ffn_gate_tensor_dim1: "
ffn_gate_tensor_dim1_text_end:

ffn_gate_tensor_dim2_text:
	.ascii "ffn_gate_tensor_dim2: "
ffn_gate_tensor_dim2_text_end:

ffn_gate_tensor_dim3_text:
	.ascii "ffn_gate_tensor_dim3: "
ffn_gate_tensor_dim3_text_end:

ffn_gate_tensor_ggml_type_text:
	.ascii "ffn_gate_tensor_ggml_type: "
ffn_gate_tensor_ggml_type_text_end:

ffn_gate_tensor_offset_text:
	.ascii "ffn_gate_tensor_offset: "
ffn_gate_tensor_offset_text_end:

ffn_up_tensor_found_text:
	.ascii "ffn_up_tensor_found: "
ffn_up_tensor_found_text_end:

ffn_up_tensor_name_text:
	.ascii "ffn_up_tensor_name: "
ffn_up_tensor_name_text_end:

ffn_up_tensor_n_dimensions_text:
	.ascii "ffn_up_tensor_n_dimensions: "
ffn_up_tensor_n_dimensions_text_end:

ffn_up_tensor_dim0_text:
	.ascii "ffn_up_tensor_dim0: "
ffn_up_tensor_dim0_text_end:

ffn_up_tensor_dim1_text:
	.ascii "ffn_up_tensor_dim1: "
ffn_up_tensor_dim1_text_end:

ffn_up_tensor_dim2_text:
	.ascii "ffn_up_tensor_dim2: "
ffn_up_tensor_dim2_text_end:

ffn_up_tensor_dim3_text:
	.ascii "ffn_up_tensor_dim3: "
ffn_up_tensor_dim3_text_end:

ffn_up_tensor_ggml_type_text:
	.ascii "ffn_up_tensor_ggml_type: "
ffn_up_tensor_ggml_type_text_end:

ffn_up_tensor_offset_text:
	.ascii "ffn_up_tensor_offset: "
ffn_up_tensor_offset_text_end:

ffn_down_tensor_found_text:
	.ascii "ffn_down_tensor_found: "
ffn_down_tensor_found_text_end:

ffn_down_tensor_name_text:
	.ascii "ffn_down_tensor_name: "
ffn_down_tensor_name_text_end:

ffn_down_tensor_n_dimensions_text:
	.ascii "ffn_down_tensor_n_dimensions: "
ffn_down_tensor_n_dimensions_text_end:

ffn_down_tensor_dim0_text:
	.ascii "ffn_down_tensor_dim0: "
ffn_down_tensor_dim0_text_end:

ffn_down_tensor_dim1_text:
	.ascii "ffn_down_tensor_dim1: "
ffn_down_tensor_dim1_text_end:

ffn_down_tensor_dim2_text:
	.ascii "ffn_down_tensor_dim2: "
ffn_down_tensor_dim2_text_end:

ffn_down_tensor_dim3_text:
	.ascii "ffn_down_tensor_dim3: "
ffn_down_tensor_dim3_text_end:

ffn_down_tensor_ggml_type_text:
	.ascii "ffn_down_tensor_ggml_type: "
ffn_down_tensor_ggml_type_text_end:

ffn_down_tensor_offset_text:
	.ascii "ffn_down_tensor_offset: "
ffn_down_tensor_offset_text_end:

token0_embedding_dequant_text:
	.ascii "token0_embedding_dequant: "
token0_embedding_dequant_text_end:

token0_attn_norm_text:
	.ascii "token0_attn_norm: "
token0_attn_norm_text_end:

token0_attn_q_matvec_text:
	.ascii "token0_attn_q_matvec: "
token0_attn_q_matvec_text_end:

token0_attn_k_matvec_text:
	.ascii "token0_attn_k_matvec: "
token0_attn_k_matvec_text_end:

token0_attn_v_matvec_text:
	.ascii "token0_attn_v_matvec: "
token0_attn_v_matvec_text_end:

token0_attn_context_text:
	.ascii "token0_attn_context: "
token0_attn_context_text_end:

token0_attn_output_matvec_text:
	.ascii "token0_attn_output_matvec: "
token0_attn_output_matvec_text_end:

token0_post_attn_residual_text:
	.ascii "token0_post_attn_residual: "
token0_post_attn_residual_text_end:

token0_ffn_norm_text:
	.ascii "token0_ffn_norm: "
token0_ffn_norm_text_end:

token0_ffn_gate_matvec_text:
	.ascii "token0_ffn_gate_matvec: "
token0_ffn_gate_matvec_text_end:

token0_ffn_up_matvec_text:
	.ascii "token0_ffn_up_matvec: "
token0_ffn_up_matvec_text_end:

token0_ffn_swiglu_text:
	.ascii "token0_ffn_swiglu: "
token0_ffn_swiglu_text_end:

token0_ffn_down_matvec_text:
	.ascii "token0_ffn_down_matvec: "
token0_ffn_down_matvec_text_end:

token0_post_ffn_residual_text:
	.ascii "token0_post_ffn_residual: "
token0_post_ffn_residual_text_end:

token0_layer1_attn_norm_text:
	.ascii "token0_layer1_attn_norm: "
token0_layer1_attn_norm_text_end:

token0_layer1_attn_q_matvec_text:
	.ascii "token0_layer1_attn_q_matvec: "
token0_layer1_attn_q_matvec_text_end:

token0_layer1_attn_k_matvec_text:
	.ascii "token0_layer1_attn_k_matvec: "
token0_layer1_attn_k_matvec_text_end:

token0_layer1_attn_v_matvec_text:
	.ascii "token0_layer1_attn_v_matvec: "
token0_layer1_attn_v_matvec_text_end:

token0_layer1_attn_context_text:
	.ascii "token0_layer1_attn_context: "
token0_layer1_attn_context_text_end:

token0_layer1_attn_output_matvec_text:
	.ascii "token0_layer1_attn_output_matvec: "
token0_layer1_attn_output_matvec_text_end:

token0_layer1_post_attn_residual_text:
	.ascii "token0_layer1_post_attn_residual: "
token0_layer1_post_attn_residual_text_end:

token0_attn_q_output0_f32_text:
	.ascii "token0_attn_q_output0_f32_hex: "
token0_attn_q_output0_f32_text_end:

token0_attn_q_output1_f32_text:
	.ascii "token0_attn_q_output1_f32_hex: "
token0_attn_q_output1_f32_text_end:

token0_attn_q_output2_f32_text:
	.ascii "token0_attn_q_output2_f32_hex: "
token0_attn_q_output2_f32_text_end:

token0_attn_q_output3_f32_text:
	.ascii "token0_attn_q_output3_f32_hex: "
token0_attn_q_output3_f32_text_end:

token0_attn_k_output0_f32_text:
	.ascii "token0_attn_k_output0_f32_hex: "
token0_attn_k_output0_f32_text_end:

token0_attn_k_output1_f32_text:
	.ascii "token0_attn_k_output1_f32_hex: "
token0_attn_k_output1_f32_text_end:

token0_attn_k_output2_f32_text:
	.ascii "token0_attn_k_output2_f32_hex: "
token0_attn_k_output2_f32_text_end:

token0_attn_k_output3_f32_text:
	.ascii "token0_attn_k_output3_f32_hex: "
token0_attn_k_output3_f32_text_end:

token0_attn_v_output0_f32_text:
	.ascii "token0_attn_v_output0_f32_hex: "
token0_attn_v_output0_f32_text_end:

token0_attn_v_output1_f32_text:
	.ascii "token0_attn_v_output1_f32_hex: "
token0_attn_v_output1_f32_text_end:

token0_attn_v_output2_f32_text:
	.ascii "token0_attn_v_output2_f32_hex: "
token0_attn_v_output2_f32_text_end:

token0_attn_v_output3_f32_text:
	.ascii "token0_attn_v_output3_f32_hex: "
token0_attn_v_output3_f32_text_end:

token0_attn_context0_f32_text:
	.ascii "token0_attn_context0_f32_hex: "
token0_attn_context0_f32_text_end:

token0_attn_context1_f32_text:
	.ascii "token0_attn_context1_f32_hex: "
token0_attn_context1_f32_text_end:

token0_attn_context2_f32_text:
	.ascii "token0_attn_context2_f32_hex: "
token0_attn_context2_f32_text_end:

token0_attn_context3_f32_text:
	.ascii "token0_attn_context3_f32_hex: "
token0_attn_context3_f32_text_end:

token0_attn_output0_f32_text:
	.ascii "token0_attn_output0_f32_hex: "
token0_attn_output0_f32_text_end:

token0_attn_output1_f32_text:
	.ascii "token0_attn_output1_f32_hex: "
token0_attn_output1_f32_text_end:

token0_attn_output2_f32_text:
	.ascii "token0_attn_output2_f32_hex: "
token0_attn_output2_f32_text_end:

token0_attn_output3_f32_text:
	.ascii "token0_attn_output3_f32_hex: "
token0_attn_output3_f32_text_end:

token0_post_attn_residual0_f32_text:
	.ascii "token0_post_attn_residual0_f32_hex: "
token0_post_attn_residual0_f32_text_end:

token0_post_attn_residual1_f32_text:
	.ascii "token0_post_attn_residual1_f32_hex: "
token0_post_attn_residual1_f32_text_end:

token0_post_attn_residual2_f32_text:
	.ascii "token0_post_attn_residual2_f32_hex: "
token0_post_attn_residual2_f32_text_end:

token0_post_attn_residual3_f32_text:
	.ascii "token0_post_attn_residual3_f32_hex: "
token0_post_attn_residual3_f32_text_end:

token0_ffn_norm0_f32_text:
	.ascii "token0_ffn_norm0_f32_hex: "
token0_ffn_norm0_f32_text_end:

token0_ffn_norm1_f32_text:
	.ascii "token0_ffn_norm1_f32_hex: "
token0_ffn_norm1_f32_text_end:

token0_ffn_norm2_f32_text:
	.ascii "token0_ffn_norm2_f32_hex: "
token0_ffn_norm2_f32_text_end:

token0_ffn_norm3_f32_text:
	.ascii "token0_ffn_norm3_f32_hex: "
token0_ffn_norm3_f32_text_end:

token0_ffn_gate_output0_f32_text:
	.ascii "token0_ffn_gate_output0_f32_hex: "
token0_ffn_gate_output0_f32_text_end:

token0_ffn_gate_output1_f32_text:
	.ascii "token0_ffn_gate_output1_f32_hex: "
token0_ffn_gate_output1_f32_text_end:

token0_ffn_gate_output2_f32_text:
	.ascii "token0_ffn_gate_output2_f32_hex: "
token0_ffn_gate_output2_f32_text_end:

token0_ffn_gate_output3_f32_text:
	.ascii "token0_ffn_gate_output3_f32_hex: "
token0_ffn_gate_output3_f32_text_end:

token0_ffn_up_output0_f32_text:
	.ascii "token0_ffn_up_output0_f32_hex: "
token0_ffn_up_output0_f32_text_end:

token0_ffn_up_output1_f32_text:
	.ascii "token0_ffn_up_output1_f32_hex: "
token0_ffn_up_output1_f32_text_end:

token0_ffn_up_output2_f32_text:
	.ascii "token0_ffn_up_output2_f32_hex: "
token0_ffn_up_output2_f32_text_end:

token0_ffn_up_output3_f32_text:
	.ascii "token0_ffn_up_output3_f32_hex: "
token0_ffn_up_output3_f32_text_end:

token0_ffn_swiglu_output0_f32_text:
	.ascii "token0_ffn_swiglu_output0_f32_hex: "
token0_ffn_swiglu_output0_f32_text_end:

token0_ffn_swiglu_output1_f32_text:
	.ascii "token0_ffn_swiglu_output1_f32_hex: "
token0_ffn_swiglu_output1_f32_text_end:

token0_ffn_swiglu_output2_f32_text:
	.ascii "token0_ffn_swiglu_output2_f32_hex: "
token0_ffn_swiglu_output2_f32_text_end:

token0_ffn_swiglu_output3_f32_text:
	.ascii "token0_ffn_swiglu_output3_f32_hex: "
token0_ffn_swiglu_output3_f32_text_end:

token0_ffn_down_output0_f32_text:
	.ascii "token0_ffn_down_output0_f32_hex: "
token0_ffn_down_output0_f32_text_end:

token0_ffn_down_output1_f32_text:
	.ascii "token0_ffn_down_output1_f32_hex: "
token0_ffn_down_output1_f32_text_end:

token0_ffn_down_output2_f32_text:
	.ascii "token0_ffn_down_output2_f32_hex: "
token0_ffn_down_output2_f32_text_end:

token0_ffn_down_output3_f32_text:
	.ascii "token0_ffn_down_output3_f32_hex: "
token0_ffn_down_output3_f32_text_end:

token0_post_ffn_residual0_f32_text:
	.ascii "token0_post_ffn_residual0_f32_hex: "
token0_post_ffn_residual0_f32_text_end:

token0_post_ffn_residual1_f32_text:
	.ascii "token0_post_ffn_residual1_f32_hex: "
token0_post_ffn_residual1_f32_text_end:

token0_post_ffn_residual2_f32_text:
	.ascii "token0_post_ffn_residual2_f32_hex: "
token0_post_ffn_residual2_f32_text_end:

token0_post_ffn_residual3_f32_text:
	.ascii "token0_post_ffn_residual3_f32_hex: "
token0_post_ffn_residual3_f32_text_end:

token0_layer1_attn_norm0_f32_text:
	.ascii "token0_layer1_attn_norm0_f32_hex: "
token0_layer1_attn_norm0_f32_text_end:

token0_layer1_attn_norm1_f32_text:
	.ascii "token0_layer1_attn_norm1_f32_hex: "
token0_layer1_attn_norm1_f32_text_end:

token0_layer1_attn_norm2_f32_text:
	.ascii "token0_layer1_attn_norm2_f32_hex: "
token0_layer1_attn_norm2_f32_text_end:

token0_layer1_attn_norm3_f32_text:
	.ascii "token0_layer1_attn_norm3_f32_hex: "
token0_layer1_attn_norm3_f32_text_end:

token0_layer1_attn_q_output0_f32_text:
	.ascii "token0_layer1_attn_q_output0_f32_hex: "
token0_layer1_attn_q_output0_f32_text_end:

token0_layer1_attn_q_output1_f32_text:
	.ascii "token0_layer1_attn_q_output1_f32_hex: "
token0_layer1_attn_q_output1_f32_text_end:

token0_layer1_attn_q_output2_f32_text:
	.ascii "token0_layer1_attn_q_output2_f32_hex: "
token0_layer1_attn_q_output2_f32_text_end:

token0_layer1_attn_q_output3_f32_text:
	.ascii "token0_layer1_attn_q_output3_f32_hex: "
token0_layer1_attn_q_output3_f32_text_end:

token0_layer1_attn_k_output0_f32_text:
	.ascii "token0_layer1_attn_k_output0_f32_hex: "
token0_layer1_attn_k_output0_f32_text_end:

token0_layer1_attn_k_output1_f32_text:
	.ascii "token0_layer1_attn_k_output1_f32_hex: "
token0_layer1_attn_k_output1_f32_text_end:

token0_layer1_attn_k_output2_f32_text:
	.ascii "token0_layer1_attn_k_output2_f32_hex: "
token0_layer1_attn_k_output2_f32_text_end:

token0_layer1_attn_k_output3_f32_text:
	.ascii "token0_layer1_attn_k_output3_f32_hex: "
token0_layer1_attn_k_output3_f32_text_end:

token0_layer1_attn_v_output0_f32_text:
	.ascii "token0_layer1_attn_v_output0_f32_hex: "
token0_layer1_attn_v_output0_f32_text_end:

token0_layer1_attn_v_output1_f32_text:
	.ascii "token0_layer1_attn_v_output1_f32_hex: "
token0_layer1_attn_v_output1_f32_text_end:

token0_layer1_attn_v_output2_f32_text:
	.ascii "token0_layer1_attn_v_output2_f32_hex: "
token0_layer1_attn_v_output2_f32_text_end:

token0_layer1_attn_v_output3_f32_text:
	.ascii "token0_layer1_attn_v_output3_f32_hex: "
token0_layer1_attn_v_output3_f32_text_end:

token0_layer1_attn_context0_f32_text:
	.ascii "token0_layer1_attn_context0_f32_hex: "
token0_layer1_attn_context0_f32_text_end:

token0_layer1_attn_context1_f32_text:
	.ascii "token0_layer1_attn_context1_f32_hex: "
token0_layer1_attn_context1_f32_text_end:

token0_layer1_attn_context2_f32_text:
	.ascii "token0_layer1_attn_context2_f32_hex: "
token0_layer1_attn_context2_f32_text_end:

token0_layer1_attn_context3_f32_text:
	.ascii "token0_layer1_attn_context3_f32_hex: "
token0_layer1_attn_context3_f32_text_end:

token0_layer1_attn_output0_f32_text:
	.ascii "token0_layer1_attn_output0_f32_hex: "
token0_layer1_attn_output0_f32_text_end:

token0_layer1_attn_output1_f32_text:
	.ascii "token0_layer1_attn_output1_f32_hex: "
token0_layer1_attn_output1_f32_text_end:

token0_layer1_attn_output2_f32_text:
	.ascii "token0_layer1_attn_output2_f32_hex: "
token0_layer1_attn_output2_f32_text_end:

token0_layer1_attn_output3_f32_text:
	.ascii "token0_layer1_attn_output3_f32_hex: "
token0_layer1_attn_output3_f32_text_end:

token0_layer1_post_attn_residual0_f32_text:
	.ascii "token0_layer1_post_attn_residual0_f32_hex: "
token0_layer1_post_attn_residual0_f32_text_end:

token0_layer1_post_attn_residual1_f32_text:
	.ascii "token0_layer1_post_attn_residual1_f32_hex: "
token0_layer1_post_attn_residual1_f32_text_end:

token0_layer1_post_attn_residual2_f32_text:
	.ascii "token0_layer1_post_attn_residual2_f32_hex: "
token0_layer1_post_attn_residual2_f32_text_end:

token0_layer1_post_attn_residual3_f32_text:
	.ascii "token0_layer1_post_attn_residual3_f32_hex: "
token0_layer1_post_attn_residual3_f32_text_end:

newline_text:
	.ascii "\n"
newline_text_end:

gguf_open_error_text:
	.ascii "mistral-asm: could not open model\n"
gguf_open_error_text_end:

gguf_fstat_error_text:
	.ascii "mistral-asm: could not stat model\n"
gguf_fstat_error_text_end:

gguf_too_small_error_text:
	.ascii "mistral-asm: file is too small for GGUF header\n"
gguf_too_small_error_text_end:

gguf_mmap_error_text:
	.ascii "mistral-asm: could not map model\n"
gguf_mmap_error_text_end:

gguf_magic_error_text:
	.ascii "mistral-asm: bad GGUF magic\n"
gguf_magic_error_text_end:

gguf_version_error_text:
	.ascii "mistral-asm: unsupported GGUF version\n"
gguf_version_error_text_end:

gguf_munmap_error_text:
	.ascii "mistral-asm: could not unmap model\n"
gguf_munmap_error_text_end:

gguf_count_error_text:
	.ascii "mistral-asm: unsupported GGUF count field\n"
gguf_count_error_text_end:

gguf_metadata_bounds_error_text:
	.ascii "mistral-asm: malformed GGUF metadata\n"
gguf_metadata_bounds_error_text_end:

gguf_metadata_type_error_text:
	.ascii "mistral-asm: unsupported GGUF metadata type\n"
gguf_metadata_type_error_text_end:

gguf_tensor_bounds_error_text:
	.ascii "mistral-asm: malformed GGUF tensor directory\n"
gguf_tensor_bounds_error_text_end:

gguf_tensor_alignment_error_text:
	.ascii "mistral-asm: misaligned GGUF tensor data\n"
gguf_tensor_alignment_error_text_end:

gguf_unknown_error_text:
	.ascii "mistral-asm: GGUF validation failed\n"
gguf_unknown_error_text_end:

