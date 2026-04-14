return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim" },
		ft = {
			"bash",
			"c",
			"cabal",
			"cpp",
			"cs",
			"css",
			"dockerfile",
			"elixir",
			"elm",
			"fish",
			"go",
			"gomod",
			"gowork",
			"haskell",
			"heex",
			"html",
			"javascript",
			"javascriptreact",
			"json",
			"jsonc",
			"lhaskell",
			"lua",
			"ps1",
			"psm1",
			"python",
			"ruby",
			"sass",
			"scss",
			"sh",
			"svelte",
			"swift",
			"toml",
			"typescript",
			"typescriptreact",
			"vue",
			"yaml",
			"zig",
			"zsh",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(args)
					local bufnr = args.buf
					vim.lsp.codelens.enable(true, { bufnr = bufnr })

					local opts = { noremap = true, silent = true, buffer = bufnr }
					local k = vim.keymap.set
					-- grr : ["gr"] = "<cmd>Telescope lsp_references<CR>",
					-- c-s : vim.keymap.set("i", "<F1>", vim.lsp.buf.signature_help, opts)
					-- k("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
					-- k("n", "<leader>d", "<cmd>Telescope lsp_definitions<CR>", opts)
					k("n", "K", vim.lsp.buf.hover, opts)
					k("n", "gD", vim.lsp.buf.declaration, opts)
					k("n", "<F4>", vim.lsp.codelens.run, opts)
					-- k("n", "<leader>e", function() vim.diagnostic.open_float({ source = "if_many" }) end, opts)
					local client_id = args.data.client_id
					if not client_id then return end
					local client = vim.lsp.get_client_by_id(client_id)
					if not client then return end
					vim.notify(string.format("📡️ %s attached", client.name))
				end,
			})

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
					on_attach = function(client) client.server_capabilities.semanticTokensProvider = nil end,
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
