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
.global layer1_ffn_up_tensor_found
.global layer1_ffn_up_tensor_n_dimensions
.global layer1_ffn_up_tensor_dim0
.global layer1_ffn_up_tensor_dim1
.global layer1_ffn_up_tensor_ggml_type
.global layer1_ffn_up_tensor_offset
.global layer1_ffn_down_tensor_found
.global layer1_ffn_down_tensor_n_dimensions
.global layer1_ffn_down_tensor_dim0
.global layer1_ffn_down_tensor_dim1
.global layer1_ffn_down_tensor_ggml_type
.global layer1_ffn_down_tensor_offset
.global layer2_attn_norm_tensor_found
.global layer2_attn_norm_tensor_n_dimensions
.global layer2_attn_norm_tensor_dim0
.global layer2_attn_norm_tensor_ggml_type
.global layer2_attn_norm_tensor_offset
.global layer2_attn_q_tensor_found
.global layer2_attn_q_tensor_n_dimensions
.global layer2_attn_q_tensor_dim0
.global layer2_attn_q_tensor_dim1
.global layer2_attn_q_tensor_ggml_type
.global layer2_attn_q_tensor_offset
.global layer2_attn_k_tensor_found
.global layer2_attn_k_tensor_n_dimensions
.global layer2_attn_k_tensor_dim0
.global layer2_attn_k_tensor_dim1
.global layer2_attn_k_tensor_ggml_type
.global layer2_attn_k_tensor_offset
.global layer2_attn_v_tensor_found
.global layer2_attn_v_tensor_n_dimensions
.global layer2_attn_v_tensor_dim0
.global layer2_attn_v_tensor_dim1
.global layer2_attn_v_tensor_ggml_type
.global layer2_attn_v_tensor_offset
.global layer2_attn_output_tensor_found
.global layer2_attn_output_tensor_n_dimensions
.global layer2_attn_output_tensor_dim0
.global layer2_attn_output_tensor_dim1
.global layer2_attn_output_tensor_ggml_type
.global layer2_attn_output_tensor_offset
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
layer1_ffn_down_tensor_slot:
layer1_ffn_down_tensor_found:
	.skip 8
layer1_ffn_down_tensor_name:
	.skip LAYER1_FFN_DOWN_TENSOR_NAME_CAP
layer1_ffn_down_tensor_n_dimensions:
	.skip 8
layer1_ffn_down_tensor_dim0:
	.skip 8
layer1_ffn_down_tensor_dim1:
	.skip 8
layer1_ffn_down_tensor_dim2:
	.skip 8
layer1_ffn_down_tensor_dim3:
	.skip 8
layer1_ffn_down_tensor_ggml_type:
	.skip 8
layer1_ffn_down_tensor_offset:
	.skip 8

.balign 8
layer2_attn_norm_tensor_slot:
layer2_attn_norm_tensor_found:
	.skip 8
layer2_attn_norm_tensor_name:
	.skip LAYER2_ATTN_NORM_TENSOR_NAME_CAP
layer2_attn_norm_tensor_n_dimensions:
	.skip 8
layer2_attn_norm_tensor_dim0:
	.skip 8
layer2_attn_norm_tensor_dim1:
	.skip 8
layer2_attn_norm_tensor_dim2:
	.skip 8
layer2_attn_norm_tensor_dim3:
	.skip 8
layer2_attn_norm_tensor_ggml_type:
	.skip 8
layer2_attn_norm_tensor_offset:
	.skip 8

.balign 8
layer2_attn_q_tensor_slot:
layer2_attn_q_tensor_found:
	.skip 8
layer2_attn_q_tensor_name:
	.skip LAYER2_ATTN_Q_TENSOR_NAME_CAP
layer2_attn_q_tensor_n_dimensions:
	.skip 8
layer2_attn_q_tensor_dim0:
	.skip 8
layer2_attn_q_tensor_dim1:
	.skip 8
layer2_attn_q_tensor_dim2:
	.skip 8
layer2_attn_q_tensor_dim3:
	.skip 8
layer2_attn_q_tensor_ggml_type:
	.skip 8
layer2_attn_q_tensor_offset:
	.skip 8

.balign 8
layer2_attn_k_tensor_slot:
layer2_attn_k_tensor_found:
	.skip 8
layer2_attn_k_tensor_name:
	.skip LAYER2_ATTN_K_TENSOR_NAME_CAP
layer2_attn_k_tensor_n_dimensions:
	.skip 8
layer2_attn_k_tensor_dim0:
	.skip 8
layer2_attn_k_tensor_dim1:
	.skip 8
layer2_attn_k_tensor_dim2:
	.skip 8
layer2_attn_k_tensor_dim3:
	.skip 8
layer2_attn_k_tensor_ggml_type:
	.skip 8
layer2_attn_k_tensor_offset:
	.skip 8

.balign 8
layer2_attn_v_tensor_slot:
layer2_attn_v_tensor_found:
	.skip 8
layer2_attn_v_tensor_name:
	.skip LAYER2_ATTN_V_TENSOR_NAME_CAP
layer2_attn_v_tensor_n_dimensions:
	.skip 8
layer2_attn_v_tensor_dim0:
	.skip 8
layer2_attn_v_tensor_dim1:
	.skip 8
layer2_attn_v_tensor_dim2:
	.skip 8
layer2_attn_v_tensor_dim3:
	.skip 8
layer2_attn_v_tensor_ggml_type:
	.skip 8
layer2_attn_v_tensor_offset:
	.skip 8

.balign 8
layer2_attn_output_tensor_slot:
layer2_attn_output_tensor_found:
	.skip 8
layer2_attn_output_tensor_name:
	.skip LAYER2_ATTN_OUTPUT_TENSOR_NAME_CAP
layer2_attn_output_tensor_n_dimensions:
	.skip 8
layer2_attn_output_tensor_dim0:
	.skip 8
layer2_attn_output_tensor_dim1:
	.skip 8
layer2_attn_output_tensor_dim2:
	.skip 8
layer2_attn_output_tensor_dim3:
	.skip 8
layer2_attn_output_tensor_ggml_type:
	.skip 8
layer2_attn_output_tensor_offset:
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
