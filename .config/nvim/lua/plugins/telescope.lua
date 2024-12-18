local function k(name)
	return function()
		require("telescope").load_extension("fzf")
		require("telescope").load_extension("ui-select")
		local theme = require('telescope.themes').get_ivy {
			layout_config = {
				height = vim.fn.round(vim.o.lines * 0.8)
			}
		}
		return require("telescope.builtin")[name](theme)
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
			{ "<c-p>",         k("find_files"),  desc = "(TS) Find files" },
			{ "<leader>fb",    k("buffers"),     desc = "(TS) List buffers" },
			{ "<leader>fd",    k("diagnostics"), desc = "(TS) List diagnostics" },
			{ "<leader>ft",    k("tags"),        desc = "(TS) List tags" },
			{ "<leader>fl",    k("live_grep"),   desc = "(TS) Live grep" },
			{ "<leader>fr",    k("registers"),   desc = "(TS) List registers" },
			{ "<leader>fh",    k("help_tags"),   desc = "(TS) Search help tags" },
			{ "<leader>fm",    k("keymaps"),     desc = "(TS) List keymaps" },
			-- { "<leader>fgc", k("git_commits"), desc = "(TS) List git commits" },
			{ "<leader>qf",    k("quickfix"),    desc = "(TS) List quickfix items" },
			-- { "<leader>fc", k("colorscheme"), desc = "(TS) List colorschemes" },
			-- { "<leader>fcmd", k("commands"), desc = "(TS) List commands" },
			-- { "<leader>fft", k("filetypes"), desc = "(TS) List filetypes" },
			{ "<leader>fgf",   k("git_files"),   desc = "(TS) Find git files" },
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
				{ desc = "(TS) Fuzzily search in current buffer" },
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
