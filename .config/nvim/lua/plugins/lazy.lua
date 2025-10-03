return {
	-- misc
	{ "wincent/terminus",     event = { "BufRead", "BufNewFile" } },
	-- coding
	{ "andymass/vim-matchup", keys = "%" },
	{
		"laytan/tailwind-sorter.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
		ft = { "html", "heex" },
		build = "cd formatter && npm ci && npm run build",
		opts = { on_save_enabled = true },
	},
	{
		'stevearc/conform.nvim',
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				-- Customize or remove this keymap to your liking
				"<leader>f",
				function() require("conform").format({ async = true }) end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
			-- Define your formatters
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
			},
			-- Set default options
			default_format_opts = { lsp_format = "fallback" },
			-- Set up format-on-save
			format_on_save = { timeout_ms = 500 },
			-- Customize formatters
			formatters = { shfmt = { append_args = { "-i", "2" } } },
		},
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
