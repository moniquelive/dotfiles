return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lsps = {
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
			}
			vim.lsp.enable(lsps)
		end
	},
}
