local function opts()
	return {
		defaults = {
			mappings = {
				i = {
					["<esc>"] = "close",
					["<C-h>"] = "which_key",
					["<C-u>"] = false,
					["<C-j>"] = "preview_scrolling_down",
					["<C-k>"] = "preview_scrolling_up",
				},
			},
		},
		pickers = {
			colorscheme = { enable_preview = true },
			buffers = {
				mappings = {
					i = {
						["<C-d>"] = require("telescope.actions").delete_buffer,
					},
				},
			},
		},
		extensions = {
			["ui-select"] = {
				require("telescope.themes").get_dropdown(),
			},
		},
	}
end

local function keys()
	local o = { noremap = true, silent = true, expr = false }
	local builtin = require("telescope.builtin")
	return {
		{ "<c-p>", builtin.find_files, o },
		{ "<leader>fb", builtin.buffers, o },
		{ "<leader>fd", builtin.diagnostics, o },
		{ "<leader>ft", builtin.tags, o },
		{ "<leader>fl", builtin.live_grep, o },
		{ "<leader>fr", builtin.registers, o },
		{ "<leader>fh", builtin.help_tags, o },
		{ "<leader>fm", builtin.keymaps, o },
		-- { "<leader>fgc", builtin.git_commits, o },
		{ "<leader>qf", builtin.quickfix, o },
		-- { "<leader>fc", builtin.colorscheme, o },
		-- { "<leader>fcmd", builtin.commands, o },
		-- { "<leader>fft", builtin.filetypes, o },
		{ "<leader>fgf", builtin.git_files, o },
		-- { "<leader>fhs", builtin.search_history, o },
		{ "<leader>fmark", builtin.marks, o },
		{ "<leader>fo", builtin.vim_options, o },
		{
			"<leader><space>",
			function()
				builtin.current_buffer_fuzzy_find(
					require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
				)
			end,
			{ desc = "[ ] Fuzzily search in current buffer" },
		},
		{
			"<leader>fc",
			function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end,
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
			{ "nvim-telescope/telescope-ui-select.nvim" },
		},
	},
}
