return {
	{
		"folke/trouble.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		opts = {},
		cmd = "Trouble",
		keys = {
			{ "]t", "<cmd>Trouble diagnostics next focus=true<cr>" },
			{ "[t", "<cmd>Trouble diagnostics prev focus=true<cr>" },
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle focus=true<cr>" },
		},
	},
}
