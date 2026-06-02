return {
	{
		"echasnovski/mini.nvim",
		version = false,
		event = "VeryLazy",
		config = function() require("config.mini").setup() end,
	},
	{
		"moniquelive/rfc.nvim",
		branch = "mini-pick-conversion",
		dependencies = { "echasnovski/mini.nvim" },
	},
	{
		"moniquelive/man.nvim",
		dir = "/Users/cyber/prj/lua/man.nvim",
		dependencies = { "echasnovski/mini.nvim" },
	},
}
