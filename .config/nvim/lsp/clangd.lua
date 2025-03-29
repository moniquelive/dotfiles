return {
	cmd = {
		(vim.fn.executable("brew") == 1 and "/opt/homebrew/opt/llvm/bin/clangd" or "clangd"),
		"--background-index",
		"--suggest-missing-includes",
		"--clang-tidy",
		'--offset-encoding=utf-8',
	},
	root_markers = { '.git', '.clangd', 'compile_commands.json' },
	filetypes = { 'c', 'h', 'cpp', 'hpp', 'cxx', 'hxx' },
}
