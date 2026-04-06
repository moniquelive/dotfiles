return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufRead", "BufNewFile" },
		init = function()
			-- global config
			vim.lsp.config("*", { root_markers = { ".git" } })
			-- specific ones
			local servers = {
				clangd = {},
				djlint = {},
				dockerls = {},
				elmls = {},
				expert = {},
				fish_lsp = {},
				gopls = {},
				hls = {
					cmd = { "haskell-language-server-wrapper", "--lsp" },
					root_markers = { "hie.yaml", "stack.yaml", "cabal.project", "*.cabal", "package.yaml" },
					on_attach = function(client)
						client.server_capabilities.semanticTokensProvider = nil
					end,
				},
				jsonls = {},
				bashls = {},
				shellcheck = {},

				-- LUA
				lua_ls = {},
				-- luacheck = {},
				-- stylua = {}, -- called by conform.nvim

				-- Microsoft
				omnisharp = {},
				powershell_es = {},

				-- PYTHON
				-- autopep8 = {},
				-- flake8 = {},
				-- isort = {}, -- called by conform.nvim
				pylsp = {},
				pylint = {},
				-- yapf = {},

				-- RUBY
				solargraph = {},

				sourcekit = {},
				tailwindcss = {},
				tombi = {},
				yamlls = {},
				zls = {},
			}
			vim.iter(servers):each(function(server, config)
				vim.lsp.config(server, config)
				vim.lsp.enable(server)
			end)
		end,
	},
}
