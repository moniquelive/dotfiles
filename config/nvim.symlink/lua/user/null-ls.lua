local ok_, null_ls = pcall(require, "null-ls")
if not ok_ then
	return
end

require("mason-null-ls").setup({
	-- ensure_installed = nil,
	-- automatic_installation = true,
	automatic_setup = true,
})

local on_attach = require("user.on-attach-keymaps")

null_ls.setup({
	sources = {
		-- null_ls.builtins.completion.spell,
		null_ls.builtins.diagnostics.eslint,
		null_ls.builtins.diagnostics.credo,
		null_ls.builtins.diagnostics.golangci_lint,
		null_ls.builtins.formatting.autopep8,
		null_ls.builtins.formatting.elm_format,
		null_ls.builtins.formatting.gofumpt,
		null_ls.builtins.formatting.isort,
		null_ls.builtins.formatting.mix,
		null_ls.builtins.formatting.prettierd.with({
			filetypes = { "html", "json", "yaml", "markdown" },
			extra_filetypes = { "toml" },
		}),
		null_ls.builtins.formatting.stylua,
	},
	on_attach = on_attach.on_attach,
})
