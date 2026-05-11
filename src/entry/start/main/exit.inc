
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
