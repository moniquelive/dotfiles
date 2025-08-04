-- vim:set ts=2:

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

-- grr : ["gr"] = "<cmd>Telescope lsp_references<CR>",
-- c-s : vim.keymap.set("i", "<F1>", vim.lsp.buf.signature_help, opts)
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

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(args)
		vim.lsp.codelens.refresh()

		local bufnr = args.buf

		for k, v in pairs(nmaps) do
			vim.keymap.set("n", k, v, { noremap = true, silent = true, buffer = bufnr })
		end
		vim.keymap.set('i', '<C-Space>', '<cmd>lua vim.lsp.completion.trigger()<cr>')

		local client_id = args.data.client_id
		if not client_id then return end

		-- we use blink.cmp
		vim.lsp.completion.enable(false, client_id, bufnr, { autotrigger = false })

		local client = vim.lsp.get_client_by_id(client_id)
		if not client then return end

		vim.notify(string.format("📡️ %s attached", client.name))
	end,
})

return {
	"williamboman/mason.nvim",
	dependencies = {
		"saghen/blink.cmp",
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
}
