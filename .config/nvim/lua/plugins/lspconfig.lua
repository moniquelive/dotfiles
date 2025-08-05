return {
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			vim.lsp.config('*', {
				root_markers = { '.git' },
			})
			vim.lsp.config("lua_ls", {
				settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("", true) } } }
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
				"rubocop",
				"sourcekit",
				"tailwindcss",
				"yamlls",
				"zls",
			})
		end
	},
}
