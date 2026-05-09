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
		event = "VeryLazy",
		config = function() require("rfc").setup() end,
	},
}
