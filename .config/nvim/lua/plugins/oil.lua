return {
	{
		"stevearc/oil.nvim",
		opts = {
			keymaps = {
				["q"] = "actions.close",
				["<C-v>"] = "actions.select_vsplit",
				["<C-x>"] = "actions.select_split",
				["<C-l>"] = false,
				["<C-h>"] = false,
			},
		},
		event = "Syntax",
		cmd = "Oil",
		keys = function()
			return {
				{ "-", require("oil").open },
			}
		end,
	},
}
