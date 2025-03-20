local function init()
	vim.g.haskell_tools = {
		tools = {
			repl = { handler = "toggleterm", prefer = "cabal" },
			definition = { hoogle_signature_fallback = true },
			hover = { stylize_markdown = true },
			hoogle = { mode = "telescope-local" }, -- "auto"|"telescope-local"|"telescope-web"|"browser"
		},
		hls = {                               -- LSP client options
			default_settings = {
				haskell = {                       -- haskell-language-server options
					formattingProvider = "fourmolu",
					hlintOn = true,
					plugin = {
						hlint = {
							codeActionsOn = true,
							diagnosticsOn = true,
						},
					},
				},
			},
			-- on_attach = function(_ --[[client]], bufnr, ht)
			-- 	local opts = { noremap = true, silent = true, buffer = bufnr, }
			-- 	vim.keymap.set('n', '<leader>ea', ht.lsp.buf_eval_all, opts)
			-- 	-- vim.print(ht)
			-- 	-- print("ATTACH", ht.default_settings.haskell)
			-- end,
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
