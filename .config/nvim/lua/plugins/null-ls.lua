local function opts()
	local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
	local null_ls = require("null-ls")
	return {
		sources = {
			null_ls.builtins.completion.spell,
			null_ls.builtins.diagnostics.eslint,
			null_ls.builtins.diagnostics.credo,
			null_ls.builtins.diagnostics.revive,
			null_ls.builtins.diagnostics.luacheck.with({
				extra_args = { "--globals vim" },
			}),
			null_ls.builtins.formatting.autopep8,
			null_ls.builtins.formatting.elm_format,
			null_ls.builtins.formatting.stylua,
			null_ls.builtins.formatting.isort,
			null_ls.builtins.formatting.mix,
			null_ls.builtins.formatting.fourmolu,
			null_ls.builtins.formatting.golines.with({
				extra_args = {
					"--max-len=180",
					"--base-formatter=gofumpt",
				},
			}),
			null_ls.builtins.formatting.prettierd.with({
				filetypes = { "html", "json", "yaml", "markdown" },
				extra_filetypes = { "toml" },
			}),
			require("go.null_ls").gotest(),
			require("go.null_ls").gotest_action(),
			--require("go.null_ls").golangci_lint(),
		},
		on_attach = function(client, bufnr)
			if client.supports_method("textDocument/formatting") then
				vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = augroup,
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({ bufnr = bufnr })
					end,
				})
			end
		end,
		default_timeout = 15000,
	}
end

return {
	{
		"jose-elias-alvarez/null-ls.nvim",
		opts = opts,
		event = { "BufRead", "BufNewFile" },
		dependencies = { "jayp0521/mason-null-ls.nvim", opts = { automatic_setup = true } },
	},
}
