return {
	-- misc
	{ "wincent/terminus",     event = { "BufRead", "BufNewFile" } },
	-- coding
	{ "andymass/vim-matchup", keys = "%" },
	{
		'kosayoda/nvim-lightbulb',
		event = { "BufRead", "BufNewFile" },
		opts = {
			autocmd = { enabled = true, updatetime = -1 },
			number = { enabled = true },
			sign = { enabled = false },
			virtual_text = { enabled = true },
		}
	},
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
			local vim_notify = require("format-on-save.error-notifiers.vim-notify")
			return {
				error_notifier = vim_notify,
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
				experiments = {
					partial_update = 'diff', -- or 'line-by-line'
				}
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
}
