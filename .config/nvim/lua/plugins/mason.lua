-- vim:set ts=2:

-- vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
vim.diagnostic.config({
	float = { border = "rounded" },
	underline = true,
	virtual_text = true,
	virtual_lines = false, -- { current_line = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = '✘',
			[vim.diagnostic.severity.WARN] = '▲',
			[vim.diagnostic.severity.HINT] = '⚑',
			[vim.diagnostic.severity.INFO] = '»',
		},
	},
})

-- grn : ["<F2>"] = vim.lsp.buf.rename,
-- grr : ["gr"] = "<cmd>Telescope lsp_references<CR>",
-- c-s : vim.keymap.set("i", "<F1>", vim.lsp.buf.signature_help, opts)
-- gra : vim.keymap.set({ "i", "n" }, "<a-cr>", vim.lsp.buf.code_action, opts)
local nmaps = {
	["K"] = function() return vim.lsp.buf.hover({ border = "rounded" }) end,
	["gD"] = vim.lsp.buf.declaration,
	["<F4>"] = vim.lsp.codelens.run,
	["gi"] = "<cmd>Telescope lsp_implementations<CR>",
	["<leader>d"] = "<cmd>Telescope lsp_definitions<CR>",
	["<leader>e"] = function() vim.diagnostic.open_float({ source = "if_many" }) end,
	["<leader>f"] = function() vim.lsp.buf.format({ async = true }) end,
	["<leader>ih"] = function()
		local curr = not vim.lsp.inlay_hint.is_enabled()
		vim.lsp.inlay_hint.enable(curr)
		vim.notify((curr and "enabled" or "disabled") .. " inlay hints")
	end,
}

local au = vim.api.nvim_create_autocmd
local function highlighting(client, bufnr)
	if not client:supports_method('textDocument/documentHighlight') then return end

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

		for key, action in pairs(nmaps) do
			vim.keymap.set("n", key, action, { noremap = true, silent = true, buffer = bufnr })
		end

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

return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"saghen/blink.cmp",
			"neovim/nvim-lspconfig",
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				build = ":MasonToolsUpdate",
				cmd = { "MasonToolsClean", "MasonToolsInstall", "MasonToolsUpdate" },
				opts = {
					ensure_installed = {
						"autopep8", "bash-language-server", "css-lsp", "djlint", "dockerfile-language-server",
						"elm-format", "elm-language-server", "flake8", "gitlint", "goimports-reviser",
						"golangci-lint-langserver", "gopls", "html-lsp", "iferr", "isort", "json-lsp",
						"lua-language-server", "luacheck", "markdownlint", "omnisharp", "powershell-editor-services", "prettierd",
						"pylint", "python-lsp-server", "revive", "rubocop", "ruby-lsp",
						"staticcheck", "stylua", "tailwindcss-language-server", "typescript-language-server",
						"vim-language-server", "yaml-language-server", "yapf", "zls",
					}
				}
			},
		},
		event = { "BufRead", "BufNewFile" },
		cmd = { "Mason", "MasonUpdate" },
		build = ":MasonUpdate",
		config = true,
	},
}
