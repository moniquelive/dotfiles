return {
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			contrast = "hard",
			transparent_mode = true,
		},
		config = function(_, opts)
			require("gruvbox").setup(opts)
			vim.cmd.colorscheme("gruvbox")
		end,
	},
}
