return {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	root_markers = { ".git", "package.json" },
	capabilities = {
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true }
			}
		}
	},
	settings = {
		json = {
			-- schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
			provideFormatter = true,
		},
	},
}
