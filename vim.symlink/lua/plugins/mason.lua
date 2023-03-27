-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
vim.o.updatetime = 250
vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])

local ok, mason = pcall(require, "mason")
if not ok then
	return
end
mason.setup()
require("mason-lspconfig").setup()
require("mason-null-ls").setup({
	-- ensure_installed = nil,
	-- automatic_installation = true,
	automatic_setup = true,
})

local keymaps = function(bufnr)
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	--vim.keymap.set("n", "<c-k>", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
	-- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", bufopts)
	-- treesitter-rename: vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, bufopts)
	vim.keymap.set("n", "<F3>", vim.lsp.buf.code_action, bufopts)
	-- vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
	vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", bufopts)
	vim.keymap.set(
		"v",
		"<leader>frr",
		[[ <ESC><cmd>lua require("telescope").extensions.refactoring.refactors()<CR> ]],
		{}
	)
	vim.keymap.set("n", "<leader>f", function()
		vim.lsp.buf.format({ timeout = 15000 })
	end, bufopts)
	-- vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
end

local on_attach = function(client, bufnr)
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
		local augroup = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
		vim.api.nvim_clear_autocmds({ buffer = bufnr, group = augroup })
		vim.api.nvim_create_autocmd(
			{ "CursorHold", "CursorHoldI" },
			{ group = augroup, buffer = bufnr, callback = vim.lsp.buf.document_highlight }
		)
		vim.api.nvim_create_autocmd(
			{ "CursorMoved", "CursorMovedI" },
			{ group = augroup, buffer = bufnr, callback = vim.lsp.buf.clear_references }
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
end

require("mason-lspconfig").setup_handlers({
	-- The first entry (without a key) will be the default handler
	-- and will be called for each installed server that doesn't have
	-- a dedicated handler.
	function(server_name) -- default handler (optional)
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		require("lspconfig")[server_name].setup({
			on_attach = on_attach,
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
	["hls"] = function()
		-- require("lspconfig").hls.setup({
		-- 	settings = {
		-- 		haskell = {
		-- 			hlintOn = true,
		-- 			formattingProvider = "fourmolu",
		-- 		},
		-- 	},
		-- })
	end,
})

local ok_, null_ls = pcall(require, "null-ls")
if not ok_ then
	return
end
null_ls.setup({
	sources = {
		null_ls.builtins.completion.spell,
		null_ls.builtins.diagnostics.eslint,
		null_ls.builtins.diagnostics.credo,
		null_ls.builtins.diagnostics.golangci_lint,
		null_ls.builtins.formatting.autopep8,
		null_ls.builtins.formatting.elm_format,
		null_ls.builtins.formatting.mix,
		null_ls.builtins.formatting.prettierd,
		null_ls.builtins.formatting.stylua,
	},
	on_attach = on_attach,
})

require("mason-tool-installer").setup({
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
})
