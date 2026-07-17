return {
	{
		"echasnovski/mini.nvim",
		version = false,
		event = "VeryLazy",
		config = function() require("config.mini").setup() end,
	},
	{
		"moniquelive/rfc.nvim",
		dependencies = { "echasnovski/mini.nvim" },
	},
	{
		"moniquelive/man.nvim",
		dependencies = { "echasnovski/mini.nvim" },
	},
}
