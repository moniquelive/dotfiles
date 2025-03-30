-- vim:set ts=2:

-- vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
vim.diagnostic.config({
	float = { border = "rounded" },
	underline = true,
	virtual_text = true,
	virtual_lines = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = '✘',
			[vim.diagnostic.severity.WARN] = '▲',
			[vim.diagnostic.severity.HINT] = '⚑',
			[vim.diagnostic.severity.INFO] = '»',
		},
	},
})

local function keymaps(bufnr)
	local nmaps = {
		["K"] = function() return vim.lsp.buf.hover({ border = "rounded" }) end,
		["gD"] = vim.lsp.buf.declaration,
		-- grn : ["<F2>"] = vim.lsp.buf.rename,
		["<F4>"] = vim.lsp.codelens.run,
		["gi"] = "<cmd>Telescope lsp_implementations<CR>",
		-- grr :  ["gr"] = "<cmd>Telescope lsp_references<CR>",
		["<leader>d"] = "<cmd>Telescope lsp_definitions<CR>",
		["<leader>e"] = function() vim.diagnostic.open_float({ source = "if_many" }) end,
		["<leader>f"] = function() vim.lsp.buf.format({ async = true }) end,
		["<leader>ih"] = function()
			local curr = not vim.lsp.inlay_hint.is_enabled()
			vim.lsp.inlay_hint.enable(curr)
			vim.notify((curr and "enabled" or "disabled") .. " inlay hints")
		end,
	}
	local opts = { noremap = true, silent = true, buffer = bufnr }
	for key, action in pairs(nmaps) do
		vim.keymap.set("n", key, action, opts)
	end
	-- c-s : vim.keymap.set("i", "<F1>", vim.lsp.buf.signature_help, opts)
	-- gra :  vim.keymap.set({ "i", "n" }, "<a-cr>", vim.lsp.buf.code_action, opts)
end

local au = vim.api.nvim_create_autocmd
local function highlighting(client, bufnr)
	if not client.supports_method('textDocument/documentHighlight') then return end

	vim.cmd([[
              hi! LspReferenceText cterm=bold ctermbg=gray guibg=#404010
              hi! LspReferenceRead cterm=bold ctermbg=green guibg=#104010
              hi! LspReferenceWrite cterm=bold ctermbg=red guibg=#401010
            ]])
	local grp = vim.api.nvim_create_augroup("lsp_document_highlight", {})
	au({ "CursorHold", "CursorHoldI" }, { group = grp, buffer = bufnr, callback = vim.lsp.buf.document_highlight })
	au({ "CursorMoved", "CursorMovedI" }, { group = grp, buffer = bufnr, callback = vim.lsp.buf.clear_references })
end

au("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(args)
		local bufnr = args.buf
		vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
		vim.api.nvim_set_option_value("formatexpr", "v:lua.vim.lsp.formatexpr()", { buf = bufnr })

		keymaps(bufnr)

		local client_id = args.data.client_id
		if not client_id then return end

		local client = vim.lsp.get_client_by_id(client_id)
		if not client then return end

		highlighting(client, bufnr)
		vim.lsp.completion.enable(true, client_id, bufnr, { autotrigger = false })
		vim.keymap.set('i', '<C-Space>', '<cmd>lua vim.lsp.completion.trigger()<cr>')

		vim.notify(string.format("📡️ %s attached", client.name))
		vim.lsp.codelens.refresh()
	end,
})

local function config()
	require("mason").setup()
	local ensure_installed = {
		"gopls",
		"jsonls",
		"lua_ls",
		"omnisharp",
		"powershell_es",
		"ruby_lsp",
		"tailwindcss",
		"yamlls",
		"zls",

		"autopep8",
		"bash-language-server",
		"css-lsp",
		"djlint",
		"dockerfile-language-server",
		"elm-format",
		"elm-language-server",
		"flake8",
		"gitlint",
		"goimports-reviser",
		"golangci-lint-langserver",
		"html-lsp",
		"iferr",
		"isort",
		"luacheck",
		"markdownlint",
		"prettierd",
		"pylint",
		"python-lsp-server",
		"revive",
		"rubocop",
		"ruby-lsp",
		"staticcheck",
		"stylua",
		"typescript-language-server",
		"vim-language-server",
		"yapf",
	}
	require "mason-tool-installer".setup({ ensure_installed = ensure_installed })
	require "mason-lspconfig".setup {
		automatic_installation = false,
		ensure_installed = {},
		handlers = {
			function(server_name)
				require("lspconfig")[server_name].setup {
					capabilities = require('blink.cmp').get_lsp_capabilities()
				}
			end,
		},
	}
	-- VIM 0.11+ LSP config
	local lsp_path = vim.fs.joinpath(vim.fn.stdpath("config"), 'lsp')
	local lsps = {}
	for fname, _ in vim.fs.dir(lsp_path) do
		lsps[#lsps + 1] = fname:match('^([^/]+).lua$')
	end
	-- vim.print(lsps)
	vim.lsp.enable(lsps)
end

return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"saghen/blink.cmp",
			"neovim/nvim-lspconfig",
			"williamboman/mason-lspconfig.nvim",
			{ "WhoIsSethDaniel/mason-tool-installer.nvim", build = ":MasonToolsUpdate" },
		},
		event = { "BufRead", "BufNewFile" },
		cmd = { "Mason", "MasonUpdate" },
		build = ":MasonUpdate",
		config = config,
	},
}
