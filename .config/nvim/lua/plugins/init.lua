return {
	-- startup
	{ "nvim-lua/plenary.nvim" },
	{ "kyazdani42/nvim-web-devicons" },
	{ "ryanoasis/vim-devicons" },
	{
		"folke/neodev.nvim",
		event = { "BufRead", "BufNewFile" },
		config = true,
	},

	-- tpope goodies
	{ "tpope/vim-characterize", keys = "ga" },
	{ "tpope/vim-commentary", keys = { { "gc", mode = { "v", "n" } } } },
	{ "tpope/vim-fugitive", cmd = { "G", "Git" } },
	{ "tpope/vim-repeat", event = { "BufRead", "BufNewFile" } },
	{ "tpope/vim-rsi", event = "CmdlineEnter" },
	{ "tpope/vim-sleuth", event = { "BufRead", "BufNewFile" } },
	{ "tpope/vim-surround", event = { "BufRead", "BufNewFile" } },
	{ "tpope/vim-unimpaired", keys = { "[", "]", "yo" } },

	-- misc
	{ "wincent/terminus", event = { "BufRead", "BufNewFile" } },
	{ "bronson/vim-trailing-whitespace", event = { "BufRead", "BufNewFile" } },
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufRead", "BufNewFile" },
		main = "ibl",
		opts = {},
	},

	-- coding
	{ "tommcdo/vim-lion", keys = { { "gl", mode = { "v", "n" } }, { "gL", mode = { "v", "n" } } } },
	{ "andymass/vim-matchup", keys = "%" },
	{
		"laytan/tailwind-sorter.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
		ft = { "html", "heex" },
		build = "cd formatter && npm i && npm run build",
		opts = {
			on_save_enabled = true,
		},
	},

	-- colorizer
	{
		"NvChad/nvim-colorizer.lua",
		ft = { "css", "html", "heex" },
		opts = {
			-- filetypes = { "*", "!cmp_menu" },
			user_default_options = { tailwind = true },
		},
	},

	-- Treesitters
	{ "RRethy/nvim-treesitter-endwise" },
	{ "theHamsta/nvim-treesitter-pairs" },

	-- Notifications
	{
		"j-hui/fidget.nvim",
		lazy = false,
		config = function()
			local fidget = require("fidget")
			fidget.setup({})
			vim.notify = fidget.notify
		end,
	},
}
