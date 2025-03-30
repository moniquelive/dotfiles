return {
	cmd = { 'gopls' },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { '.git', 'go.mod' },
	init_options = { usePlaceholders = true },
	settings = {
		gopls = {
			completeUnimported = true,
			-- usePlaceholders = true,
			semanticTokens = true,
			experimentalPostfixCompletions = true,
			staticcheck = true,
			analyses = {
				useany = true,
				unusedparams = true,
				shadow = true,
				nilness = true,
				unusedvariable = true,
			},
			-- hints = {
			-- 	rangeVariableTypes = true,
			-- 	parameterNames = true,
			-- 	functionTypeParameters = true,
			-- 	constantValues = true,
			-- 	compositeLiteralTypes = true,
			-- 	compositeLiteralFields = true,
			-- 	assignVariableTypes = true,
			-- },
		},
	},
}
