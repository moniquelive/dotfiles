return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
		config = function()
			vim.o.background = "dark"
			vim.cmd.colorscheme("rose-pine-moon")
		end,
	},
}
