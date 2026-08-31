return {
	{
		"oonamo/ef-themes.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			transparent = true,
			on_highlights = function(_, colors)
				return {
					MatchParen = { fg = colors.fg_main, bg = colors.bg_paren_match },
				}
			end,
			options = { compile = false },
		},
		config = function(_, opts)
			require("ef-themes").setup(opts)
			vim.cmd.colorscheme("ef-cherie")
		end,
	},
}
