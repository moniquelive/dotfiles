return {
	"stevearc/oil.nvim",
	config = {
		keymaps = {
			["<C-v>"] = "actions.select_vsplit",
			["<C-x>"] = "actions.select_split",
		},
	},
	cmd = "Oil",
	keys = { {
		"-",
		function()
			require("oil").open()
		end,
	} },
}
