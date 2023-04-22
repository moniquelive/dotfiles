local function opts()
	local null_ls = require("null-ls")
	return {
		sources = {
			null_ls.builtins.completion.spell,
			null_ls.builtins.diagnostics.eslint,
			null_ls.builtins.diagnostics.credo,
			-- null_ls.builtins.diagnostics.semgrep,
			null_ls.builtins.formatting.autopep8,
			null_ls.builtins.formatting.elm_format,
			--null_ls.builtins.formatting.gofumpt,
			null_ls.builtins.formatting.isort,
			null_ls.builtins.formatting.mix,
			null_ls.builtins.formatting.prettierd.with({
				filetypes = { "html", "json", "yaml", "markdown" },
				extra_filetypes = { "toml" },
			}),
			null_ls.builtins.formatting.stylua,
		},
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
