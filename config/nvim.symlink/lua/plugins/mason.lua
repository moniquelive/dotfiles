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
		if string.find(diagnostics[1].message, "\n") then
			vim.notify(diagnostics[1].message, "", { render = "minimal", max_width = 0, max_height = 0 })
		else
			vim.api.nvim_echo({ { diagnostics[1].message } }, false, {})
		end
	end,
})
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, { group = grp_diag_hold, command = [[echo ""]] })

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

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
		vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")

		keymaps(bufnr)
		highlighting(client, bufnr)
		if client.name == "solargraph" then
			client.server_capabilities.documentHighlightProvider = false
		end
		--require("notify").notify({ client.name }, "INFO", { title = "LSP Attached" })
	end,
})

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
						require("lspconfig")[server_name].setup({
							capabilities = require("cmp_nvim_lsp").default_capabilities(
								vim.lsp.protocol.make_client_capabilities()
							),
						})
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
					-- ["gopls"] = function()
					--   require("go").setup({ lsp_cfg = false, lsp_codelens = false })
					--   local cfg = require("go.lsp").config()
					--   require("lspconfig").gopls.setup(cfg)
					-- end,
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
					["omnisharp"] = function()
						require("lspconfig").omnisharp.setup({
							cmd = {
								"/usr/local/share/dotnet/dotnet",
								"/Users/cyber/.local/share/nvim/mason/packages/omnisharp/OmniSharp.dll",
							},
						})
					end,
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
						-- "gofumpt",
						-- "goimports-reviser",
						-- "golines",
						-- "gopls",
						-- "gotests",
						-- "gotestsum",
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
