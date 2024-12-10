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
			path_display = { "truncate" },
			sorting_strategy = "ascending",
			winblend = 10,
			mappings = {
				i = {
					["<esc>"] = "close",
					["<C-h>"] = "which_key",
					["<C-u>"] = false,
					["<C-j>"] = "preview_scrolling_down",
					["<C-k>"] = "preview_scrolling_up",
					["<C-f>"] = "preview_scrolling_down",
					["<C-b>"] = "preview_scrolling_up",
				},
			},
			file_ignore_patterns = { "node_modules", ".git/" },
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--hidden",
			},
		},
		pickers = {
			find_files = {
				hidden = true,
			},
			colorscheme = { enable_preview = true },
			buffers = {
				sort_lastused = true,
				mappings = {
					i = {
						["<C-d>"] = require("telescope.actions").delete_buffer,
					},
				},
			},
		},
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
			["ui-select"] = {
				require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}),
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
			{ "<c-p>",         k("find_files"),  desc = "Find files" },
			{ "<leader>fb",    k("buffers"),     desc = "List buffers" },
			{ "<leader>fd",    k("diagnostics"), desc = "List diagnostics" },
			{ "<leader>ft",    k("tags"),        desc = "List tags" },
			{ "<leader>fl",    k("live_grep"),   desc = "Live grep" },
			{ "<leader>fr",    k("registers"),   desc = "List registers" },
			{ "<leader>fh",    k("help_tags"),   desc = "Search help tags" },
			{ "<leader>fm",    k("keymaps"),     desc = "List keymaps" },
			-- { "<leader>fgc", k("git_commits"), desc = "List git commits" },
			{ "<leader>qf",    k("quickfix"),    desc = "List quickfix items" },
			-- { "<leader>fc", k("colorscheme"), desc = "List colorschemes" },
			-- { "<leader>fcmd", k("commands"), desc = "List commands" },
			-- { "<leader>fft", k("filetypes"), desc = "List filetypes" },
			{ "<leader>fgf",   k("git_files"),   desc = "Find git files" },
			-- { "<leader>fhs", k("search_history"),  },
			{ "<leader>fmark", k("marks") },
			{ "<leader>fo",    k("vim_options") },
			{
				"<leader><space>",
				function()
					local bi = require("telescope.builtin")
					local th = require("telescope.themes")
					return bi.current_buffer_fuzzy_find(th.get_dropdown({ winblend = 10, previewer = false }))
				end,
				{ desc = "[ ] Fuzzily search in current buffer" },
			},
			{
				"<leader>fc", function()
				return require("telescope.builtin").find_files {
					cwd = vim.fn.stdpath("config")
				}
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
