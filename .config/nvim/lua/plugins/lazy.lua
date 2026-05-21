return {
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
			format_on_save = function(bufnr)
				local timeout_ms = vim.bo[bufnr].filetype == "python" and 3000 or 500
				return { lsp_format = "fallback", timeout_ms = timeout_ms }
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				ruby = { "rubyfmt", lsp_format = "prefer" },
				rust = { "rustfmt", lsp_format = "fallback" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
			},
			default_format_opts = { lsp_format = "fallback" },
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
