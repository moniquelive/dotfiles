local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
	-- coding
	{ "andymass/vim-matchup", keys = "%" },
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
				bash = { "shfmt" },
				css = prettier,
				html = prettier,
				javascript = prettier,
				javascriptreact = prettier,
				json = prettier,
				jsonc = prettier,
				lua = { "stylua" },
				python = { "isort", "black" },
				ruby = { "rubyfmt", lsp_format = "prefer" },
				rust = { "rustfmt", lsp_format = "fallback" },
				scss = prettier,
				sh = { "shfmt" },
				svelte = prettier,
				typescript = prettier,
				typescriptreact = prettier,
				vue = prettier,
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
				"man.nvim",
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "${3rd}/love2d/library", words = { "love%." } },
				{ path = "LazyVim", words = { "LazyVim" } },
				{ path = "luassert-types/library", words = { "assert" } },
				{ path = "busted-types/library", words = { "describe" } },
			},
		},
	},
}
