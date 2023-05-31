local function opts()
	local trouble = require("trouble.providers.telescope")
	local telescope = require("telescope")
	telescope.load_extension("fzf")
	telescope.load_extension("emoji")
	telescope.load_extension("notify")
	telescope.load_extension("ht")
	return {
		defaults = {
			mappings = {
				i = {
					["<esc>"] = "close",
					["<C-u>"] = false,
					["<C-j>"] = "preview_scrolling_down",
					["<C-k>"] = "preview_scrolling_up",
					["<c-t>"] = trouble.open_with_trouble,
				},
				n = {
					["<c-t>"] = trouble.open_with_trouble,
				},
			},
		},
		extensions = {},
	}
end

local function keys()
	local ok, builtin = pcall(require, "telescope.builtin")
	if not ok then return end
	local o = { noremap = true, silent = true, expr = false }
	return {
		{ "<c-p>", builtin.find_files, o },
		{ "<leader>fb", builtin.buffers, o },
		{ "<leader>fd", builtin.diagnostics, o },
		{ "<leader>fe", "<cmd>Telescope emoji<CR>", o },
		{ "<leader>ft", builtin.tags, o },
		{ "<leader>fl", builtin.live_grep, o },
		{ "<leader>fr", builtin.registers, o },
		{ "<leader>fh", builtin.help_tags, o },
		{ "<leader>fm", builtin.keymaps, o },
		{ "<leader>fgc", builtin.git_commits, o },
		{ "<leader>qf", builtin.quickfix, o },
		{ "<leader>fc", builtin.colorscheme, o },
		{ "<leader>fcmd", builtin.commands, o },
		{ "<leader>fft", builtin.filetypes, o },
		{ "<leader>fgf", builtin.git_files, o },
		{ "<leader>fhs", builtin.search_history, o },
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
	}

	-- vim.keymap.set("n", "<leader>fh", builtin.command_history, {})
	-- vim.keymap.set("n", "<leader>fl", builtin.current_buffer_fuzzy_find, {})
	-- vim.keymap.set("n", "<leader>fgfd", nil, {}) --  :<C-u>GFiles-diff<cr>
	-- vim.keymap.set("n", "<leader>fhf", nil, {}) --   :<C-u>History-files<cr>
	-- vim.keymap.set("n", "<leader>fw", nil, {}) --    :<C-u>Windows<cr>
	-- vim.keymap.set("n", "<leader>fs", nil, {}) --    :<C-u>Snippets<cr>
end

return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		opts = opts,
		cmd = "Telescope",
		keys = keys,
		dependencies = {
			"xiyaowong/telescope-emoji.nvim",
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
