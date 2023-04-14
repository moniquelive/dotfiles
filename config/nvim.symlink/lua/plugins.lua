local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- startup
	"ryanoasis/vim-devicons",
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

	-- airline
	"kyazdani42/nvim-web-devicons",
	"nvim-lualine/lualine.nvim",

	-- Notifications
	"rcarriga/nvim-notify",

	-- Refactoring
	"ThePrimeagen/refactoring.nvim",

	-- Haskell
	"mrcjkb/haskell-tools.nvim",

	-- Better Terminal
	"akinsho/toggleterm.nvim",

	-- Tree
	{ "kyazdani42/nvim-tree.lua", cmd = "NvimTreeToggle" },

	-- colorscheme
	{
		"catppuccin/nvim",
		as = "catppuccin",
		config = function()
			vim.o.background = "dark" -- for the dark version
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- Mason
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
			{ "WhoIsSethDaniel/mason-tool-installer.nvim", build = ":MasonToolsUpdate" },
		},
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-context",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/nvim-treesitter-refactor",
			"HiPhish/nvim-ts-rainbow2",
		},
	},

	-- CMP
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"onsails/lspkind.nvim",
			"hrsh7th/cmp-nvim-lsp",
			{ "hrsh7th/cmp-nvim-lua", dependencies = "folke/neodev.nvim" },
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
			{ "L3MON4D3/LuaSnip", dependencies = { "rafamadriz/friendly-snippets" } },
		},
	},

	-- NullLS
	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = { "jayp0521/mason-null-ls.nvim" },
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			{ "xiyaowong/telescope-emoji.nvim", cmd = "Telescope" },
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
	},
}, {})
