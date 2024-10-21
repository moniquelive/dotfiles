local function k(name)
	return function()
		local bi = require("telescope.builtin")
		local kf = {
			find_files = bi.find_files,
			buffers = bi.buffers,
			diagnostics = bi.diagnostics,
			tags = bi.tags,
			live_grep = bi.live_grep,
			registers = bi.registers,
			help_tags = bi.help_tags,
			keymaps = bi.keymaps,
			quickfix = bi.quickfix,
			git_files = bi.git_files,
			marks = bi.marks,
			vim_options = bi.vim_options,
		}
		return kf[name]()
	end
end

local function keys()
	local o = { noremap = true, silent = true, expr = false }
	return {
		{ "<c-p>", k("find_files"), o },
		{ "<leader>fb", k("buffers"), o },
		{ "<leader>fd", k("diagnostics"), o },
		{ "<leader>ft", k("tags"), o },
		{ "<leader>fl", k("live_grep"), o },
		{ "<leader>fr", k("registers"), o },
		{ "<leader>fh", k("help_tags"), o },
		{ "<leader>fm", k("keymaps"), o },
		-- { "<leader>fgc", k("git_commits"), o },
		{ "<leader>qf", k("quickfix"), o },
		-- { "<leader>fc", k("colorscheme"), o },
		-- { "<leader>fcmd", k("commands"), o },
		-- { "<leader>fft", k("filetypes"), o },
		{ "<leader>fgf", k("git_files"), o },
		-- { "<leader>fhs", k("search_history"), o },
		{ "<leader>fmark", k("marks"), o },
		{ "<leader>fo", k("vim_options"), o },
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
