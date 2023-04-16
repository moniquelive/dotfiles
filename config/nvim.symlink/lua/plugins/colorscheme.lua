return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			vim.o.background = "dark" -- for the dark version
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
