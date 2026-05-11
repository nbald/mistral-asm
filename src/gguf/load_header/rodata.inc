
.section .rodata

general_architecture_key:
	.ascii "general.architecture"
general_architecture_key_end:

mistral3_context_length_key:
	.ascii "mistral3.context_length"
mistral3_context_length_key_end:

mistral3_block_count_key:
	.ascii "mistral3.block_count"
mistral3_block_count_key_end:

mistral3_attn_norm_rms_epsilon_key:
	.ascii "mistral3.attention.layer_norm_rms_epsilon"
mistral3_attn_norm_rms_epsilon_key_end:

tokenizer_tokens_key:
	.ascii "tokenizer.ggml.tokens"
tokenizer_tokens_key_end:

attn_norm_tensor_request:
	.ascii "blk.0.attn_norm.weight"
attn_norm_tensor_request_end:

attn_q_tensor_request:
	.ascii "blk.0.attn_q.weight"
attn_q_tensor_request_end:

attn_k_tensor_request:
	.ascii "blk.0.attn_k.weight"
attn_k_tensor_request_end:

attn_v_tensor_request:
	.ascii "blk.0.attn_v.weight"
attn_v_tensor_request_end:

attn_output_tensor_request:
	.ascii "blk.0.attn_output.weight"
attn_output_tensor_request_end:

ffn_norm_tensor_request:
	.ascii "blk.0.ffn_norm.weight"
ffn_norm_tensor_request_end:

ffn_gate_tensor_request:
	.ascii "blk.0.ffn_gate.weight"
ffn_gate_tensor_request_end:

ffn_up_tensor_request:
	.ascii "blk.0.ffn_up.weight"
ffn_up_tensor_request_end:

ffn_down_tensor_request:
	.ascii "blk.0.ffn_down.weight"
ffn_down_tensor_request_end:
