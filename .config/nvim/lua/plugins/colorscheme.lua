return {
	{
		"oonamo/ef-themes.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			transparent = true,
			options = { compile = false },
		},
		config = function(_, opts)
			require("ef-themes").setup(opts)
			vim.cmd.colorscheme("ef-cherie")
		end,
	},
}
