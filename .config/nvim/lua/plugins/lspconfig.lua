return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.lsp.config('*', {
				root_markers = { '.git' },
			})
			vim.lsp.config("elixirls", {
				cmd = { vim.fn.expand("~/.local/share/mise/installs/elixir-ls/latest/language_server.sh") }
			})
			vim.lsp.enable({
				"clangd",
				"elixirls",
				"fish_lsp",
				"ghcide",
				"gopls",
				"hls",
				"jsonls",
				"lua_ls",
				"omnisharp",
				"powershell_es",
				"ruby_lsp",
				"sourcekit",
				"tailwindcss",
				"yamlls",
				"zls",
			})
		end
	},
}
