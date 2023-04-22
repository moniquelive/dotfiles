-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
vim.o.updatetime = 250
vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
local format_timeout = 15000

local function keymaps(bufnr)
	local keys = {
		["gD"] = vim.lsp.buf.declaration,
		["gd"] = vim.lsp.buf.definition,
		["K"] = vim.lsp.buf.hover,
		["[d"] = vim.diagnostic.goto_prev,
		["]d"] = vim.diagnostic.goto_next,
		["gi"] = "<cmd>Telescope lsp_implementations<CR>",
		["<F3>"] = vim.lsp.buf.code_action,
		["gr"] = "<cmd>Telescope lsp_references<CR>",
		["<leader>d"] = "<cmd>Telescope lsp_definitions<CR>",
		["<leader>f"] = function()
			vim.lsp.buf.format({ timeout = format_timeout })
		end,
	}
	for lhs, rhs in pairs(keys) do
		vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, buffer = bufnr })
	end
end

local function highlighting(client, bufnr)
	if client.server_capabilities.documentHighlightProvider then
		vim.cmd([[
              hi! LspReferenceText cterm=bold ctermbg=red guibg=#403040
              hi! LspReferenceRead cterm=bold ctermbg=red guibg=#106010
              hi! LspReferenceWrite cterm=bold ctermbg=red guibg=#601010
            ]])
		local grp = vim.api.nvim_create_augroup("lsp_document_highlight", {})
		local au = vim.api.nvim_create_autocmd
		au({ "CursorHold", "CursorHoldI" }, { group = grp, buffer = bufnr, callback = vim.lsp.buf.document_highlight })
		au({ "CursorMoved", "CursorMovedI" }, { group = grp, buffer = bufnr, callback = vim.lsp.buf.clear_references })
	end
end

local function formatting(client, bufnr)
	if client.supports_method("textDocument/formatting") then
		local grp = vim.api.nvim_create_augroup("lsp_document_formatting", {})
		local au = vim.api.nvim_create_autocmd
		au("BufWritePre", {
			group = grp,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = format_timeout })
			end,
		})
	end
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		vim.api.nvim_buf_set_option(args.buf, "omnifunc", "v:lua.vim.lsp.omnifunc") -- Enable completion triggered by <c-x><c-o>
		keymaps(args.buf)
		highlighting(client, args.buf)
		formatting(client, args.buf)
		if client.name == "lua_ls" then
			client.server_capabilities.settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" }, -- Get the language server to recognize the `vim` global
					},
				},
			}
		end
		if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
			local semantic = client.config.capabilities.textDocument.semanticTokens
			client.server_capabilities.semanticTokensProvider = {
				full = true,
				legend = { tokenModifiers = semantic.tokenModifiers, tokenTypes = semantic.tokenTypes },
				range = true,
			}
		end
	end,
})

return {
	{
		"williamboman/mason.nvim",
		config = true,
		cmd = "Mason",
		build = ":MasonUpdate",
		dependencies = {
			"neovim/nvim-lspconfig",

			{
				"williamboman/mason-lspconfig.nvim",
				opts = {
					-- The first entry (without a key) will be the default handler
					-- and will be called for each installed server that doesn't have
					-- a dedicated handler.
					function(server_name) -- default handler (optional)
						require("lspconfig")[server_name].setup({
							capabilities = require("cmp_nvim_lsp").default_capabilities(
								vim.lsp.protocol.make_client_capabilities()
							),
						})
					end,
					-- Next, you can provide a dedicated handler for specific servers.
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
							cmd = { vim.fn.expand("~/.elixir-ls/language_server.sh") },
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
					["powershell_es"] = function()
						require("lspconfig").powershell_es.setup({
							bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services/",
						})
					end,
				},
				config = function(_, opts)
					require("mason-lspconfig").setup_handlers(opts)
				end,
			},

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
						"gopls",
						"gotests",
						"gotestsum",
						"haskell-language-server",
						"html-lsp",
						"iferr",
						"isort",
						"json-lsp",
						"lua-language-server",
						"luacheck",
						"markdownlint",
						"prettierd",
						"pylint",
						"python-lsp-server",
						"revive",
						"solargraph",
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
