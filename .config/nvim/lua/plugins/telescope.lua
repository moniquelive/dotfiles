local function k(name)
	return function()
		require("telescope").load_extension("fzf")
		require("telescope").load_extension("ui-select")
		return require("telescope.builtin")[name]()
	end
end

local function opts()
	return {
		defaults = {
			layout_strategy = "flex",
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

return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		opts = opts,
		cmd = "Telescope",
		keys = {
			{ "<c-p>", k("find_files") },
			{ "<leader>fb", k("buffers") },
			{ "<leader>fd", k("diagnostics") },
			{ "<leader>ft", k("tags") },
			{ "<leader>fl", k("live_grep") },
			{ "<leader>fr", k("registers") },
			{ "<leader>fh", k("help_tags") },
			{ "<leader>fm", k("keymaps") },
			-- { "<leader>fgc", k("git_commits"),  },
			{ "<leader>qf", k("quickfix") },
			-- { "<leader>fc", k("colorscheme"),  },
			-- { "<leader>fcmd", k("commands"),  },
			-- { "<leader>fft", k("filetypes"),  },
			{ "<leader>fgf", k("git_files") },
			-- { "<leader>fhs", k("search_history"),  },
			{ "<leader>fmark", k("marks") },
			{ "<leader>fo", k("vim_options") },
			{
				"<leader><space>",
				function()
					return require("telescope.builtin").current_buffer_fuzzy_find(
						require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
					)
				end,
				{ desc = "[ ] Fuzzily search in current buffer" },
			},
			{
				"<leader>fc",
				function()
					return require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
				end,
			},
		},
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
