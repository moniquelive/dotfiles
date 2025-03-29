return {
	cmd = {
		vim.fn.expand("~/.ghcup/bin/haskell-language-server-wrapper"),
		"--lsp"
	},
	filetypes = { 'haskell', 'lhaskell', 'cabal' },
	root_markers = { '.git', 'stack.yaml', 'cabal.project' },
	capabilities = {
		cabalFormattingProvider = "cabalfmt",
		formattingProvider = "ormolu",
	},
}
