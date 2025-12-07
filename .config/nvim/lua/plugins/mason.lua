return {
	"williamboman/mason.nvim",
	dependencies = {
		"saghen/blink.cmp",
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			build = ":MasonToolsUpdate",
			cmd = { "MasonToolsClean", "MasonToolsInstall", "MasonToolsUpdate" },
			opts = {
				-- stylua: ignore
				ensure_installed = {
					"autopep8", "bash-language-server", "css-lsp", "djlint", "dockerfile-language-server",
					"elm-format", "elm-language-server", "expert", "flake8", "gitlint", "goimports-reviser",
					"golangci-lint-langserver", "gopls", "html-lsp", "iferr", "isort", "json-lsp",
					"lua-language-server", "luacheck", "markdownlint", "powershell-editor-services", "prettierd",
					"pylint", "python-lsp-server", "revive", "rubocop", "ruby-lsp",
					"staticcheck", "stylua", "tailwindcss-language-server", "typescript-language-server",
					"vim-language-server", "yaml-language-server", "yapf", -- "zls",
				},
			},
		},
	},
	event = { "BufRead", "BufNewFile" },
	cmd = { "Mason", "MasonUpdate" },
	build = ":MasonUpdate",
	config = true,
	init = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(args)
				vim.lsp.codelens.refresh()

				local bufnr = args.buf
				local opts = { noremap = true, silent = true, buffer = bufnr }
				local k = vim.keymap.set
				-- grr : ["gr"] = "<cmd>Telescope lsp_references<CR>",
				-- c-s : vim.keymap.set("i", "<F1>", vim.lsp.buf.signature_help, opts)
				-- k("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
				-- k("n", "<leader>d", "<cmd>Telescope lsp_definitions<CR>", opts)
				k("i", "<C-Space>", "<cmd>lua vim.lsp.completion.trigger()<cr>")
				k("n", "K", vim.lsp.buf.hover, opts)
				k("n", "gD", vim.lsp.buf.declaration, opts)
				k("n", "<F4>", vim.lsp.codelens.run, opts)
				-- k("n", "<leader>e", function() vim.diagnostic.open_float({ source = "if_many" }) end, opts)
				k("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
				local client_id = args.data.client_id
				if not client_id then return end
				local client = vim.lsp.get_client_by_id(client_id)
				if not client then return end
				vim.notify(string.format("📡️ %s attached", client.name))
			end,
		})
	end,
}
