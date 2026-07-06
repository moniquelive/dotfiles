local function tools_to_install()
	-- stylua: ignore
	local tools = {
		"autopep8", "bash-language-server", "black", "clojure-lsp", "djlint", "dockerfile-language-server",
		"elm-format", "elm-language-server", "expert", "flake8", "gitlint", "goimports-reviser",
		"golangci-lint-langserver", "gopls", "iferr", "isort", "json-lsp",
		"lua-language-server", "markdownlint", "omnisharp", "powershell-editor-services", "prettierd",
		"pylint", "python-lsp-server", "revive", "ruby-lsp", "rubyfmt",
		"staticcheck", "stylua", "tailwindcss-language-server", "tombi",
		"yaml-language-server", "yapf",
	}

	if vim.uv.os_uname().sysname ~= "FreeBSD" then return tools end

	local unsupported = {
		["clojure-lsp"] = true,
		["elm-format"] = true,
		["expert"] = true,
		["goimports-reviser"] = true,
		["lua-language-server"] = true,
		["omnisharp"] = true,
		["rubyfmt"] = true,
		["stylua"] = true,
		["tombi"] = true,
	}

	return vim.iter(tools):filter(function(tool) return not unsupported[tool] end):totable()
end

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
			ensure_installed = tools_to_install(),
		},
	},
}
