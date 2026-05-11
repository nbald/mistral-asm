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
	.ascii "FFN RMSNorm, gate/up matvec, SwiGLU/down output slices, "
	.ascii "post-FFN residual output slice, and layer-2 attention "
	.ascii "RMSNorm/query output slices.\n"
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

layer1_ffn_down_tensor_request:
	.ascii "blk.1.ffn_down.weight"
layer1_ffn_down_tensor_request_end:

layer2_attn_norm_tensor_request:
	.ascii "blk.2.attn_norm.weight"
layer2_attn_norm_tensor_request_end:

layer2_attn_q_tensor_request:
	.ascii "blk.2.attn_q.weight"
layer2_attn_q_tensor_request_end:
