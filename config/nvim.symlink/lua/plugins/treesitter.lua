vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

local function textobjects_keys()
	local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
	return {
		-- Repeat movement with ; and ,
		-- ensure ; goes forward and , goes backward regardless of the last direction
		{ ";", ts_repeat_move.repeat_last_move_next, mode = { "n", "x", "o" } },
		{ ",", ts_repeat_move.repeat_last_move_previous, mode = { "n", "x", "o" } },
		-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
		{ "f", ts_repeat_move.builtin_f, mode = { "n", "x", "o" } },
		{ "F", ts_repeat_move.builtin_F, mode = { "n", "x", "o" } },
		{ "t", ts_repeat_move.builtin_t, mode = { "n", "x", "o" } },
		{ "T", ts_repeat_move.builtin_T, mode = { "n", "x", "o" } },
	}
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = "all",
			endwise = { enable = true },
			highlight = { enable = true, additional_vim_regex_highlighting = false },
			indent = { enable = true, disable = { "python", "ruby" } },
			textobjects = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<M-UP>", -- set to `false` to disable one of the mappings
					node_incremental = "<M-UP>",
					scope_incremental = "<M-RIGHT>",
					node_decremental = "<M-DOWN>",
				},
			},
			matchup = {
				enable = true, -- mandatory, false will disable the whole extension
			},
		},
		build = ":TSUpdate",
		event = "BufRead",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-context",
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				main = "nvim-treesitter.configs",
				keys = textobjects_keys,
				opts = {
					textobjects = {
						select = {
							enable = true,
							lookahead = true,
							keymaps = {
								["af"] = "@function.outer",
								["if"] = "@function.inner",
								["ac"] = "@class.outer",
								["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
								["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
							},
							selection_modes = {
								["@parameter.outer"] = "v", -- charwise
								["@function.outer"] = "V", -- linewise
								["@class.outer"] = "<c-v>", -- blockwise
							},
							include_surrounding_whitespace = true,
						},
						move = {
							enable = true,
							set_jumps = true, -- whether to set jumps in the jumplist
							goto_next_start = {
								["]m"] = "@function.outer",
								["]]"] = { query = "@class.outer", desc = "Next class start" },
								["]o"] = "@loop.*",
								["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
								["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
							},
							goto_next_end = {
								["]M"] = "@function.outer",
								["]["] = "@class.outer",
							},
							goto_previous_start = {
								["[m"] = "@function.outer",
								["[["] = "@class.outer",
							},
							goto_previous_end = {
								["[M"] = "@function.outer",
								["[]"] = "@class.outer",
							},
							goto_next = {
								["]d"] = "@conditional.outer",
							},
							goto_previous = {
								["[d"] = "@conditional.outer",
							},
						},
						lsp_interop = {
							enable = true,
							peek_definition_code = {
								["<leader>df"] = "@function.outer",
								["<leader>dF"] = "@class.outer",
							},
						},
					},
				},
			},
			{
				"nvim-treesitter/nvim-treesitter-refactor",
				main = "nvim-treesitter.configs",
				opts = {
					highlight_current_scope = { enable = true },
					refactor = {
						smart_rename = {
							enable = true,
							keymaps = {
								smart_rename = "<F2>",
							},
						},
						navigation = {
							enable = true,
							goto_definition_lsp_fallback = true,
						},
					},
				},
			},
			{
				"HiPhish/nvim-ts-rainbow2",
				main = "nvim-treesitter.configs",
				opts = {
					rainbow = { enable = true },
				},
			},
		},
	},
}
