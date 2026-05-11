
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
