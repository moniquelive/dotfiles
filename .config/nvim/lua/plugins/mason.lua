local function tools_to_install()
	-- stylua: ignore
	local tools = {
		"bash-language-server", "black", "clojure-lsp", "dockerfile-language-server",
		"elm-language-server", "expert", "golangci-lint", "golangci-lint-langserver", "gopls",
		"isort", "json-lsp", "lua-language-server", "omnisharp", "powershell-editor-services",
		"prettierd", "pylint", "python-lsp-server", "ruby-lsp", "rubyfmt", "shfmt", "stylua",
		"tailwindcss-language-server", "tombi", "yaml-language-server",
	}

	if vim.uv.os_uname().sysname ~= "FreeBSD" then return tools end

	local unsupported = {
		["clojure-lsp"] = true,
		["expert"] = true,
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
		config = function(_, opts) require("mason").setup(opts) end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		build = ":MasonToolsUpdate",
		lazy = false,
		cmd = {
			"MasonToolsClean",
			"MasonToolsInstall",
			"MasonToolsInstallSync",
			"MasonToolsUpdate",
			"MasonToolsUpdateSync",
		},
		opts = {
			debounce_hours = 24,
			ensure_installed = tools_to_install(),
			run_on_start = true,
			start_delay = 3000,
		},
	},
}
