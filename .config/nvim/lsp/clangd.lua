return {
	cmd = {
		"clangd",
		"--background-index",
		"--suggest-missing-includes",
		"--clang-tidy",
		'--offset-encoding=utf-8',
	},
	root_markers = { '.git', '.clangd', 'compile_commands.json' },
	filetypes = { 'c', 'h', 'cpp', 'hpp', 'cxx', 'hxx' },
}
