return {
	-- startup
	"ryanoasis/vim-devicons",
	"kyazdani42/nvim-web-devicons",
	"mhinz/vim-startify",

	-- tpope fandom
	"tpope/vim-characterize",
	"tpope/vim-commentary",
	"tpope/vim-fugitive",
	"tpope/vim-repeat",
	"tpope/vim-rsi",
	"tpope/vim-surround",
	"tpope/vim-unimpaired",
	"tpope/vim-vinegar",

	-- misc
	"wincent/terminus",
	"bronson/vim-trailing-whitespace",

	-- coding
	"AndrewRadev/splitjoin.vim",
	"tommcdo/vim-lion",
	"andymass/vim-matchup",
	"nvim-lua/plenary.nvim",

	-- Notifications
	{
		"rcarriga/nvim-notify",
		config = function()
			vim.notify = require("notify")
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
