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
		dependencies = { { "echasnovski/mini.pick", opts = {} } },
		lazy = false,
		config = function() require("rfc").setup() end,
	},
}
