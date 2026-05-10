.intel_syntax noprefix

.equ GGUF_SUMMARY_ARCHITECTURE_CAP, 32
.equ GGUF_SUMMARY_FIRST_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_LOOKUP_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_ATTN_NORM_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_ATTN_Q_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_ATTN_K_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_ATTN_V_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_FFN_NORM_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_FFN_GATE_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_FFN_UP_TENSOR_NAME_CAP, 96
.equ GGUF_SUMMARY_FFN_DOWN_TENSOR_NAME_CAP, 96
.equ LAYER1_ATTN_NORM_TENSOR_NAME_CAP, 96
.equ LAYER1_ATTN_Q_TENSOR_NAME_CAP, 96
.equ LAYER1_ATTN_K_TENSOR_NAME_CAP, 96
.equ LAYER1_ATTN_V_TENSOR_NAME_CAP, 96
.equ LAYER1_ATTN_OUTPUT_TENSOR_NAME_CAP, 96
.equ LAYER1_FFN_NORM_TENSOR_NAME_CAP, 96
.equ LAYER1_FFN_GATE_TENSOR_NAME_CAP, 96
.equ LAYER1_FFN_UP_TENSOR_NAME_CAP, 96
.equ GGML_TYPE_F32, 0
.equ GGML_TYPE_Q8_0, 8
.equ TOKEN_EMBEDDING_ACTIVATION_VALUES, 3072
.equ TOKEN_EMBEDDING_ACTIVATION_BYTES, TOKEN_EMBEDDING_ACTIVATION_VALUES * 4
.equ TOKEN0_ATTN_Q_OUTPUT_VALUES, 4096
.equ TOKEN0_ATTN_Q_OUTPUT_BYTES, TOKEN0_ATTN_Q_OUTPUT_VALUES * 4
.equ TOKEN0_ATTN_K_OUTPUT_VALUES, 1024
.equ TOKEN0_ATTN_K_OUTPUT_BYTES, TOKEN0_ATTN_K_OUTPUT_VALUES * 4
.equ TOKEN0_ATTN_V_OUTPUT_VALUES, 1024
.equ TOKEN0_ATTN_V_OUTPUT_BYTES, TOKEN0_ATTN_V_OUTPUT_VALUES * 4
.equ TOKEN0_ATTN_HEAD_DIM_VALUES, 128
.equ TOKEN0_ATTN_QUERY_HEADS_PER_KV_HEAD, 4
.equ TOKEN0_ATTN_KV_HEADS, TOKEN0_ATTN_V_OUTPUT_VALUES / TOKEN0_ATTN_HEAD_DIM_VALUES
.equ TOKEN0_ATTN_CONTEXT_VALUES, TOKEN0_ATTN_Q_OUTPUT_VALUES
.equ TOKEN0_ATTN_CONTEXT_BYTES, TOKEN0_ATTN_CONTEXT_VALUES * 4
.equ TOKEN0_ATTN_OUTPUT_VALUES, TOKEN_EMBEDDING_ACTIVATION_VALUES
.equ TOKEN0_ATTN_OUTPUT_BYTES, TOKEN0_ATTN_OUTPUT_VALUES * 4
.equ TOKEN0_POST_ATTN_RESIDUAL_VALUES, TOKEN_EMBEDDING_ACTIVATION_VALUES
.equ TOKEN0_POST_ATTN_RESIDUAL_BYTES, TOKEN0_POST_ATTN_RESIDUAL_VALUES * 4
.equ TOKEN0_FFN_NORM_VALUES, TOKEN_EMBEDDING_ACTIVATION_VALUES
.equ TOKEN0_FFN_NORM_BYTES, TOKEN0_FFN_NORM_VALUES * 4
.equ TOKEN0_FFN_GATE_OUTPUT_VALUES, 9216
.equ TOKEN0_FFN_GATE_OUTPUT_BYTES, TOKEN0_FFN_GATE_OUTPUT_VALUES * 4
.equ TOKEN0_FFN_UP_OUTPUT_VALUES, 9216
.equ TOKEN0_FFN_UP_OUTPUT_BYTES, TOKEN0_FFN_UP_OUTPUT_VALUES * 4
.equ TOKEN0_FFN_SWIGLU_VALUES, 9216
.equ TOKEN0_FFN_SWIGLU_BYTES, TOKEN0_FFN_SWIGLU_VALUES * 4
.equ TOKEN0_FFN_DOWN_OUTPUT_VALUES, TOKEN_EMBEDDING_ACTIVATION_VALUES
.equ TOKEN0_FFN_DOWN_OUTPUT_BYTES, TOKEN0_FFN_DOWN_OUTPUT_VALUES * 4
.equ TOKEN0_POST_FFN_RESIDUAL_VALUES, TOKEN_EMBEDDING_ACTIVATION_VALUES
.equ TOKEN0_POST_FFN_RESIDUAL_BYTES, TOKEN0_POST_FFN_RESIDUAL_VALUES * 4
.equ TOKEN0_LAYER1_ATTN_NORM_VALUES, TOKEN_EMBEDDING_ACTIVATION_VALUES
.equ TOKEN0_LAYER1_ATTN_NORM_BYTES, TOKEN0_LAYER1_ATTN_NORM_VALUES * 4
.equ TOKEN0_LAYER1_ATTN_Q_OUTPUT_VALUES, TOKEN0_ATTN_Q_OUTPUT_VALUES
.equ TOKEN0_LAYER1_ATTN_Q_OUTPUT_BYTES, TOKEN0_LAYER1_ATTN_Q_OUTPUT_VALUES * 4
.equ TOKEN0_LAYER1_ATTN_K_OUTPUT_VALUES, TOKEN0_ATTN_K_OUTPUT_VALUES
.equ TOKEN0_LAYER1_ATTN_K_OUTPUT_BYTES, TOKEN0_LAYER1_ATTN_K_OUTPUT_VALUES * 4
.equ TOKEN0_LAYER1_ATTN_V_OUTPUT_VALUES, TOKEN0_ATTN_V_OUTPUT_VALUES
.equ TOKEN0_LAYER1_ATTN_V_OUTPUT_BYTES, TOKEN0_LAYER1_ATTN_V_OUTPUT_VALUES * 4
.equ TOKEN0_LAYER1_ATTN_CONTEXT_VALUES, TOKEN0_LAYER1_ATTN_Q_OUTPUT_VALUES
.equ TOKEN0_LAYER1_ATTN_CONTEXT_BYTES, TOKEN0_LAYER1_ATTN_CONTEXT_VALUES * 4
.equ TOKEN0_LAYER1_ATTN_OUTPUT_VALUES, TOKEN0_LAYER1_ATTN_NORM_VALUES
.equ TOKEN0_LAYER1_ATTN_OUTPUT_BYTES, TOKEN0_LAYER1_ATTN_OUTPUT_VALUES * 4
.equ TOKEN0_LAYER1_POST_ATTN_RESIDUAL_VALUES, TOKEN0_LAYER1_ATTN_OUTPUT_VALUES
.equ TOKEN0_LAYER1_POST_ATTN_RESIDUAL_BYTES, TOKEN0_LAYER1_POST_ATTN_RESIDUAL_VALUES * 4
.equ TOKEN0_LAYER1_FFN_NORM_VALUES, TOKEN0_LAYER1_POST_ATTN_RESIDUAL_VALUES
.equ TOKEN0_LAYER1_FFN_NORM_BYTES, TOKEN0_LAYER1_FFN_NORM_VALUES * 4
.equ Q8_0_BLOCK_SIZE, 32
.equ Q8_0_BLOCK_BYTES, 34

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
	.ascii "FFN RMSNorm status, FFN gate matvec status, "
	.ascii "and FFN up descriptor smoke.\n"
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

# Focused inference modules consume these process-owned handoff slots while
# _start still owns parser orchestration, mapping lifetime, and summary output.
.global gguf_summary_tensor_data_offset
.global gguf_summary_attn_norm_rms_epsilon_found
.global gguf_summary_attn_norm_rms_epsilon_f32
.global gguf_mapping_base
.global gguf_mapping_size
.global layer1_ffn_norm_tensor_found
.global layer1_ffn_norm_tensor_n_dimensions
.global layer1_ffn_norm_tensor_dim0
.global layer1_ffn_norm_tensor_ggml_type
.global layer1_ffn_norm_tensor_offset
.global layer1_ffn_gate_tensor_found
.global layer1_ffn_gate_tensor_n_dimensions
.global layer1_ffn_gate_tensor_dim0
.global layer1_ffn_gate_tensor_dim1
.global layer1_ffn_gate_tensor_ggml_type
.global layer1_ffn_gate_tensor_offset
.global token0_layer1_post_attn_residual_status
.global token0_layer1_post_attn_residual
.global token0_layer1_ffn_norm_status
.global token0_layer1_ffn_norm_activation

.section .bss

.balign 8
gguf_summary:
gguf_summary_tensor_count:
	.skip 8
gguf_summary_metadata_count:
	.skip 8
gguf_summary_architecture:
	.skip GGUF_SUMMARY_ARCHITECTURE_CAP
gguf_summary_context_length:
	.skip 8
gguf_summary_block_count:
	.skip 8
gguf_summary_vocab_size:
	.skip 8
gguf_summary_first_tensor_name:
	.skip GGUF_SUMMARY_FIRST_TENSOR_NAME_CAP
gguf_summary_first_tensor_n_dimensions:
	.skip 8
gguf_summary_first_tensor_dim0:
	.skip 8
gguf_summary_first_tensor_dim1:
	.skip 8
gguf_summary_first_tensor_dim2:
	.skip 8
gguf_summary_first_tensor_dim3:
	.skip 8
gguf_summary_first_tensor_ggml_type:
	.skip 8
gguf_summary_first_tensor_offset:
	.skip 8
gguf_summary_lookup_tensor_found:
	.skip 8
gguf_summary_lookup_tensor_name:
	.skip GGUF_SUMMARY_LOOKUP_TENSOR_NAME_CAP
gguf_summary_lookup_tensor_n_dimensions:
	.skip 8
gguf_summary_lookup_tensor_dim0:
	.skip 8
gguf_summary_lookup_tensor_dim1:
	.skip 8
gguf_summary_lookup_tensor_dim2:
	.skip 8
gguf_summary_lookup_tensor_dim3:
	.skip 8
gguf_summary_lookup_tensor_ggml_type:
	.skip 8
gguf_summary_lookup_tensor_offset:
	.skip 8
gguf_summary_tensor_data_offset:
	.skip 8
gguf_summary_attn_norm_tensor_found:
	.skip 8
gguf_summary_attn_norm_tensor_name:
	.skip GGUF_SUMMARY_ATTN_NORM_TENSOR_NAME_CAP
gguf_summary_attn_norm_tensor_n_dimensions:
	.skip 8
gguf_summary_attn_norm_tensor_dim0:
	.skip 8
gguf_summary_attn_norm_tensor_dim1:
	.skip 8
gguf_summary_attn_norm_tensor_dim2:
	.skip 8
gguf_summary_attn_norm_tensor_dim3:
	.skip 8
gguf_summary_attn_norm_tensor_ggml_type:
	.skip 8
gguf_summary_attn_norm_tensor_offset:
	.skip 8
gguf_summary_attn_q_tensor_found:
	.skip 8
gguf_summary_attn_q_tensor_name:
	.skip GGUF_SUMMARY_ATTN_Q_TENSOR_NAME_CAP
gguf_summary_attn_q_tensor_n_dimensions:
	.skip 8
gguf_summary_attn_q_tensor_dim0:
	.skip 8
gguf_summary_attn_q_tensor_dim1:
	.skip 8
gguf_summary_attn_q_tensor_dim2:
	.skip 8
gguf_summary_attn_q_tensor_dim3:
	.skip 8
gguf_summary_attn_q_tensor_ggml_type:
	.skip 8
gguf_summary_attn_q_tensor_offset:
	.skip 8
gguf_summary_attn_k_tensor_found:
	.skip 8
gguf_summary_attn_k_tensor_name:
	.skip GGUF_SUMMARY_ATTN_K_TENSOR_NAME_CAP
gguf_summary_attn_k_tensor_n_dimensions:
	.skip 8
gguf_summary_attn_k_tensor_dim0:
	.skip 8
gguf_summary_attn_k_tensor_dim1:
	.skip 8
gguf_summary_attn_k_tensor_dim2:
	.skip 8
gguf_summary_attn_k_tensor_dim3:
	.skip 8
gguf_summary_attn_k_tensor_ggml_type:
	.skip 8
gguf_summary_attn_k_tensor_offset:
	.skip 8
gguf_summary_attn_v_tensor_found:
	.skip 8
gguf_summary_attn_v_tensor_name:
	.skip GGUF_SUMMARY_ATTN_V_TENSOR_NAME_CAP
gguf_summary_attn_v_tensor_n_dimensions:
	.skip 8
gguf_summary_attn_v_tensor_dim0:
	.skip 8
gguf_summary_attn_v_tensor_dim1:
	.skip 8
gguf_summary_attn_v_tensor_dim2:
	.skip 8
gguf_summary_attn_v_tensor_dim3:
	.skip 8
gguf_summary_attn_v_tensor_ggml_type:
	.skip 8
gguf_summary_attn_v_tensor_offset:
	.skip 8
gguf_summary_attn_output_tensor_found:
	.skip 8
gguf_summary_attn_output_tensor_name:
	.skip GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_NAME_CAP
gguf_summary_attn_output_tensor_n_dimensions:
	.skip 8
gguf_summary_attn_output_tensor_dim0:
	.skip 8
gguf_summary_attn_output_tensor_dim1:
	.skip 8
gguf_summary_attn_output_tensor_dim2:
	.skip 8
gguf_summary_attn_output_tensor_dim3:
	.skip 8
gguf_summary_attn_output_tensor_ggml_type:
	.skip 8
gguf_summary_attn_output_tensor_offset:
	.skip 8
gguf_summary_ffn_norm_tensor_found:
	.skip 8
gguf_summary_ffn_norm_tensor_name:
	.skip GGUF_SUMMARY_FFN_NORM_TENSOR_NAME_CAP
gguf_summary_ffn_norm_tensor_n_dimensions:
	.skip 8
gguf_summary_ffn_norm_tensor_dim0:
	.skip 8
gguf_summary_ffn_norm_tensor_dim1:
	.skip 8
gguf_summary_ffn_norm_tensor_dim2:
	.skip 8
gguf_summary_ffn_norm_tensor_dim3:
	.skip 8
gguf_summary_ffn_norm_tensor_ggml_type:
	.skip 8
gguf_summary_ffn_norm_tensor_offset:
	.skip 8
gguf_summary_ffn_gate_tensor_found:
	.skip 8
gguf_summary_ffn_gate_tensor_name:
	.skip GGUF_SUMMARY_FFN_GATE_TENSOR_NAME_CAP
gguf_summary_ffn_gate_tensor_n_dimensions:
	.skip 8
gguf_summary_ffn_gate_tensor_dim0:
	.skip 8
gguf_summary_ffn_gate_tensor_dim1:
	.skip 8
gguf_summary_ffn_gate_tensor_dim2:
	.skip 8
gguf_summary_ffn_gate_tensor_dim3:
	.skip 8
gguf_summary_ffn_gate_tensor_ggml_type:
	.skip 8
gguf_summary_ffn_gate_tensor_offset:
	.skip 8
gguf_summary_ffn_up_tensor_found:
	.skip 8
gguf_summary_ffn_up_tensor_name:
	.skip GGUF_SUMMARY_FFN_UP_TENSOR_NAME_CAP
gguf_summary_ffn_up_tensor_n_dimensions:
	.skip 8
gguf_summary_ffn_up_tensor_dim0:
	.skip 8
gguf_summary_ffn_up_tensor_dim1:
	.skip 8
gguf_summary_ffn_up_tensor_dim2:
	.skip 8
gguf_summary_ffn_up_tensor_dim3:
	.skip 8
gguf_summary_ffn_up_tensor_ggml_type:
	.skip 8
gguf_summary_ffn_up_tensor_offset:
	.skip 8
gguf_summary_ffn_down_tensor_found:
	.skip 8
gguf_summary_ffn_down_tensor_name:
	.skip GGUF_SUMMARY_FFN_DOWN_TENSOR_NAME_CAP
gguf_summary_ffn_down_tensor_n_dimensions:
	.skip 8
gguf_summary_ffn_down_tensor_dim0:
	.skip 8
gguf_summary_ffn_down_tensor_dim1:
	.skip 8
gguf_summary_ffn_down_tensor_dim2:
	.skip 8
gguf_summary_ffn_down_tensor_dim3:
	.skip 8
gguf_summary_ffn_down_tensor_ggml_type:
	.skip 8
gguf_summary_ffn_down_tensor_offset:
	.skip 8
gguf_summary_attn_norm_rms_epsilon_found:
	.skip 8
gguf_summary_attn_norm_rms_epsilon_f32:
	.skip 4
.balign 8
gguf_summary_tensor_infos_offset:
	.skip 8

.balign 8
gguf_mapping:
gguf_mapping_base:
	.skip 8
gguf_mapping_size:
	.skip 8

.balign 8
layer1_attn_norm_tensor_slot:
layer1_attn_norm_tensor_found:
	.skip 8
layer1_attn_norm_tensor_name:
	.skip LAYER1_ATTN_NORM_TENSOR_NAME_CAP
layer1_attn_norm_tensor_n_dimensions:
	.skip 8
layer1_attn_norm_tensor_dim0:
	.skip 8
layer1_attn_norm_tensor_dim1:
	.skip 8
layer1_attn_norm_tensor_dim2:
	.skip 8
layer1_attn_norm_tensor_dim3:
	.skip 8
layer1_attn_norm_tensor_ggml_type:
	.skip 8
layer1_attn_norm_tensor_offset:
	.skip 8

.balign 8
layer1_attn_q_tensor_slot:
layer1_attn_q_tensor_found:
	.skip 8
layer1_attn_q_tensor_name:
	.skip LAYER1_ATTN_Q_TENSOR_NAME_CAP
layer1_attn_q_tensor_n_dimensions:
	.skip 8
layer1_attn_q_tensor_dim0:
	.skip 8
layer1_attn_q_tensor_dim1:
	.skip 8
layer1_attn_q_tensor_dim2:
	.skip 8
layer1_attn_q_tensor_dim3:
	.skip 8
layer1_attn_q_tensor_ggml_type:
	.skip 8
layer1_attn_q_tensor_offset:
	.skip 8

.balign 8
layer1_attn_k_tensor_slot:
layer1_attn_k_tensor_found:
	.skip 8
layer1_attn_k_tensor_name:
	.skip LAYER1_ATTN_K_TENSOR_NAME_CAP
layer1_attn_k_tensor_n_dimensions:
	.skip 8
layer1_attn_k_tensor_dim0:
	.skip 8
layer1_attn_k_tensor_dim1:
	.skip 8
layer1_attn_k_tensor_dim2:
	.skip 8
layer1_attn_k_tensor_dim3:
	.skip 8
layer1_attn_k_tensor_ggml_type:
	.skip 8
layer1_attn_k_tensor_offset:
	.skip 8

.balign 8
layer1_attn_v_tensor_slot:
layer1_attn_v_tensor_found:
	.skip 8
layer1_attn_v_tensor_name:
	.skip LAYER1_ATTN_V_TENSOR_NAME_CAP
layer1_attn_v_tensor_n_dimensions:
	.skip 8
layer1_attn_v_tensor_dim0:
	.skip 8
layer1_attn_v_tensor_dim1:
	.skip 8
layer1_attn_v_tensor_dim2:
	.skip 8
layer1_attn_v_tensor_dim3:
	.skip 8
layer1_attn_v_tensor_ggml_type:
	.skip 8
layer1_attn_v_tensor_offset:
	.skip 8

.balign 8
layer1_attn_output_tensor_slot:
layer1_attn_output_tensor_found:
	.skip 8
layer1_attn_output_tensor_name:
	.skip LAYER1_ATTN_OUTPUT_TENSOR_NAME_CAP
layer1_attn_output_tensor_n_dimensions:
	.skip 8
layer1_attn_output_tensor_dim0:
	.skip 8
layer1_attn_output_tensor_dim1:
	.skip 8
layer1_attn_output_tensor_dim2:
	.skip 8
layer1_attn_output_tensor_dim3:
	.skip 8
layer1_attn_output_tensor_ggml_type:
	.skip 8
layer1_attn_output_tensor_offset:
	.skip 8

.balign 8
layer1_ffn_norm_tensor_slot:
layer1_ffn_norm_tensor_found:
	.skip 8
layer1_ffn_norm_tensor_name:
	.skip LAYER1_FFN_NORM_TENSOR_NAME_CAP
layer1_ffn_norm_tensor_n_dimensions:
	.skip 8
layer1_ffn_norm_tensor_dim0:
	.skip 8
layer1_ffn_norm_tensor_dim1:
	.skip 8
layer1_ffn_norm_tensor_dim2:
	.skip 8
layer1_ffn_norm_tensor_dim3:
	.skip 8
layer1_ffn_norm_tensor_ggml_type:
	.skip 8
layer1_ffn_norm_tensor_offset:
	.skip 8

.balign 8
layer1_ffn_gate_tensor_slot:
layer1_ffn_gate_tensor_found:
	.skip 8
layer1_ffn_gate_tensor_name:
	.skip LAYER1_FFN_GATE_TENSOR_NAME_CAP
layer1_ffn_gate_tensor_n_dimensions:
	.skip 8
layer1_ffn_gate_tensor_dim0:
	.skip 8
layer1_ffn_gate_tensor_dim1:
	.skip 8
layer1_ffn_gate_tensor_dim2:
	.skip 8
layer1_ffn_gate_tensor_dim3:
	.skip 8
layer1_ffn_gate_tensor_ggml_type:
	.skip 8
layer1_ffn_gate_tensor_offset:
	.skip 8

.balign 8
layer1_ffn_up_tensor_slot:
layer1_ffn_up_tensor_found:
	.skip 8
layer1_ffn_up_tensor_name:
	.skip LAYER1_FFN_UP_TENSOR_NAME_CAP
layer1_ffn_up_tensor_n_dimensions:
	.skip 8
layer1_ffn_up_tensor_dim0:
	.skip 8
layer1_ffn_up_tensor_dim1:
	.skip 8
layer1_ffn_up_tensor_dim2:
	.skip 8
layer1_ffn_up_tensor_dim3:
	.skip 8
layer1_ffn_up_tensor_ggml_type:
	.skip 8
layer1_ffn_up_tensor_offset:
	.skip 8

.balign 8
token0_embedding_dequant_status:
	.skip 8

.balign 8
token0_attn_norm_status:
	.skip 8

.balign 8
token0_attn_q_matvec_status:
	.skip 8

.balign 8
token0_attn_k_matvec_status:
	.skip 8

.balign 8
token0_attn_v_matvec_status:
	.skip 8

.balign 8
token0_attn_context_status:
	.skip 8

.balign 8
token0_attn_output_matvec_status:
	.skip 8

.balign 8
token0_post_attn_residual_status:
	.skip 8

.balign 8
token0_ffn_norm_status:
	.skip 8

.balign 8
token0_ffn_gate_matvec_status:
	.skip 8

.balign 8
token0_ffn_up_matvec_status:
	.skip 8

.balign 8
token0_ffn_swiglu_status:
	.skip 8

.balign 8
token0_ffn_down_matvec_status:
	.skip 8

.balign 8
token0_post_ffn_residual_status:
	.skip 8

.balign 8
token0_layer1_attn_norm_status:
	.skip 8

.balign 8
token0_layer1_attn_q_matvec_status:
	.skip 8

.balign 8
token0_layer1_attn_k_matvec_status:
	.skip 8

.balign 8
token0_layer1_attn_v_matvec_status:
	.skip 8

.balign 8
token0_layer1_attn_context_status:
	.skip 8

.balign 8
token0_layer1_attn_output_matvec_status:
	.skip 8

.balign 8
token0_layer1_post_attn_residual_status:
	.skip 8

.balign 8
token0_layer1_ffn_norm_status:
	.skip 8

.balign 4
token_embedding_activation:
	.skip TOKEN_EMBEDDING_ACTIVATION_BYTES

.balign 4
token0_attn_norm_activation:
	.skip TOKEN_EMBEDDING_ACTIVATION_BYTES

.balign 4
token0_attn_q_output:
	.skip TOKEN0_ATTN_Q_OUTPUT_BYTES

.balign 4
token0_attn_k_output:
	.skip TOKEN0_ATTN_K_OUTPUT_BYTES

.balign 4
token0_attn_v_output:
	.skip TOKEN0_ATTN_V_OUTPUT_BYTES

.balign 4
token0_attn_context:
	.skip TOKEN0_ATTN_CONTEXT_BYTES

.balign 4
token0_attn_output:
	.skip TOKEN0_ATTN_OUTPUT_BYTES

.balign 4
token0_post_attn_residual:
	.skip TOKEN0_POST_ATTN_RESIDUAL_BYTES

.balign 4
token0_ffn_norm_activation:
	.skip TOKEN0_FFN_NORM_BYTES

.balign 4
token0_ffn_gate_output:
	.skip TOKEN0_FFN_GATE_OUTPUT_BYTES

.balign 4
token0_ffn_up_output:
	.skip TOKEN0_FFN_UP_OUTPUT_BYTES

.balign 4
token0_ffn_swiglu_output:
	.skip TOKEN0_FFN_SWIGLU_BYTES

.balign 4
token0_ffn_down_output:
	.skip TOKEN0_FFN_DOWN_OUTPUT_BYTES

.balign 4
token0_post_ffn_residual:
	.skip TOKEN0_POST_FFN_RESIDUAL_BYTES

.balign 4
token0_layer1_attn_norm_activation:
	.skip TOKEN0_LAYER1_ATTN_NORM_BYTES

.balign 4
token0_layer1_attn_q_output:
	.skip TOKEN0_LAYER1_ATTN_Q_OUTPUT_BYTES

.balign 4
token0_layer1_attn_k_output:
	.skip TOKEN0_LAYER1_ATTN_K_OUTPUT_BYTES

.balign 4
token0_layer1_attn_v_output:
	.skip TOKEN0_LAYER1_ATTN_V_OUTPUT_BYTES

.balign 4
token0_layer1_attn_context:
	.skip TOKEN0_LAYER1_ATTN_CONTEXT_BYTES

.balign 4
token0_layer1_attn_output:
	.skip TOKEN0_LAYER1_ATTN_OUTPUT_BYTES

.balign 4
token0_layer1_post_attn_residual:
	.skip TOKEN0_LAYER1_POST_ATTN_RESIDUAL_BYTES

.balign 4
token0_layer1_ffn_norm_activation:
	.skip TOKEN0_LAYER1_FFN_NORM_BYTES

.section .text

.global _start
.type _start, @function

# Contract: process entry point for the current runtime milestone.
# Inputs: initial Linux process stack at rsp; argv[0..argc-1] and envp follow
# the System V AMD64 process-start layout. This function currently accepts
# either "--help" or one GGUF model path.
# Outputs: does not return. Writes help, success, or diagnostic text, then exits
# with status 0 for help/valid GGUF summary and smoke handling, 2 for CLI usage
# errors, or 3 for GGUF validation errors.
# Clobbers: all general-purpose registers may be clobbered; no caller exists.
# Ownership/lifetime: argv strings remain kernel-provided process memory. The
# loader returns a live read-only model mapping descriptor on success; _start
# keeps it live through the current summary path and token embedding, RMSNorm,
# first query projection, first key projection, and first value projection
# smokes, then derives the single-token attention context and projects it
# through the first output projection before adding the post-attention residual
# from process-owned static buffers, applies the FFN RMSNorm smoke through
# retained FFN norm weights, and projects that activation through the retained
# FFN gate and up matrices before deriving the first FFN SwiGLU activation,
# projecting it through the retained FFN down matrix, adding the guarded post-FFN
# residual from process-owned static buffers, then applying guarded layer-1
# attention RMSNorm, query/key/value projection, context, output projection, and
# post-attention residual smokes through reusable layer-1 descriptors, delegating
# the layer-1 FFN RMSNorm and gate matvec smokes to focused inference code, and
# publishing
# status-gated exact-hex slices from the audited output buffers. It also
# performs non-math reusable descriptor lookups for
# `blk.1.attn_norm.weight`, `blk.1.attn_q.weight`, `blk.1.attn_k.weight`,
# `blk.1.attn_v.weight`, `blk.1.attn_output.weight`, and
# `blk.1.ffn_norm.weight`, `blk.1.ffn_gate.weight`, and
# `blk.1.ffn_up.weight` into separate process-owned scratch slots before the
# token-0 math path. The up descriptor is still descriptor-only in this step;
# the gate descriptor is consumed only by the layer-1 FFN gate status smoke
# after the FFN-normalized activation exists. The mapping is released explicitly
# with
# gguf_release_mapping before exit. The GGUF summary buffer is process-owned
# static storage passed to the loader for scalar header counts, bounded metadata
# string copies, and selected scalar and array-length
# metadata values, plus a bounded snapshot of the first tensor descriptor and
# the first requested tensor-name lookup, including up to four dimension sizes
# for each retained descriptor, the tensor-info directory start offset, the
# aligned tensor-data base offset for non-empty tensor directories, and a
# retained descriptor for the first-layer attention RMSNorm weights, query
# projection, key projection, value projection, output projection, FFN RMSNorm
# weights, and FFN gate, FFN up, and FFN down projections.
# Error behavior: maps gguf_validate_file and post-validation tensor lookup
# status codes to stderr diagnostics after releasing any live mapping.
_start:
	# argc is the first word on the initial process stack. The milestone CLI
	# accepts exactly one user argument: either "--help" or a model path.
	mov rax, qword ptr [rsp]
	cmp rax, 2
	jne .Lusage_error

	# Compare argv[1] against the literal help flag before treating it as a
	# filesystem path. str_eq_exact also rejects longer strings with this prefix.
	mov rdi, qword ptr [rsp + 16]
	lea rsi, [rip + help_arg]
	mov rdx, help_arg_end - help_arg
	call str_eq_exact
	test rax, rax
	jz .Lvalidate_model

	# Help output goes to stdout. sys_exit never returns, so no cleanup follows.
	mov rdi, 1
	lea rsi, [rip + help_text]
	mov rdx, help_text_end - help_text
	call sys_write

	xor rdi, rdi
	call sys_exit

.Lvalidate_model:
	# The loader closes the file descriptor after validation and hands back a
	# read-only mapping descriptor. Keeping the mapping live here is the handoff
	# needed before tensor payload reads are added.
	mov rdi, qword ptr [rsp + 16]
	lea rsi, [rip + gguf_summary]
	lea rdx, [rip + lookup_tensor_request]
	mov rcx, lookup_tensor_request_end - lookup_tensor_request
	lea r8, [rip + gguf_mapping]
	call gguf_validate_file
	test rax, rax
	jz .Lgguf_ok

	# Keep this dispatch explicit while the status enum is still small; it makes
	# audit of each user-visible failure path straightforward.
	cmp rax, 1
	je .Lgguf_open_error
	cmp rax, 2
	je .Lgguf_fstat_error
	cmp rax, 3
	je .Lgguf_too_small_error
	cmp rax, 4
	je .Lgguf_mmap_error
	cmp rax, 5
	je .Lgguf_magic_error
	cmp rax, 6
	je .Lgguf_version_error
	cmp rax, 7
	je .Lgguf_munmap_error
	cmp rax, 8
	je .Lgguf_count_error
	cmp rax, 9
	je .Lgguf_metadata_bounds_error
	cmp rax, 10
	je .Lgguf_metadata_type_error
	cmp rax, 11
	je .Lgguf_tensor_bounds_error
	cmp rax, 12
	je .Lgguf_tensor_alignment_error

	lea rsi, [rip + gguf_unknown_error_text]
	mov rdx, gguf_unknown_error_text_end - gguf_unknown_error_text
	jmp .Lwrite_model_error

.Lgguf_open_error:
	lea rsi, [rip + gguf_open_error_text]
	mov rdx, gguf_open_error_text_end - gguf_open_error_text
	jmp .Lwrite_model_error

.Lgguf_fstat_error:
	lea rsi, [rip + gguf_fstat_error_text]
	mov rdx, gguf_fstat_error_text_end - gguf_fstat_error_text
	jmp .Lwrite_model_error

.Lgguf_too_small_error:
	lea rsi, [rip + gguf_too_small_error_text]
	mov rdx, gguf_too_small_error_text_end - gguf_too_small_error_text
	jmp .Lwrite_model_error

.Lgguf_mmap_error:
	lea rsi, [rip + gguf_mmap_error_text]
	mov rdx, gguf_mmap_error_text_end - gguf_mmap_error_text
	jmp .Lwrite_model_error

.Lgguf_magic_error:
	lea rsi, [rip + gguf_magic_error_text]
	mov rdx, gguf_magic_error_text_end - gguf_magic_error_text
	jmp .Lwrite_model_error

.Lgguf_version_error:
	lea rsi, [rip + gguf_version_error_text]
	mov rdx, gguf_version_error_text_end - gguf_version_error_text
	jmp .Lwrite_model_error

.Lgguf_munmap_error:
	lea rsi, [rip + gguf_munmap_error_text]
	mov rdx, gguf_munmap_error_text_end - gguf_munmap_error_text
	jmp .Lwrite_model_error

.Lgguf_count_error:
	lea rsi, [rip + gguf_count_error_text]
	mov rdx, gguf_count_error_text_end - gguf_count_error_text
	jmp .Lwrite_model_error

.Lgguf_metadata_bounds_error:
	lea rsi, [rip + gguf_metadata_bounds_error_text]
	mov rdx, gguf_metadata_bounds_error_text_end - gguf_metadata_bounds_error_text
	jmp .Lwrite_model_error

.Lgguf_metadata_type_error:
	lea rsi, [rip + gguf_metadata_type_error_text]
	mov rdx, gguf_metadata_type_error_text_end - gguf_metadata_type_error_text
	jmp .Lwrite_model_error

.Lgguf_tensor_bounds_error:
	lea rsi, [rip + gguf_tensor_bounds_error_text]
	mov rdx, gguf_tensor_bounds_error_text_end - gguf_tensor_bounds_error_text
	jmp .Lwrite_model_error

.Lgguf_tensor_alignment_error:
	lea rsi, [rip + gguf_tensor_alignment_error_text]
	mov rdx, gguf_tensor_alignment_error_text_end - gguf_tensor_alignment_error_text

.Lwrite_model_error:
	# Loader and post-validation lookup failures are runtime errors, distinct
	# from CLI misuse.
	mov rdi, 2
	call sys_write

	mov rdi, 3
	call sys_exit

.Lgguf_ok:
	# Exercise the reusable tensor-info lookup on later-layer descriptors while
	# leaving the fixed first-layer summary slots as the only inputs to the
	# token-0 layer-0 math smoke path below.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_attn_norm_tensor_request]
	mov r9, layer1_attn_norm_tensor_request_end - layer1_attn_norm_tensor_request
	lea r10, [rip + layer1_attn_norm_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_attn_q_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_attn_q_tensor:
	# Keep the next-layer query projection descriptor separate from the fixed
	# first-layer summary slots. The math smoke below consumes only this generic
	# slot after the layer-1 RMSNorm activation exists.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_attn_q_tensor_request]
	mov r9, layer1_attn_q_tensor_request_end - layer1_attn_q_tensor_request
	lea r10, [rip + layer1_attn_q_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_attn_k_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_attn_k_tensor:
	# Capture the next-layer key projection descriptor for descriptor-only smoke
	# coverage. No key projection payload bytes are read in this step.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_attn_k_tensor_request]
	mov r9, layer1_attn_k_tensor_request_end - layer1_attn_k_tensor_request
	lea r10, [rip + layer1_attn_k_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_attn_v_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_attn_v_tensor:
	# Capture the next-layer value projection descriptor for descriptor-only smoke
	# coverage. No layer-1 value projection payload bytes are read in this step.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_attn_v_tensor_request]
	mov r9, layer1_attn_v_tensor_request_end - layer1_attn_v_tensor_request
	lea r10, [rip + layer1_attn_v_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_attn_output_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_attn_output_tensor:
	# Capture the next-layer output projection descriptor for descriptor-only
	# coverage. The layer-1 output projection payload remains unread.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_attn_output_tensor_request]
	mov r9, layer1_attn_output_tensor_request_end - layer1_attn_output_tensor_request
	lea r10, [rip + layer1_attn_output_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_ffn_norm_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_ffn_norm_tensor:
	# Capture the next-layer FFN RMSNorm descriptor for descriptor-only coverage.
	# The tensor payload remains unread until a later RMSNorm smoke step.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_ffn_norm_tensor_request]
	mov r9, layer1_ffn_norm_tensor_request_end - layer1_ffn_norm_tensor_request
	lea r10, [rip + layer1_ffn_norm_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_ffn_gate_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_ffn_gate_tensor:
	# Capture the next-layer FFN gate descriptor for descriptor-only coverage.
	# This step intentionally prints only the directory summary and does not
	# inspect any Q8_0 payload bytes.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_ffn_gate_tensor_request]
	mov r9, layer1_ffn_gate_tensor_request_end - layer1_ffn_gate_tensor_request
	lea r10, [rip + layer1_ffn_gate_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Llookup_layer1_ffn_up_tensor
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_layer1_ffn_up_tensor:
	# Capture the next-layer FFN up descriptor for descriptor-only coverage.
	# The consumer matvec will be added in a later atomic step after this
	# directory lookup is independently visible.
	mov rdi, qword ptr [rip + gguf_mapping_base]
	mov rsi, qword ptr [rip + gguf_mapping_size]
	mov rdx, qword ptr [rip + gguf_summary_tensor_infos_offset]
	mov rcx, qword ptr [rip + gguf_summary_tensor_count]
	lea r8, [rip + layer1_ffn_up_tensor_request]
	mov r9, layer1_ffn_up_tensor_request_end - layer1_ffn_up_tensor_request
	lea r10, [rip + layer1_ffn_up_tensor_slot]
	mov r11, qword ptr [rip + gguf_summary_tensor_data_offset]
	call gguf_lookup_tensor_info
	test rax, rax
	jz .Lsummary_print
	cmp rax, 12
	je .Llookup_tensor_alignment_error
	cmp rax, 11
	je .Llookup_tensor_bounds_error
	jmp .Llookup_unknown_error

.Llookup_tensor_alignment_error:
	lea rdi, [rip + gguf_mapping]
	call gguf_release_mapping
	lea rsi, [rip + gguf_tensor_alignment_error_text]
	mov rdx, gguf_tensor_alignment_error_text_end - gguf_tensor_alignment_error_text
	jmp .Lwrite_model_error

.Llookup_tensor_bounds_error:
	lea rdi, [rip + gguf_mapping]
	call gguf_release_mapping
	lea rsi, [rip + gguf_tensor_bounds_error_text]
	mov rdx, gguf_tensor_bounds_error_text_end - gguf_tensor_bounds_error_text
	jmp .Lwrite_model_error

.Llookup_unknown_error:
	lea rdi, [rip + gguf_mapping]
	call gguf_release_mapping
	lea rsi, [rip + gguf_unknown_error_text]
	mov rdx, gguf_unknown_error_text_end - gguf_unknown_error_text
	jmp .Lwrite_model_error

.Lsummary_print:
	# This milestone validates the fixed GGUF header, metadata shapes, and
	# tensor-info directory bounds, then exposes header counts, selected metadata,
	# the aligned tensor-data base, and retained tensor descriptors in
	# caller-owned storage.
	mov rdi, 1
	lea rsi, [rip + gguf_ok_text]
	mov rdx, gguf_ok_text_end - gguf_ok_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + tensor_count_text]
	mov rdx, tensor_count_text_end - tensor_count_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_tensor_count]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + metadata_count_text]
	mov rdx, metadata_count_text_end - metadata_count_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_metadata_count]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + architecture_text]
	mov rdx, architecture_text_end - architecture_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_architecture]
	mov rdx, GGUF_SUMMARY_ARCHITECTURE_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + context_length_text]
	mov rdx, context_length_text_end - context_length_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_context_length]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + block_count_text]
	mov rdx, block_count_text_end - block_count_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_block_count]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + vocab_size_text]
	mov rdx, vocab_size_text_end - vocab_size_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_vocab_size]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_rms_epsilon_found_text]
	mov rdx, attn_norm_rms_epsilon_found_text_end - attn_norm_rms_epsilon_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_rms_epsilon_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_rms_epsilon_f32_text]
	mov rdx, attn_norm_rms_epsilon_f32_text_end - attn_norm_rms_epsilon_f32_text
	call sys_write

	mov rdi, 1
	mov esi, dword ptr [rip + gguf_summary_attn_norm_rms_epsilon_f32]
	call write_u32_hex

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + tensor_infos_offset_text]
	mov rdx, tensor_infos_offset_text_end - tensor_infos_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_tensor_infos_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + tensor_data_offset_text]
	mov rdx, tensor_data_offset_text_end - tensor_data_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_tensor_data_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_layer1_attn_norm_lookup_summary
	call print_layer1_attn_q_lookup_summary
	call print_layer1_attn_k_lookup_summary
	call print_layer1_attn_v_lookup_summary
	call print_layer1_attn_output_lookup_summary
	call print_layer1_ffn_norm_lookup_summary
	call print_layer1_ffn_gate_lookup_summary
	call print_layer1_ffn_up_lookup_summary

	mov rdi, 1
	lea rsi, [rip + first_tensor_name_text]
	mov rdx, first_tensor_name_text_end - first_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_first_tensor_name]
	mov rdx, GGUF_SUMMARY_FIRST_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_n_dimensions_text]
	mov rdx, first_tensor_n_dimensions_text_end - first_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_dim0_text]
	mov rdx, first_tensor_dim0_text_end - first_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_dim1_text]
	mov rdx, first_tensor_dim1_text_end - first_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_dim2_text]
	mov rdx, first_tensor_dim2_text_end - first_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_dim3_text]
	mov rdx, first_tensor_dim3_text_end - first_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_ggml_type_text]
	mov rdx, first_tensor_ggml_type_text_end - first_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + first_tensor_offset_text]
	mov rdx, first_tensor_offset_text_end - first_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_first_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_found_text]
	mov rdx, lookup_tensor_found_text_end - lookup_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_name_text]
	mov rdx, lookup_tensor_name_text_end - lookup_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_lookup_tensor_name]
	mov rdx, GGUF_SUMMARY_LOOKUP_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_n_dimensions_text]
	mov rdx, lookup_tensor_n_dimensions_text_end - lookup_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_dim0_text]
	mov rdx, lookup_tensor_dim0_text_end - lookup_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_dim1_text]
	mov rdx, lookup_tensor_dim1_text_end - lookup_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_dim2_text]
	mov rdx, lookup_tensor_dim2_text_end - lookup_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_dim3_text]
	mov rdx, lookup_tensor_dim3_text_end - lookup_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_ggml_type_text]
	mov rdx, lookup_tensor_ggml_type_text_end - lookup_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + lookup_tensor_offset_text]
	mov rdx, lookup_tensor_offset_text_end - lookup_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_lookup_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_found_text]
	mov rdx, attn_norm_tensor_found_text_end - attn_norm_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_name_text]
	mov rdx, attn_norm_tensor_name_text_end - attn_norm_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_attn_norm_tensor_name]
	mov rdx, GGUF_SUMMARY_ATTN_NORM_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_n_dimensions_text]
	mov rdx, attn_norm_tensor_n_dimensions_text_end - attn_norm_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_dim0_text]
	mov rdx, attn_norm_tensor_dim0_text_end - attn_norm_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_dim1_text]
	mov rdx, attn_norm_tensor_dim1_text_end - attn_norm_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_dim2_text]
	mov rdx, attn_norm_tensor_dim2_text_end - attn_norm_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_dim3_text]
	mov rdx, attn_norm_tensor_dim3_text_end - attn_norm_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_ggml_type_text]
	mov rdx, attn_norm_tensor_ggml_type_text_end - attn_norm_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_norm_tensor_offset_text]
	mov rdx, attn_norm_tensor_offset_text_end - attn_norm_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_norm_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_found_text]
	mov rdx, attn_q_tensor_found_text_end - attn_q_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_name_text]
	mov rdx, attn_q_tensor_name_text_end - attn_q_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_attn_q_tensor_name]
	mov rdx, GGUF_SUMMARY_ATTN_Q_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_n_dimensions_text]
	mov rdx, attn_q_tensor_n_dimensions_text_end - attn_q_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_dim0_text]
	mov rdx, attn_q_tensor_dim0_text_end - attn_q_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_dim1_text]
	mov rdx, attn_q_tensor_dim1_text_end - attn_q_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_dim2_text]
	mov rdx, attn_q_tensor_dim2_text_end - attn_q_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_dim3_text]
	mov rdx, attn_q_tensor_dim3_text_end - attn_q_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_ggml_type_text]
	mov rdx, attn_q_tensor_ggml_type_text_end - attn_q_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_q_tensor_offset_text]
	mov rdx, attn_q_tensor_offset_text_end - attn_q_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_q_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_found_text]
	mov rdx, attn_k_tensor_found_text_end - attn_k_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_name_text]
	mov rdx, attn_k_tensor_name_text_end - attn_k_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_attn_k_tensor_name]
	mov rdx, GGUF_SUMMARY_ATTN_K_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_n_dimensions_text]
	mov rdx, attn_k_tensor_n_dimensions_text_end - attn_k_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_dim0_text]
	mov rdx, attn_k_tensor_dim0_text_end - attn_k_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_dim1_text]
	mov rdx, attn_k_tensor_dim1_text_end - attn_k_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_dim2_text]
	mov rdx, attn_k_tensor_dim2_text_end - attn_k_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_dim3_text]
	mov rdx, attn_k_tensor_dim3_text_end - attn_k_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_ggml_type_text]
	mov rdx, attn_k_tensor_ggml_type_text_end - attn_k_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_k_tensor_offset_text]
	mov rdx, attn_k_tensor_offset_text_end - attn_k_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_k_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_found_text]
	mov rdx, attn_v_tensor_found_text_end - attn_v_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_name_text]
	mov rdx, attn_v_tensor_name_text_end - attn_v_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_attn_v_tensor_name]
	mov rdx, GGUF_SUMMARY_ATTN_V_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_n_dimensions_text]
	mov rdx, attn_v_tensor_n_dimensions_text_end - attn_v_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_dim0_text]
	mov rdx, attn_v_tensor_dim0_text_end - attn_v_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_dim1_text]
	mov rdx, attn_v_tensor_dim1_text_end - attn_v_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_dim2_text]
	mov rdx, attn_v_tensor_dim2_text_end - attn_v_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_dim3_text]
	mov rdx, attn_v_tensor_dim3_text_end - attn_v_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_ggml_type_text]
	mov rdx, attn_v_tensor_ggml_type_text_end - attn_v_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_v_tensor_offset_text]
	mov rdx, attn_v_tensor_offset_text_end - attn_v_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_v_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_found_text]
	mov rdx, attn_output_tensor_found_text_end - attn_output_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_name_text]
	mov rdx, attn_output_tensor_name_text_end - attn_output_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_attn_output_tensor_name]
	mov rdx, GGUF_SUMMARY_ATTN_OUTPUT_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_n_dimensions_text]
	mov rdx, attn_output_tensor_n_dimensions_text_end - attn_output_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_dim0_text]
	mov rdx, attn_output_tensor_dim0_text_end - attn_output_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_dim1_text]
	mov rdx, attn_output_tensor_dim1_text_end - attn_output_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_dim2_text]
	mov rdx, attn_output_tensor_dim2_text_end - attn_output_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_dim3_text]
	mov rdx, attn_output_tensor_dim3_text_end - attn_output_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_ggml_type_text]
	mov rdx, attn_output_tensor_ggml_type_text_end - attn_output_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + attn_output_tensor_offset_text]
	mov rdx, attn_output_tensor_offset_text_end - attn_output_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_attn_output_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_found_text]
	mov rdx, ffn_norm_tensor_found_text_end - ffn_norm_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_name_text]
	mov rdx, ffn_norm_tensor_name_text_end - ffn_norm_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_ffn_norm_tensor_name]
	mov rdx, GGUF_SUMMARY_FFN_NORM_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_n_dimensions_text]
	mov rdx, ffn_norm_tensor_n_dimensions_text_end - ffn_norm_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_dim0_text]
	mov rdx, ffn_norm_tensor_dim0_text_end - ffn_norm_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_dim1_text]
	mov rdx, ffn_norm_tensor_dim1_text_end - ffn_norm_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_dim2_text]
	mov rdx, ffn_norm_tensor_dim2_text_end - ffn_norm_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_dim3_text]
	mov rdx, ffn_norm_tensor_dim3_text_end - ffn_norm_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_ggml_type_text]
	mov rdx, ffn_norm_tensor_ggml_type_text_end - ffn_norm_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_norm_tensor_offset_text]
	mov rdx, ffn_norm_tensor_offset_text_end - ffn_norm_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_norm_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_found_text]
	mov rdx, ffn_gate_tensor_found_text_end - ffn_gate_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_name_text]
	mov rdx, ffn_gate_tensor_name_text_end - ffn_gate_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_ffn_gate_tensor_name]
	mov rdx, GGUF_SUMMARY_FFN_GATE_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_n_dimensions_text]
	mov rdx, ffn_gate_tensor_n_dimensions_text_end - ffn_gate_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_dim0_text]
	mov rdx, ffn_gate_tensor_dim0_text_end - ffn_gate_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_dim1_text]
	mov rdx, ffn_gate_tensor_dim1_text_end - ffn_gate_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_dim2_text]
	mov rdx, ffn_gate_tensor_dim2_text_end - ffn_gate_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_dim3_text]
	mov rdx, ffn_gate_tensor_dim3_text_end - ffn_gate_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_ggml_type_text]
	mov rdx, ffn_gate_tensor_ggml_type_text_end - ffn_gate_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_gate_tensor_offset_text]
	mov rdx, ffn_gate_tensor_offset_text_end - ffn_gate_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_gate_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_found_text]
	mov rdx, ffn_up_tensor_found_text_end - ffn_up_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_name_text]
	mov rdx, ffn_up_tensor_name_text_end - ffn_up_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_ffn_up_tensor_name]
	mov rdx, GGUF_SUMMARY_FFN_UP_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_n_dimensions_text]
	mov rdx, ffn_up_tensor_n_dimensions_text_end - ffn_up_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_dim0_text]
	mov rdx, ffn_up_tensor_dim0_text_end - ffn_up_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_dim1_text]
	mov rdx, ffn_up_tensor_dim1_text_end - ffn_up_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_dim2_text]
	mov rdx, ffn_up_tensor_dim2_text_end - ffn_up_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_dim3_text]
	mov rdx, ffn_up_tensor_dim3_text_end - ffn_up_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_ggml_type_text]
	mov rdx, ffn_up_tensor_ggml_type_text_end - ffn_up_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_up_tensor_offset_text]
	mov rdx, ffn_up_tensor_offset_text_end - ffn_up_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_up_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_found_text]
	mov rdx, ffn_down_tensor_found_text_end - ffn_down_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_name_text]
	mov rdx, ffn_down_tensor_name_text_end - ffn_down_tensor_name_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + gguf_summary_ffn_down_tensor_name]
	mov rdx, GGUF_SUMMARY_FFN_DOWN_TENSOR_NAME_CAP
	call write_bounded_c_string

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_n_dimensions_text]
	mov rdx, ffn_down_tensor_n_dimensions_text_end - ffn_down_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_dim0_text]
	mov rdx, ffn_down_tensor_dim0_text_end - ffn_down_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_dim1_text]
	mov rdx, ffn_down_tensor_dim1_text_end - ffn_down_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_dim2_text]
	mov rdx, ffn_down_tensor_dim2_text_end - ffn_down_tensor_dim2_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_dim2]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_dim3_text]
	mov rdx, ffn_down_tensor_dim3_text_end - ffn_down_tensor_dim3_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_dim3]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_ggml_type_text]
	mov rdx, ffn_down_tensor_ggml_type_text_end - ffn_down_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + ffn_down_tensor_offset_text]
	mov rdx, ffn_down_tensor_offset_text_end - ffn_down_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + gguf_summary_ffn_down_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	# The token-0 embedding smoke is deliberately after the summary print so the
	# retained descriptor remains visible even when a narrow synthetic GGUF is not
	# target-shaped enough to dequantize.
	call dequant_token0_embedding_smoke
	mov qword ptr [rip + token0_embedding_dequant_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_embedding_dequant_text]
	mov rdx, token0_embedding_dequant_text_end - token0_embedding_dequant_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_embedding_dequant_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call token0_attn_norm_smoke
	mov qword ptr [rip + token0_attn_norm_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_attn_norm_text]
	mov rdx, token0_attn_norm_text_end - token0_attn_norm_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_attn_norm_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call token0_attn_q_matvec_smoke
	mov qword ptr [rip + token0_attn_q_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_attn_q_matvec_text]
	mov rdx, token0_attn_q_matvec_text_end - token0_attn_q_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_attn_q_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_attn_q_output_slice

	call token0_attn_k_matvec_smoke
	mov qword ptr [rip + token0_attn_k_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_attn_k_matvec_text]
	mov rdx, token0_attn_k_matvec_text_end - token0_attn_k_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_attn_k_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_attn_k_output_slice

	call token0_attn_v_matvec_smoke
	mov qword ptr [rip + token0_attn_v_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_attn_v_matvec_text]
	mov rdx, token0_attn_v_matvec_text_end - token0_attn_v_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_attn_v_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_attn_v_output_slice

	call token0_attn_context_smoke
	mov qword ptr [rip + token0_attn_context_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_attn_context_text]
	mov rdx, token0_attn_context_text_end - token0_attn_context_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_attn_context_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_attn_context_slice

	call token0_attn_output_matvec_smoke
	mov qword ptr [rip + token0_attn_output_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_attn_output_matvec_text]
	mov rdx, token0_attn_output_matvec_text_end - token0_attn_output_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_attn_output_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_attn_output_slice

	call token0_post_attn_residual_smoke
	mov qword ptr [rip + token0_post_attn_residual_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_post_attn_residual_text]
	mov rdx, token0_post_attn_residual_text_end - token0_post_attn_residual_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_post_attn_residual_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_post_attn_residual_slice

	call token0_ffn_norm_smoke
	mov qword ptr [rip + token0_ffn_norm_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_ffn_norm_text]
	mov rdx, token0_ffn_norm_text_end - token0_ffn_norm_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_ffn_norm_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_ffn_norm_slice

	call token0_ffn_gate_matvec_smoke
	mov qword ptr [rip + token0_ffn_gate_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_ffn_gate_matvec_text]
	mov rdx, token0_ffn_gate_matvec_text_end - token0_ffn_gate_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_ffn_gate_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_ffn_gate_output_slice

	call token0_ffn_up_matvec_smoke
	mov qword ptr [rip + token0_ffn_up_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_ffn_up_matvec_text]
	mov rdx, token0_ffn_up_matvec_text_end - token0_ffn_up_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_ffn_up_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_ffn_up_output_slice

	call token0_ffn_swiglu_smoke
	mov qword ptr [rip + token0_ffn_swiglu_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_ffn_swiglu_text]
	mov rdx, token0_ffn_swiglu_text_end - token0_ffn_swiglu_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_ffn_swiglu_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_ffn_swiglu_output_slice

	call token0_ffn_down_matvec_smoke
	mov qword ptr [rip + token0_ffn_down_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_ffn_down_matvec_text]
	mov rdx, token0_ffn_down_matvec_text_end - token0_ffn_down_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_ffn_down_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_ffn_down_output_slice

	call token0_post_ffn_residual_smoke
	mov qword ptr [rip + token0_post_ffn_residual_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_post_ffn_residual_text]
	mov rdx, token0_post_ffn_residual_text_end - token0_post_ffn_residual_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_post_ffn_residual_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_post_ffn_residual_slice

	call token0_layer1_attn_norm_smoke
	mov qword ptr [rip + token0_layer1_attn_norm_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_norm_text]
	mov rdx, token0_layer1_attn_norm_text_end - token0_layer1_attn_norm_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_attn_norm_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_attn_norm_slice

	call token0_layer1_attn_q_matvec_smoke
	mov qword ptr [rip + token0_layer1_attn_q_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_q_matvec_text]
	mov rdx, token0_layer1_attn_q_matvec_text_end - token0_layer1_attn_q_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_attn_q_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_attn_q_output_slice

	call token0_layer1_attn_k_matvec_smoke
	mov qword ptr [rip + token0_layer1_attn_k_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_k_matvec_text]
	mov rdx, token0_layer1_attn_k_matvec_text_end - token0_layer1_attn_k_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_attn_k_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_attn_k_output_slice

	call token0_layer1_attn_v_matvec_smoke
	mov qword ptr [rip + token0_layer1_attn_v_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_v_matvec_text]
	mov rdx, token0_layer1_attn_v_matvec_text_end - token0_layer1_attn_v_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_attn_v_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_attn_v_output_slice

	call token0_layer1_attn_context_smoke
	mov qword ptr [rip + token0_layer1_attn_context_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_context_text]
	mov rdx, token0_layer1_attn_context_text_end - token0_layer1_attn_context_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_attn_context_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_attn_context_slice

	call token0_layer1_attn_output_matvec_smoke
	mov qword ptr [rip + token0_layer1_attn_output_matvec_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_attn_output_matvec_text]
	mov rdx, token0_layer1_attn_output_matvec_text_end - token0_layer1_attn_output_matvec_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_attn_output_matvec_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_attn_output_slice

	call token0_layer1_post_attn_residual_smoke
	mov qword ptr [rip + token0_layer1_post_attn_residual_status], rax

	mov rdi, 1
	lea rsi, [rip + token0_layer1_post_attn_residual_text]
	mov rdx, token0_layer1_post_attn_residual_text_end - token0_layer1_post_attn_residual_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + token0_layer1_post_attn_residual_status]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	call print_token0_layer1_post_attn_residual_slice

	call run_token0_layer1_ffn_norm_status

	call run_token0_layer1_ffn_gate_matvec_status

	# The live mapping has now served parser summary and guarded tensor payload
	# smoke paths. Ownership remains explicit and is released before exit.
	lea rdi, [rip + gguf_mapping]
	call gguf_release_mapping
	test rax, rax
	jz .Lsummary_exit_ok

	lea rsi, [rip + gguf_munmap_error_text]
	mov rdx, gguf_munmap_error_text_end - gguf_munmap_error_text
	jmp .Lwrite_model_error

.Lsummary_exit_ok:
	xor rdi, rdi
	call sys_exit

.Lusage_error:
	# Usage errors are intentionally handled before any file syscall.
	mov rdi, 2
	lea rsi, [rip + usage_error_text]
	mov rdx, usage_error_text_end - usage_error_text
	call sys_write

	mov rdi, 2
	call sys_exit

.size _start, . - _start

.type print_layer1_attn_norm_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.1.attn_norm.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info after model validation.
# Outputs: writes found flag, dimension count, first dimension, ggml_type, and
# relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads static scratch storage only during this call and
# does not retain mapped-file pointers.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer1_attn_norm_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer1_attn_norm_tensor_found_text]
	mov rdx, layer1_attn_norm_tensor_found_text_end - layer1_attn_norm_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_norm_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_norm_tensor_n_dimensions_text]
	mov rdx, layer1_attn_norm_tensor_n_dimensions_text_end - layer1_attn_norm_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_norm_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_norm_tensor_dim0_text]
	mov rdx, layer1_attn_norm_tensor_dim0_text_end - layer1_attn_norm_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_norm_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_norm_tensor_ggml_type_text]
	mov rdx, layer1_attn_norm_tensor_ggml_type_text_end - layer1_attn_norm_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_norm_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_norm_tensor_offset_text]
	mov rdx, layer1_attn_norm_tensor_offset_text_end - layer1_attn_norm_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_norm_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer1_attn_norm_lookup_summary, . - print_layer1_attn_norm_lookup_summary

.type print_layer1_attn_q_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.1.attn_q.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info after model validation.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads static scratch storage only during this call and
# does not retain mapped-file pointers.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer1_attn_q_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer1_attn_q_tensor_found_text]
	mov rdx, layer1_attn_q_tensor_found_text_end - layer1_attn_q_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_q_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_q_tensor_n_dimensions_text]
	mov rdx, layer1_attn_q_tensor_n_dimensions_text_end - layer1_attn_q_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_q_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_q_tensor_dim0_text]
	mov rdx, layer1_attn_q_tensor_dim0_text_end - layer1_attn_q_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_q_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_q_tensor_dim1_text]
	mov rdx, layer1_attn_q_tensor_dim1_text_end - layer1_attn_q_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_q_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_q_tensor_ggml_type_text]
	mov rdx, layer1_attn_q_tensor_ggml_type_text_end - layer1_attn_q_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_q_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_q_tensor_offset_text]
	mov rdx, layer1_attn_q_tensor_offset_text_end - layer1_attn_q_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_q_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer1_attn_q_lookup_summary, . - print_layer1_attn_q_lookup_summary

.type print_layer1_attn_k_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.1.attn_k.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info after model validation.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads static scratch storage only during this call and
# does not retain mapped-file pointers.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer1_attn_k_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer1_attn_k_tensor_found_text]
	mov rdx, layer1_attn_k_tensor_found_text_end - layer1_attn_k_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_k_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_k_tensor_n_dimensions_text]
	mov rdx, layer1_attn_k_tensor_n_dimensions_text_end - layer1_attn_k_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_k_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_k_tensor_dim0_text]
	mov rdx, layer1_attn_k_tensor_dim0_text_end - layer1_attn_k_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_k_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_k_tensor_dim1_text]
	mov rdx, layer1_attn_k_tensor_dim1_text_end - layer1_attn_k_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_k_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_k_tensor_ggml_type_text]
	mov rdx, layer1_attn_k_tensor_ggml_type_text_end - layer1_attn_k_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_k_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_k_tensor_offset_text]
	mov rdx, layer1_attn_k_tensor_offset_text_end - layer1_attn_k_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_k_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer1_attn_k_lookup_summary, . - print_layer1_attn_k_lookup_summary

.type print_layer1_attn_v_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.1.attn_v.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info after model validation.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads static scratch storage only during this call and
# does not retain mapped-file pointers.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer1_attn_v_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer1_attn_v_tensor_found_text]
	mov rdx, layer1_attn_v_tensor_found_text_end - layer1_attn_v_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_v_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_v_tensor_n_dimensions_text]
	mov rdx, layer1_attn_v_tensor_n_dimensions_text_end - layer1_attn_v_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_v_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_v_tensor_dim0_text]
	mov rdx, layer1_attn_v_tensor_dim0_text_end - layer1_attn_v_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_v_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_v_tensor_dim1_text]
	mov rdx, layer1_attn_v_tensor_dim1_text_end - layer1_attn_v_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_v_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_v_tensor_ggml_type_text]
	mov rdx, layer1_attn_v_tensor_ggml_type_text_end - layer1_attn_v_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_v_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_v_tensor_offset_text]
	mov rdx, layer1_attn_v_tensor_offset_text_end - layer1_attn_v_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_v_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer1_attn_v_lookup_summary, . - print_layer1_attn_v_lookup_summary

.type print_layer1_attn_output_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.1.attn_output.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info after model validation.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads static scratch storage only during this call and
# does not retain mapped-file pointers or inspect tensor payload bytes.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer1_attn_output_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer1_attn_output_tensor_found_text]
	mov rdx, layer1_attn_output_tensor_found_text_end - layer1_attn_output_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_output_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_output_tensor_n_dims_text]
	mov rdx, layer1_attn_output_tensor_n_dims_text_end - layer1_attn_output_tensor_n_dims_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_output_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_output_tensor_dim0_text]
	mov rdx, layer1_attn_output_tensor_dim0_text_end - layer1_attn_output_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_output_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_output_tensor_dim1_text]
	mov rdx, layer1_attn_output_tensor_dim1_text_end - layer1_attn_output_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_output_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_output_tensor_ggml_type_text]
	mov rdx, layer1_attn_output_tensor_ggml_type_text_end - layer1_attn_output_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_output_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_attn_output_tensor_offset_text]
	mov rdx, layer1_attn_output_tensor_offset_text_end - layer1_attn_output_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_attn_output_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer1_attn_output_lookup_summary, . - print_layer1_attn_output_lookup_summary

.type print_layer1_ffn_norm_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.1.ffn_norm.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info after model validation.
# Outputs: writes found flag, dimension count, first dimension, ggml_type, and
# relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads static scratch storage only during this call and
# does not retain mapped-file pointers or inspect tensor payload bytes.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer1_ffn_norm_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer1_ffn_norm_tensor_found_text]
	mov rdx, layer1_ffn_norm_tensor_found_text_end - layer1_ffn_norm_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_norm_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_norm_tensor_n_dimensions_text]
	mov rdx, layer1_ffn_norm_tensor_n_dimensions_text_end - layer1_ffn_norm_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_norm_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_norm_tensor_dim0_text]
	mov rdx, layer1_ffn_norm_tensor_dim0_text_end - layer1_ffn_norm_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_norm_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_norm_tensor_ggml_type_text]
	mov rdx, layer1_ffn_norm_tensor_ggml_type_text_end - layer1_ffn_norm_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_norm_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_norm_tensor_offset_text]
	mov rdx, layer1_ffn_norm_tensor_offset_text_end - layer1_ffn_norm_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_norm_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer1_ffn_norm_lookup_summary, . - print_layer1_ffn_norm_lookup_summary

.type print_layer1_ffn_gate_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.1.ffn_gate.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info after model validation.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads static scratch storage only during this call and
# does not retain mapped-file pointers or inspect tensor payload bytes.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer1_ffn_gate_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer1_ffn_gate_tensor_found_text]
	mov rdx, layer1_ffn_gate_tensor_found_text_end - layer1_ffn_gate_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_gate_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_gate_tensor_n_dimensions_text]
	mov rdx, layer1_ffn_gate_tensor_n_dimensions_text_end - layer1_ffn_gate_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_gate_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_gate_tensor_dim0_text]
	mov rdx, layer1_ffn_gate_tensor_dim0_text_end - layer1_ffn_gate_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_gate_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_gate_tensor_dim1_text]
	mov rdx, layer1_ffn_gate_tensor_dim1_text_end - layer1_ffn_gate_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_gate_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_gate_tensor_ggml_type_text]
	mov rdx, layer1_ffn_gate_tensor_ggml_type_text_end - layer1_ffn_gate_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_gate_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_gate_tensor_offset_text]
	mov rdx, layer1_ffn_gate_tensor_offset_text_end - layer1_ffn_gate_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_gate_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer1_ffn_gate_lookup_summary, . - print_layer1_ffn_gate_lookup_summary

.type print_layer1_ffn_up_lookup_summary, @function

# Contract: print the reusable descriptor-lookup smoke slot for
# `blk.1.ffn_up.weight`.
# Inputs: no register inputs. Reads the process-owned generic descriptor slot
# filled by gguf_lookup_tensor_info after model validation.
# Outputs: writes found flag, dimension count, first two dimensions, ggml_type,
# and relative payload offset to stdout.
# Clobbers: caller-saved registers and flags through sys_write and
# write_u64_decimal.
# Ownership/lifetime: reads static scratch storage only during this call and
# does not retain mapped-file pointers or inspect tensor payload bytes.
# Error behavior: this is diagnostic summary output; write failures are not
# surfaced separately.
print_layer1_ffn_up_lookup_summary:
	mov rdi, 1
	lea rsi, [rip + layer1_ffn_up_tensor_found_text]
	mov rdx, layer1_ffn_up_tensor_found_text_end - layer1_ffn_up_tensor_found_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_up_tensor_found]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_up_tensor_n_dimensions_text]
	mov rdx, layer1_ffn_up_tensor_n_dimensions_text_end - layer1_ffn_up_tensor_n_dimensions_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_up_tensor_n_dimensions]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_up_tensor_dim0_text]
	mov rdx, layer1_ffn_up_tensor_dim0_text_end - layer1_ffn_up_tensor_dim0_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_up_tensor_dim0]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_up_tensor_dim1_text]
	mov rdx, layer1_ffn_up_tensor_dim1_text_end - layer1_ffn_up_tensor_dim1_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_up_tensor_dim1]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_up_tensor_ggml_type_text]
	mov rdx, layer1_ffn_up_tensor_ggml_type_text_end - layer1_ffn_up_tensor_ggml_type_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_up_tensor_ggml_type]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	mov rdi, 1
	lea rsi, [rip + layer1_ffn_up_tensor_offset_text]
	mov rdx, layer1_ffn_up_tensor_offset_text_end - layer1_ffn_up_tensor_offset_text
	call sys_write

	mov rdi, 1
	mov rsi, qword ptr [rip + layer1_ffn_up_tensor_offset]
	call write_u64_decimal

	mov rdi, 1
	lea rsi, [rip + newline_text]
	mov rdx, newline_text_end - newline_text
	call sys_write

	ret

.size print_layer1_ffn_up_lookup_summary, . - print_layer1_ffn_up_lookup_summary

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

.section .note.GNU-stack,"",@progbits
