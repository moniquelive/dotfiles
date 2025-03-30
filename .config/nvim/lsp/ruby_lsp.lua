return {
	cmd = { "ruby-lsp" },
	filetypes = { "ruby", "eruby" },
	root_markers = { ".git", "Gemfile", "Gemfile.lock" },
	init_options = {
		rubyVersionManager = "mise",
		formatter = "rubocop",
		linters = { "rubocop" },
		enabledFeatures = {
			codeActions = true,
			codeLens = true,
			completion = true,
			definition = true,
			diagnostics = true,
			documentHighlights = true,
			documentSymbols = true,
			foldingRanges = true,
			formatting = true,
			hover = true,
			-- inlayHint = true,
			onTypeFormatting = true,
			selectionRanges = true,
			semanticHighlighting = true,
			signatureHelp = true,
		},
		featuresConfiguration = {
			inlayHint = {
				implicitHashValue = true,
				implicitRescue = true,
			},
		},
	},
}
