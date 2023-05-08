return {
	-- startup
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "kyazdani42/nvim-web-devicons", lazy = true },
	"ryanoasis/vim-devicons",
	{ "RRethy/nvim-treesitter-endwise", lazy = true },
	{ "folke/neodev.nvim", config = true, event = { "BufRead", "BufNewFile" } },

	-- tpope goodies
	{ "tpope/vim-characterize", keys = "ga" },
	{ "tpope/vim-commentary", keys = { { "gc", mode = { "v", "n" } } } },
	{ "tpope/vim-fugitive", cmd = { "G", "Git" } },
	{ "tpope/vim-repeat", event = { "BufRead", "BufNewFile" } },
	{ "tpope/vim-rsi", event = "CmdlineEnter" },
	{ "tpope/vim-surround", event = { "BufRead", "BufNewFile" } },
	{ "tpope/vim-unimpaired", keys = { "[", "]", "yo" } },
	{ "tpope/vim-vinegar", event = "VeryLazy" },

	-- misc
	{ "wincent/terminus", event = { "BufRead", "BufNewFile" } },
	{ "bronson/vim-trailing-whitespace", event = { "BufRead", "BufNewFile" } },

	-- coding
	{ "tommcdo/vim-lion", keys = { "gl", "gL" } },
	{ "andymass/vim-matchup", keys = "%" },

	-- Lua Line
	{
		"nvim-lualine/lualine.nvim",
		config = true,
		event = { "BufRead", "BufNewFile" },
		ft = "",
	},

	-- Notifications
	{
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			notify.setup({ fps = 60 })
			vim.notify = notify
		end,
	},
}
