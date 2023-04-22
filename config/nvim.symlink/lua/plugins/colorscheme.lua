return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			flavor = "mocha",
			show_end_of_buffer = true,
			dim_inactive = { enabled = true, percentage = 0 },
			integrations = { notify = true, treesitter_context = true, ts_rainbow2 = true },
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
