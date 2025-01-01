return {
	-- misc
	{ "wincent/terminus",                event = { "BufRead", "BufNewFile" } },
	{ "bronson/vim-trailing-whitespace", event = { "BufRead", "BufNewFile" } },
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufRead", "BufNewFile" },
		main = "ibl",
		opts = {},
	},

	-- coding
	{ "tommcdo/vim-lion",     keys = { { "gl", mode = { "v", "n" } }, { "gL", mode = { "v", "n" } } } },
	{ "andymass/vim-matchup", keys = "%" },
	{
		"laytan/tailwind-sorter.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
		ft = { "html", "heex" },
		build = "cd formatter && npm ci && npm run build",
		opts = { on_save_enabled = true },
	},
	{
		"elentok/format-on-save.nvim",
		event = { "BufRead", "BufNewFile" },
		opts = function()
			local formatters = require("format-on-save.formatters")
			return {
				error_notifier = require("format-on-save.error-notifiers.vim-notify"),
				exclude_path_patterns = {
					"/node_modules/",
					".local/share/nvim/lazy",
				},
				formatter_by_ft = {
					sh = formatters.shfmt,
					markdown = formatters.prettierd,
					typescript = formatters.prettierd,
				},
				fallback_formatter = {
					formatters.remove_trailing_whitespace,
					formatters.remove_trailing_newlines,
					formatters.lsp,
				},
			}
		end,
	},
	{
		"folke/lazydev.nvim",
		dependencies = {
			{ "LuaCATS/luassert", name = "luassert-types" },
			{ "LuaCATS/busted",   name = "busted-types" },
		},
		ft = "lua",
		opts = {
			library = {
				"~/.config/nvim",
				"rfc.nvim",
				{ path = "${3rd}/luv/library",     words = { "vim%.uv" } },
				{ path = "${3rd}/love2d/library",  words = { "love%." } },
				{ path = "LazyVim",                words = { "LazyVim" } },
				{ path = "luassert-types/library", words = { "assert" } },
				{ path = "busted-types/library",   words = { "describe" } },
			},
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

	-- Notifications
	{
		"j-hui/fidget.nvim",
		lazy = false,
		opts = {
			notification = {
				override_vim_notify = true,
				window = { winblend = 0, border = 'rounded' },
			},
			integration = {
				["nvim-tree"] = { enable = false },
			},
		},
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false,
		config = true,
	},
}
