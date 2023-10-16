local function opts()
	local telescope = require("telescope")
	telescope.load_extension("fzf")
	telescope.load_extension("notify")
	return {
		defaults = {
			mappings = {
				i = {
					["<esc>"] = "close",
					["<C-u>"] = false,
					["<C-j>"] = "preview_scrolling_down",
					["<C-k>"] = "preview_scrolling_up",
				},
			},
		},
		pickers = { colorscheme = { enable_preview = true } },
		extensions = {},
	}
end

local function keys()
	local o = { noremap = true, silent = true, expr = false }
	return {
		{ "<c-p>", require("telescope.builtin").find_files, o },
		{ "<leader>fb", require("telescope.builtin").buffers, o },
		{ "<leader>fd", require("telescope.builtin").diagnostics, o },
		{ "<leader>ft", require("telescope.builtin").tags, o },
		{ "<leader>fl", require("telescope.builtin").live_grep, o },
		{ "<leader>fr", require("telescope.builtin").registers, o },
		{ "<leader>fh", require("telescope.builtin").help_tags, o },
		{ "<leader>fm", require("telescope.builtin").keymaps, o },
		{ "<leader>fgc", require("telescope.builtin").git_commits, o },
		{ "<leader>qf", require("telescope.builtin").quickfix, o },
		{ "<leader>fc", require("telescope.builtin").colorscheme, o },
		{ "<leader>fcmd", require("telescope.builtin").commands, o },
		{ "<leader>fft", require("telescope.builtin").filetypes, o },
		{ "<leader>fgf", require("telescope.builtin").git_files, o },
		{ "<leader>fhs", require("telescope.builtin").search_history, o },
		{ "<leader>fmark", require("telescope.builtin").marks, o },
		{ "<leader>fo", require("telescope.builtin").vim_options, o },
		{
			"<leader><space>",
			function()
				require("telescope.builtin").current_buffer_fuzzy_find(
					require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
				)
			end,
			{ desc = "[ ] Fuzzily search in current buffer" },
		},
	}
end

return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		opts = opts,
		cmd = "Telescope",
		keys = keys,
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
	},
}
