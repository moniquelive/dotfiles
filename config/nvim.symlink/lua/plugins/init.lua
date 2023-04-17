return {
	-- startup
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "kyazdani42/nvim-web-devicons", lazy = true },
	"ryanoasis/vim-devicons",
	"mhinz/vim-startify",
	{ "folke/neodev.nvim", config = true, event = "BufRead" },

	-- tpope fandom
	{ "tpope/vim-characterize", keys = "ga" },
	{ "tpope/vim-commentary", keys = { { "gc", mode = { "v", "n" } } } },
	{ "tpope/vim-fugitive", cmd = { "G", "Git" } },
	{ "tpope/vim-repeat", event = "BufRead" },
	{ "tpope/vim-rsi", event = "CmdlineEnter" },
	{ "tpope/vim-surround", event = "BufRead" },
	{ "tpope/vim-unimpaired", keys = { "[", "]" } },
	{ "tpope/vim-vinegar", event = "VimEnter" },

	-- misc
	{ "wincent/terminus", event = "BufRead" },
	{ "bronson/vim-trailing-whitespace", event = "BufRead" },

	-- coding
	{ "AndrewRadev/splitjoin.vim", keys = { "<leader>s", "<leader>j" } },
	{ "tommcdo/vim-lion", keys = { "gl", "gL" } },
	{ "andymass/vim-matchup", keys = "%" },

	-- Notifications
	{
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			notify.setup({ fps = 60 })
			vim.notify = notify
		end,
	},

	-- Lua Line
	{
		"nvim-lualine/lualine.nvim",
		event = "BufRead",
		opts = {
			sections = {
				lualine_c = { "filename", "buffers" },
			},
		},
	},
}
