return {
	{
		"folke/snacks.nvim",
		init = function()
			local fallback_input = vim.ui.input
			local function lazy_input(...)
				require("lazy").load({ plugins = { "snacks.nvim" } })
				if vim.ui.input ~= lazy_input then return vim.ui.input(...) end
				return fallback_input(...)
			end
			vim.ui.input = lazy_input
		end,
		opts = {
			input = { enabled = true },
		},
	},

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
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function() require("conform").format({ async = true }) end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				ruby = { "rubyfmt", stop_after_first = true },
				rust = { "rustfmt", lsp_format = "fallback" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
			},
			default_format_opts = { lsp_format = "fallback" },
			format_on_save = { lsp_format = "fallback", timeout_ms = 500 },
			formatters = { shfmt = { append_args = { "-i", "2" } } },
		},
	},
	{
		"folke/lazydev.nvim",
		dependencies = {
			{ "LuaCATS/luassert", name = "luassert-types" },
			{ "LuaCATS/busted", name = "busted-types" },
		},
		ft = "lua",
		opts = {
			library = {
				"~/.config/nvim",
				"~/Exercism/lua",
				"rfc.nvim",
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "${3rd}/love2d/library", words = { "love%." } },
				{ path = "LazyVim", words = { "LazyVim" } },
				{ path = "luassert-types/library", words = { "assert" } },
				{ path = "busted-types/library", words = { "describe" } },
			},
		},
	},
}
