return {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
	root_markers = { ".git" },
	capabilities = {
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true
				}
			}
		}
	},
	settings = {
		yaml = {
			schemaStore = { url = "", enable = false },
			-- schemas = require("schemastore").yaml.schemas(),
		},
	},
}
