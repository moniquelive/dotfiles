return {
	"stevearc/oil.nvim",
	opts = {
		keymaps = {
			["<C-v>"] = "actions.select_vsplit",
			["<C-x>"] = "actions.select_split",
		},
	},
	event = "Syntax",
	cmd = "Oil",
	keys = { {
		"-",
		function()
			require("oil").open()
		end,
	} },
}
