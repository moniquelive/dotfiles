return {
	cmd = { "sourcekit-lsp" },
	capabilities = {
		workspace = {
			didChangeWatchedFiles = {
				dynamicRegistration = true,
			},
		},
	},
	filetypes = { "swift", "objc", "objcpp", },
	root_markers = { '.git', '.sourcekit-lsp' },
}
