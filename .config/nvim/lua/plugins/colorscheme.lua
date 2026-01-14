return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = true,
				show_end_of_buffer = true,
				dim_inactive = { enabled = true },
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
