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
					"autopep8", "bash-language-server", "djlint", "dockerfile-language-server",
					"elm-format", "elm-language-server", "expert", "flake8", "gitlint", "goimports-reviser",
					"golangci-lint-langserver", "gopls", "iferr", "isort", "json-lsp",
					"lua-language-server", "markdownlint", "omnisharp", "powershell-editor-services", "prettierd",
					"pylint", "python-lsp-server", "revive",
					"solargraph", "staticcheck", "stylua", "tailwindcss-language-server", "tombi",
					"yaml-language-server", "yapf", -- "zls",
				},
			},
		},
	},
	event = "VeryLazy",
	cmd = { "Mason", "MasonUpdate" },
	build = ":MasonUpdate",
	config = function(_, opts) require("mason").setup(opts) end,
}
