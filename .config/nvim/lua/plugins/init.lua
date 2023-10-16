return {
	-- startup
	{ "nvim-lua/plenary.nvim" },
	{ "kyazdani42/nvim-web-devicons" },
	{ "ryanoasis/vim-devicons" },
	{ "RRethy/nvim-treesitter-endwise" },
	{
		"folke/neodev.nvim",
		config = true,
		event = { "BufRead", "BufNewFile" },
	},

	-- tpope goodies
	{ "tpope/vim-characterize", keys = "ga" },
	{ "tpope/vim-commentary", keys = { { "gc", mode = { "v", "n" } } } },
	{ "tpope/vim-fugitive", cmd = { "G", "Git" } },
	{ "tpope/vim-repeat", event = { "BufRead", "BufNewFile" } },
	{ "tpope/vim-rsi", event = "CmdlineEnter" },
	{ "tpope/vim-surround", event = { "BufRead", "BufNewFile" } },
	{ "tpope/vim-unimpaired", keys = { "[", "]", "yo" } },

	-- misc
	{ "wincent/terminus", event = { "BufRead", "BufNewFile" } },
	{ "bronson/vim-trailing-whitespace", event = { "BufRead", "BufNewFile" } },
	{ "lukas-reineke/indent-blankline.nvim", event = { "BufRead", "BufNewFile" } },

	-- coding
	{ "tommcdo/vim-lion", keys = { { "gl", mode = { "v", "n" } }, { "gL", mode = { "v", "n" } } } },
	{ "andymass/vim-matchup", keys = "%" },
	{
		"simrat39/symbols-outline.nvim",
		config = true,
		keys = {
			{ "<leader>o", "<cmd>SymbolsOutline<cr>" },
		},
	},

	-- Lua Line
	{
		"nvim-lualine/lualine.nvim",
		event = { "BufRead", "BufNewFile" },
		config = true,
		opts = {
			sections = {
				lualine_c = { { "filename", file_status = true, path = 1 } },
			},
		},
		-- opts = {
		-- 	sections = {
		-- 		lualine_x = {
		-- 			{
		-- 				require("lazy.status").updates,
		-- 				cond = require("lazy.status").has_updates,
		-- 				color = { fg = "#ff9e64" },
		-- 			},
		-- 		},
		-- 	},
		-- },
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

	-- 	{
	-- 		"roobert/tailwindcss-colorizer-cmp.nvim",
	-- 		ft = { "css", "html", "heex" },
	-- 		opts = { color_square_width = 2 },
	-- 		config = true,
	-- 	},

	-- json schema store
	{ "b0o/schemastore.nvim" },

	-- Notifications
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		config = function()
			local notify = require("notify")
			notify.setup({ fps = 60, render = "wrapped-compact", top_down = false })
			vim.notify = notify
		end,
	},
}
