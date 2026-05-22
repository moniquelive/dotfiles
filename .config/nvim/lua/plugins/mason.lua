return {
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonLog", "MasonUninstall", "MasonUninstallAll", "MasonUpdate" },
		build = ":MasonUpdate",
		config = function(_, opts)
			require("mason").setup(opts)
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		build = ":MasonToolsUpdate",
		cmd = {
			"MasonToolsClean",
			"MasonToolsInstall",
			"MasonToolsInstallSync",
			"MasonToolsUpdate",
			"MasonToolsUpdateSync",
		},
		opts = {
			-- stylua: ignore
			ensure_installed = {
				"autopep8", "bash-language-server", "black", "clojure-lsp", "djlint", "dockerfile-language-server",
				"elm-format", "elm-language-server", "expert", "flake8", "gitlint", "goimports-reviser",
				"golangci-lint-langserver", "gopls", "iferr", "isort", "json-lsp",
				"lua-language-server", "markdownlint", "omnisharp", "powershell-editor-services", "prettierd",
				"pylint", "python-lsp-server", "revive", "ruby-lsp", "rubyfmt",
				"staticcheck", "stylua", "tailwindcss-language-server", "tombi",
				"yaml-language-server", "yapf",
			},
		},
	},
}
