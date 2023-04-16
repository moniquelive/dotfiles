local function config()
	local telescope = require("telescope")
	telescope.load_extension("refactoring")
	telescope.load_extension("fzf")
	telescope.load_extension("emoji")
	telescope.load_extension("notify")
	telescope.load_extension("ht")

	local builtin = require("telescope.builtin")
	local k = vim.keymap.set
	local opts = { noremap = true, silent = true, expr = false }
	k("n", "<c-p>", builtin.find_files, opts)
	k("n", "<leader>fb", builtin.buffers, opts)
	k("n", "<leader>fd", builtin.diagnostics, opts)
	k("n", "<leader>fe", "<cmd>Telescope emoji<CR>", opts)
	k("n", "<leader>ft", builtin.tags, opts)
	k("n", "<leader>fl", builtin.live_grep, opts)
	k("n", "<leader>fr", builtin.registers, opts)
	k("n", "<leader>fh", builtin.help_tags, opts)
	k("n", "<leader>fm", builtin.keymaps, opts)
	k("n", "<leader>fgc", builtin.git_commits, opts)
	k("n", "<leader>qf", builtin.quickfix, opts)
	k("n", "<leader>fc", builtin.colorscheme, opts)
	k("n", "<leader>fcmd", builtin.commands, opts)
	k("n", "<leader>fft", builtin.filetypes, opts)
	k("n", "<leader>fgf", builtin.git_files, opts)
	k("n", "<leader>fhs", builtin.search_history, opts)
	k("n", "<leader>fmark", builtin.marks, opts)
	k("n", "<leader>fo", builtin.vim_options, opts)
	k("n", "<leader><space>", function()
		builtin.current_buffer_fuzzy_find(
			require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
		)
	end, { desc = "[ ] Fuzzily search in current buffer" })

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
		config = config,
		opts = {
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
			extensions = {},
		},
		dependencies = {
			{ "xiyaowong/telescope-emoji.nvim", cmd = "Telescope" },
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
