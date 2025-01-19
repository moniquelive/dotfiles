return {
	{
		"folke/trouble.nvim",
		opts = {},
		cmd = "Trouble",
		keys = {
			{ "]t",         "<cmd>Trouble diagnostics next focus=true<cr>" },
			{ "[t",         "<cmd>Trouble diagnostics prev focus=true<cr>" },
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle win.wo.wrap=true focus=true<cr>" },
		},
	},
}
