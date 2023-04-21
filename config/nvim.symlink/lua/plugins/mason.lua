-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
vim.o.updatetime = 250
vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])

local function keymaps(bufnr)
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local opts = { noremap = true, silent = true, buffer = bufnr }
	local k = vim.keymap.set
	k("n", "gD", vim.lsp.buf.declaration, opts)
	k("n", "gd", vim.lsp.buf.definition, opts)
	k("n", "K", vim.lsp.buf.hover, opts)
	--vim.keymap.set("n", "<c-k>", vim.lsp.buf.signature_help, bufopts)
	k("n", "[d", vim.diagnostic.goto_prev, opts)
	k("n", "]d", vim.diagnostic.goto_next, opts)
	-- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	k("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
	-- treesitter-rename: vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, bufopts)
	k("n", "<F3>", vim.lsp.buf.code_action, opts)
	-- vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
	k("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
	k("v", "<leader>frr", [[ <ESC><cmd>lua require("telescope").extensions.refactoring.refactors()<CR> ]], {})
	vim.keymap.set("n", "<leader>f", function()
		vim.lsp.buf.format({ timeout = 15000 })
	end, opts)
	-- vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local function mason_lspconfig_opts()
	return {
		-- The first entry (without a key) will be the default handler
		-- and will be called for each installed server that doesn't have
		-- a dedicated handler.
		function(server_name) -- default handler (optional)
			require("lspconfig")[server_name].setup({
				on_attach = function(client, bufnr)
					-- Enable completion triggered by <c-x><c-o>
					vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
					-- Mappings.
					keymaps(bufnr)
					if client.server_capabilities.documentHighlightProvider then
						vim.cmd([[
              hi! LspReferenceText cterm=bold ctermbg=red guibg=#403040
              hi! LspReferenceRead cterm=bold ctermbg=red guibg=#106010
              hi! LspReferenceWrite cterm=bold ctermbg=red guibg=#601010
            ]])
						local grp = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
						local au = vim.api.nvim_create_autocmd
						au(
							{ "CursorHold", "CursorHoldI" },
							{ group = grp, buffer = bufnr, callback = vim.lsp.buf.document_highlight }
						)
						au(
							{ "CursorMoved", "CursorMovedI" },
							{ group = grp, buffer = bufnr, callback = vim.lsp.buf.clear_references }
						)
					end

					if client.supports_method("textDocument/formatting") then
						local augroup = vim.api.nvim_create_augroup("lsp_document_formatting", { clear = false })
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 15000 })
							end,
						})
					end
				end,
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
	}
end

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
				opts = mason_lspconfig_opts,
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
