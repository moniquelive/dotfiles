return {
	{
		"echasnovski/mini.nvim",
		version = false,
		event = { "BufRead", "BufNewFile" },
		config = function()
			require("mini.icons").setup()
			require("mini.ai").setup()
			require("mini.align").setup({
				mappings = {
					start = "gl",
					start_with_preview = "gL",
				},
			})
			require("mini.bracketed").setup()
			require("mini.comment").setup()
			require("mini.move").setup({
				mappings = {
					-- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
					left = "<C-M-h>",
					right = "<C-M-l>",
					down = "<C-M-j>",
					up = "<C-M-k>",

					-- Move current line in Normal mode
					line_left = "<C-M-h>",
					line_right = "<C-M-l>",
					line_down = "<C-M-j>",
					line_up = "<C-M-k>",
				},
			})
			require("mini.splitjoin").setup()
			require("mini.surround").setup()
			require("mini.diff").setup()
			require("mini.statusline").setup()
			require("mini.trailspace").setup()
			require("mini.misc").setup_restore_cursor()
			require("mini.misc").setup_termbg_sync()
		end,
	},
}
