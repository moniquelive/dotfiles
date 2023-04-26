return {
	{
		"luisiacc/gruvbox-baby",
		name = "gruvbox",
		lazy = false,
		priority = 1000,
		config = function()
			vim.o.background = "dark"
			vim.g.gruvbox_baby_background_color = "dark"
			vim.cmd.colorscheme("gruvbox-baby")
		end,
	},
}
