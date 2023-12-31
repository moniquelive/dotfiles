-- vim:set ts=2:
-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
vim.o.updatetime = 250
-- vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
vim.diagnostic.config({
	float = { border = "single" },
	underline = false,
	virtual_text = false,
	virtual_lines = false,
})
local format_timeout = 15000

-- vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
local grp_diag_hold = vim.api.nvim_create_augroup("cursor_hold_diagnostic", {})
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	group = grp_diag_hold,
	callback = function()
		local diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
		if not next(diagnostics) then
			return
		end
		-- vim.print(diagnostics[1])
		local msg = vim.split(diagnostics[1].message, "\n")
		vim.api.nvim_echo({ { string.sub(msg[1], 1, vim.v.echospace) } }, false, {})
	end,
})
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, { group = grp_diag_hold, command = [[echo ""]] })

vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
	config = config or {}
	config.focus_id = ctx.method
	if not (result and result.contents) then
		return
	end
	local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
	markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
	if vim.tbl_isempty(markdown_lines) then
		return
	end
	return vim.lsp.util.open_floating_preview(markdown_lines, "markdown", config)
end

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
		["<leader>e"] = function()
			vim.diagnostic.open_float({ source = "if_many" })
		end,
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

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
		vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")

		keymaps(bufnr)
		highlighting(client, bufnr)
		--require("notify").notify({ client.name }, "INFO", { title = "LSP Attached" })
	end,
})

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
return {
	{
		"williamboman/mason.nvim",
		config = true,
		cmd = "Mason",
		build = ":MasonUpdate",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"neovim/nvim-lspconfig",
			{
				"williamboman/mason-lspconfig.nvim",
				opts = {
					-- The first entry (without a key) will be the default handler
					-- and will be called for each installed server that doesn't have
					-- a dedicated handler.
					function(server_name) -- default handler (optional)
						require("lspconfig")[server_name].setup({ capabilities = capabilities })
					end,
					-- Next, you can provide a dedicated handler for specific servers.
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
					["clangd"] = function()
						require("lspconfig").clangd.setup({
							cmd = {
								"/opt/homebrew/opt/llvm/bin/clangd",
								"--offset-encoding=utf-16",
								"--background-index",
								"--clang-tidy",
							},
						})
					end,
					["hls"] = function()
						require("lspconfig").hls.setup({
							settings = {
								haskell = {
									formattingProvider = "fourmolu",
								},
							},
						})
					end,
					["gopls"] = function()
						require("lspconfig").gopls.setup({
							settings = {
								gopls = {
									completeUnimported = true,
									usePlaceholders = true,
									semanticTokens = true,
									experimentalPostfixCompletions = true,
									staticcheck = true,
									analyses = {
										unusedparams = true,
										shadow = true,
										nilness = true,
										unusedvariable = true,
									},
								},
							},
						})
					end,
					["jsonls"] = function()
						require("lspconfig").jsonls.setup({
							capabilities = vim.tbl_extend(
								"force",
								capabilities,
								{ textDocument = { completion = { completionItem = { snippetSupport = true } } } }
							),
							settings = {
								json = {
									schemas = require("schemastore").json.schemas(),
									validate = { enable = true },
								},
							},
						})
					end,
					["yamlls"] = function()
						require("lspconfig").yamlls.setup({
							capabilities = vim.tbl_extend(
								"force",
								capabilities,
								{ textDocument = { completion = { completionItem = { snippetSupport = true } } } }
							),
							settings = {
								yaml = {
									schemaStore = {
										url = "",
										enable = false,
									},
									schemas = require("schemastore").yaml.schemas(),
								},
							},
						})
					end,
					["omnisharp"] = function()
						require("lspconfig").omnisharp.setup({
							cmd = {
								"/usr/local/share/dotnet/dotnet",
								"/Users/cyber/.local/share/nvim/mason/packages/omnisharp/OmniSharp.dll",
							},
						})
					end,
					["powershell_es"] = function()
						require("lspconfig").powershell_es.setup({
							bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services/",
						})
					end,
					["elixirls"] = function()
						require("lspconfig").elixirls.setup({
							-- cmd = { vim.fn.expand("~/.elixir-ls/language_server.sh") },
							-- cmd = { vim.fn.expand("/opt/homebrew/bin/elixir-ls") },
							cmd = { vim.fn.expand("~/.local/share/nvim/mason/packages/elixir-ls/language_server.sh") },
							settings = {
								elixirLS = {
									dialyzerEnabled = false,
									fetchDeps = false,
								},
							},
						})
					end,
					["emmet_ls"] = function()
						require("lspconfig").emmet_ls.setup({
							capabilities = capabilities,
							filetypes = { "html", "css", "heex", "eelixir" },
						})
					end,
					["tsserver"] = function()
						require("lspconfig").tsserver.setup({
							capabilities = capabilities,
						})
					end,
					["tailwindcss"] = function()
						require("lspconfig").tailwindcss.setup({
							capabilities = capabilities,
							init_options = {
								userLanguages = {
									elixir = "html-eex",
									eelixir = "html-eex",
									heex = "html-eex",
								},
							},
							root_dir = require("lspconfig.util").root_pattern(
								"tailwind.config.js",
								"tailwind.config.cjs",
								"tailwind.config.mjs",
								"tailwind.config.ts",
								"postcss.config.js",
								"postcss.config.cjs",
								"postcss.config.mjs",
								"postcss.config.ts",
								"package.json",
								"node_modules",
								"mix.exs",
								".git"
							),
							settings = {
								experimental = {
									classRegex = {
										[[class= "([^"]*)]],
										[[class: "([^"]*)]],
										'~H""".*class="([^"]*)".*"""',
										'~F""".*class="([^"]*)".*"""',
									},
								},
							},
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
						"goimports-reviser",
						"golangci-lint-langserver",
						"golines",
						"gopls",
						"gotests",
						"gotestsum",
						--"haskell-language-server",
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
						"ruby-lsp",
						"rubyfmt",
						"standardrb",
						"staticcheck",
						"stylua",
						"tailwindcss-language-server",
						"typescript-language-server",
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
