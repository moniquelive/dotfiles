local function init()
	vim.g.haskell_tools = {
		hoogle = {
			mode = "telescope-local",
		},
		tools = {
			repl = { handler = "toggleterm" },
			definition = { hoogle_signature_fallback = true },
			hover = { stylize_markdown = true },
		},
		hls = { -- LSP client options
			on_attach = function(client, _bufnr, ht)
				print("ATTACH", ht.default_settings.haskell)
			end,
			default_settings = {
				haskell = { -- haskell-language-server options
					formattingProvider = "fourmolu",
					plugin = {
						hlint = {
							codeActionsOn = true,
							diagnosticsOn = true,
						},
					},
				},
			},
		},
	}
end

return {
	{
		"mrcjkb/haskell-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "akinsho/toggleterm.nvim" },
		version = "^4", -- Recommended
		init = init,
		ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
	},
}
