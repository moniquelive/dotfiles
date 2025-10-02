local servers = {
	clangd = {},
	djlint = {},
	dockerls = {},
	expert = {},
	fish_lsp = {},
	ghcide = {},
	gopls = {},
	hls = {},
	jsonls = {},

	-- LUA
	lua_ls = {},
	-- luacheck = {},
	-- stylua = {},

	-- Microsoft
	omnisharp = {},
	powershell_es = {},

	-- PYTHON
	-- autopep8 = {},
	-- flake8 = {},
	pylsp = {},
	pylint = {},
	-- yapf = {},

	-- RUBY
	ruby_lsp = {},
	rubocop = {},

	sourcekit = {},
	tailwindcss = {},
	yamlls = {},
	zls = {},
}
return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		lazy = false,
		config = function()
			-- global config
			vim.lsp.config("*", { root_markers = { ".git" } })
			-- specific ones
			for server, config in pairs(servers) do
				config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
				vim.lsp.config(server, { settings = config })
				vim.lsp.enable(server)
			end
		end,
	},
}
