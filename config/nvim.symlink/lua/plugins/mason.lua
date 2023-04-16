-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
vim.o.updatetime = 250
vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])

local function config()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

	require("mason-lspconfig").setup_handlers({
		-- The first entry (without a key) will be the default handler
		-- and will be called for each installed server that doesn't have
		-- a dedicated handler.
		function(server_name) -- default handler (optional)
			require("lspconfig")[server_name].setup({
				on_attach = require("user.on-attach-keymaps").on_attach,
				capabilities = capabilities,
			})
		end,
		-- Next, you can provide a dedicated handler for specific servers.
		-- For example, a handler override for the `rust_analyzer`:
		["rust_analyzer"] = function()
			require("rust-tools").setup({})
		end,
		["lua_ls"] = function()
			require("lspconfig").lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" }, -- Get the language server to recognize the `vim` global
						},
					},
				},
			})
		end,
		["yamlls"] = function()
			require("lspconfig").yamlls.setup({
				settings = {
					yaml = {
						schemaStore = {
							url = "https://www.schemastore.org/api/json/catalog.json",
							enable = true,
						},
					},
				},
			})
		end,
		["hls"] = function() end,
		["elixirls"] = function()
			require("lspconfig").elixirls.setup({
				settings = {
					elixirLS = {
						dialyzerEnabled = true,
					},
				},
			})
		end,
		["tailwindcss"] = function()
			require("lspconfig").tailwindcss.setup({
				filetypes = { "html", "elixir", "eelixir", "heex" },
				init_options = {
					userLanguages = { elixir = "html-eex", eelixir = "html-eex", heex = "html-eex" },
				},
				settings = {
					tailwindCSS = {
						experimental = {
							classRegex = { 'class[:]\\s*"([^"]*)"' },
						},
					},
				},
			})
		end,
	})
end

return {
	{
		"williamboman/mason.nvim",
		opts = {},
		build = ":MasonUpdate",
		dependencies = {
			{
				"williamboman/mason-lspconfig.nvim",
				config = config,
				dependencies = { "folke/neodev.nvim", config = true },
			},
			"neovim/nvim-lspconfig",

			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				build = ":MasonToolsUpdate",
				opts = {
					-- a list of all tools you want to ensure are installed upon
					-- start; they should be the names Mason uses for each tool
					ensure_installed = {
						-- { '' , version = '1.8.0.0' }, you can pin a tool to a particular version
						"autopep8",
						"bash-language-server",
						"css-lsp",
						"diagnostic-languageserver",
						"djlint",
						"dockerfile-language-server",
						"elixir-ls",
						"elm-format",
						"elm-language-server",
						"emmet-ls",
						"flake8",
						"gitlint",
						"gofumpt",
						"goimports",
						"golangci-lint-langserver",
						"gopls",
						"gotests",
						"gotestsum",
						"haskell-language-server",
						"html-lsp",
						"iferr",
						"isort",
						"jedi-language-server",
						"json-lsp",
						"lua-language-server",
						"luacheck",
						"markdownlint",
						"prettierd",
						"pylint",
						"python-lsp-server",
						"revive",
						"semgrep",
						"solargraph",
						"standardrb",
						"staticcheck",
						"stylua",
						"tailwindcss-language-server",
						"vim-language-server",
						"yaml-language-server",
						"yamlfmt",
						"yamllint",
						"yapf",
					},
				},
			},
		},
	},
}
