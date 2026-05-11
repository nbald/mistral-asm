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
	.ascii "RMSNorm/query/key/value output slices plus output descriptor "
	.ascii "lookup, context smoke, output matvec slice, and "
	.ascii "post-attention residual output slice plus FFN RMSNorm, "
	.ascii "gate/up matvec, SwiGLU output slices, FFN down "
	.ascii "matvec output slice, post-FFN residual output slice, "
	.ascii "and layer-3 attention RMSNorm descriptor lookup/output "
	.ascii "slice plus query descriptor lookup/matvec output slice "
	.ascii "and key descriptor lookup/matvec output slice plus "
	.ascii "value descriptor lookup/matvec output slice plus "
	.ascii "output descriptor lookup/context output slice and "
	.ascii "output matvec slice, post-attention residual slice, "
	.ascii "FFN RMSNorm slice, FFN gate matvec slice, and "
	.ascii "FFN up matvec slice plus FFN SwiGLU activation slice "
	.ascii "and FFN down matvec output slice plus post-FFN residual "
	.ascii "output slice plus layer-4 attention RMSNorm descriptor "
	.ascii "lookup/output slice and query/key descriptor lookup plus "
	.ascii "query matvec output slice and key matvec status.\n"
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

layer2_attn_k_tensor_request:
	.ascii "blk.2.attn_k.weight"
layer2_attn_k_tensor_request_end:

layer2_attn_v_tensor_request:
	.ascii "blk.2.attn_v.weight"
layer2_attn_v_tensor_request_end:

layer2_attn_output_tensor_request:
	.ascii "blk.2.attn_output.weight"
layer2_attn_output_tensor_request_end:

layer2_ffn_norm_tensor_request:
	.ascii "blk.2.ffn_norm.weight"
layer2_ffn_norm_tensor_request_end:

layer2_ffn_gate_tensor_request:
	.ascii "blk.2.ffn_gate.weight"
layer2_ffn_gate_tensor_request_end:

layer2_ffn_up_tensor_request:
	.ascii "blk.2.ffn_up.weight"
layer2_ffn_up_tensor_request_end:

layer2_ffn_down_tensor_request:
	.ascii "blk.2.ffn_down.weight"
layer2_ffn_down_tensor_request_end:
