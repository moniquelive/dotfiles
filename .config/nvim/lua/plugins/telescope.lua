local function find_files()
	return require("telescope.builtin").find_files()
end
local function buffers()
	return require("telescope.builtin").buffers()
end
local function diagnostics()
	return require("telescope.builtin").diagnostics()
end
local function tags()
	return require("telescope.builtin").tags()
end
local function live_grep()
	return require("telescope.builtin").live_grep()
end
local function registers()
	return require("telescope.builtin").registers()
end
local function help_tags()
	return require("telescope.builtin").help_tags()
end
local function keymaps()
	return require("telescope.builtin").keymaps()
end
local function quickfix()
	return require("telescope.builtin").quickfix()
end
local function git_files()
	return require("telescope.builtin").git_files()
end
local function marks()
	return require("telescope.builtin").marks()
end
local function vim_options()
	return require("telescope.builtin").vim_options()
end

local function keys()
	local o = { noremap = true, silent = true, expr = false }
	return {
		{ "<c-p>", find_files, o },
		{ "<leader>fb", buffers, o },
		{ "<leader>fd", diagnostics, o },
		{ "<leader>ft", tags, o },
		{ "<leader>fl", live_grep, o },
		{ "<leader>fr", registers, o },
		{ "<leader>fh", help_tags, o },
		{ "<leader>fm", keymaps, o },
		-- { "<leader>fgc", builtin.git_commits, o },
		{ "<leader>qf", quickfix, o },
		-- { "<leader>fc", builtin.colorscheme, o },
		-- { "<leader>fcmd", builtin.commands, o },
		-- { "<leader>fft", builtin.filetypes, o },
		{ "<leader>fgf", git_files, o },
		-- { "<leader>fhs", builtin.search_history, o },
		{ "<leader>fmark", marks, o },
		{ "<leader>fo", vim_options, o },
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
	}
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
		keys = keys,
		config = function()
			require("telescope").load_extension("fzf")
			require("telescope").load_extension("ui-select")
		end,
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
