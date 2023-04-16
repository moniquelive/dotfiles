return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			vim.o.background = "dark" -- for the dark version
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
