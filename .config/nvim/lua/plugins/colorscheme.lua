return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		priority = 1000,
		lazy = false,
		opts = {
			variant = "moon",
			dark_variant = "moon",
			styles = { transparency = true },
		},
		config = function(_, opts)
			require("rose-pine").setup(opts)
			vim.cmd.colorscheme("rose-pine-moon")
		end,
	},
}
