return {
	-- startup
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "kyazdani42/nvim-web-devicons", lazy = true },
	"ryanoasis/vim-devicons",
	"mhinz/vim-startify",

	-- tpope fandom
	{ "tpope/vim-characterize", keys = "ga" },
	{ "tpope/vim-commentary", keys = { "gc" } },
	{ "tpope/vim-fugitive", cmd = { "G", "Git" } },
	"tpope/vim-repeat",
	"tpope/vim-rsi",
	"tpope/vim-surround",
	{ "tpope/vim-unimpaired", keys = { "[", "]" } },
	"tpope/vim-vinegar",

	-- misc
	"wincent/terminus",
	"bronson/vim-trailing-whitespace",

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
		opts = {
			sections = {
				lualine_c = { "filename", "buffers" },
			},
		},
	},
}
