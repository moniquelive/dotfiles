return {
	"williamboman/mason.nvim",
	dependencies = {
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			build = ":MasonToolsUpdate",
			cmd = { "MasonToolsClean", "MasonToolsInstall", "MasonToolsUpdate" },
			opts = {
				-- stylua: ignore
				ensure_installed = {
					"autopep8", "bash-language-server", "css-lsp", "djlint", "dockerfile-language-server",
					"elm-format", "elm-language-server", "expert", "flake8", "gitlint", "goimports-reviser",
					"golangci-lint-langserver", "gopls", "html-lsp", "iferr", "isort", "json-lsp",
					"lua-language-server", "markdownlint", "powershell-editor-services", "prettierd",
					"pylint", "python-lsp-server", "revive",
					"solargraph", "staticcheck", "stylua", "tailwindcss-language-server", "tombi", "typescript-language-server",
					"vim-language-server", "yaml-language-server", "yapf", -- "zls",
				},
			},
		},
	},
	event = "VeryLazy",
	cmd = { "Mason", "MasonUpdate" },
	build = ":MasonUpdate",
	config = function(_, opts) require("mason").setup(opts) end,
}
