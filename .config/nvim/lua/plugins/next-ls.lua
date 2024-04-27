return {
	"elixir-tools/elixir-tools.nvim",
	version = "*",
	-- event = { "BufReadPre", "BufNewFile" },
	ft = { "heex", "elixir" },
	config = function()
		local elixir = require("elixir")
		local elixirls = require("elixir.elixirls")

		elixir.setup({
			nextls = { enable = true },
			credo = {},
			elixirls = {
				enable = true,
				settings = elixirls.settings({
					dialyzerEnabled = false,
					enableTestLenses = false,
				}),
				-- on_attach = function(client, _bufnr)
				-- 	vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
				-- 	vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
				-- 	vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })
				-- end,
			},
		})
	end,
	dependencies = { "nvim-lua/plenary.nvim" },
}
