local function opts()
	vim.o.foldmethod = "expr"
	vim.o.foldexpr = "nvim_treesitter#foldexpr()"
	return {
		ensure_installed = "all",
		highlight = { enable = true },
		indent = { enable = true, disable = { "python", "ruby" } },
		textobjects = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "gnn", -- set to `false` to disable one of the mappings
				node_incremental = "gnn",
				scope_incremental = "grc",
				node_decremental = "gnN",
			},
		},
		matchup = {
			enable = true, -- mandatory, false will disable the whole extension
		},
	}
end

local function textobjects_keys()
	local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
	return {
		-- Repeat movement with ; and ,
		-- ensure ; goes forward and , goes backward regardless of the last direction
		{ ";", ts_repeat_move.repeat_last_move_next, mode = { "n", "x", "o" } },
		{ ",", ts_repeat_move.repeat_last_move_previous, mode = { "n", "x", "o" } },

		-- vim way: ; goes to the direction you were moving.
		-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
		-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

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
		opts = opts,
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
							-- Automatically jump forward to textobj, similar to targets.vim
							lookahead = true,
							keymaps = {
								-- You can use the capture groups defined in textobjects.scm
								["af"] = "@function.outer",
								["if"] = "@function.inner",
								["ac"] = "@class.outer",
								-- You can optionally set descriptions to the mappings (used in the desc parameter of
								-- nvim_buf_set_keymap) which plugins like which-key display
								["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
								-- You can also use captures from other query groups like `locals.scm`
								["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
							},
							-- You can choose the select mode (default is charwise 'v')
							--
							-- Can also be a function which gets passed a table with the keys
							-- * query_string: eg '@function.inner'
							-- * method: eg 'v' or 'o'
							-- and should return the mode ('v', 'V', or '<c-v>') or a table
							-- mapping query_strings to modes.
							selection_modes = {
								["@parameter.outer"] = "v", -- charwise
								["@function.outer"] = "V", -- linewise
								["@class.outer"] = "<c-v>", -- blockwise
							},
							-- If you set this to `true` (default is `false`) then any textobject is
							-- extended to include preceding or succeeding whitespace. Succeeding
							-- whitespace has priority in order to act similarly to eg the built-in
							-- `ap`.
							--
							-- Can also be a function which gets passed a table with the keys
							-- * query_string: eg '@function.inner'
							-- * selection_mode: eg 'v'
							-- and should return true of false
							include_surrounding_whitespace = true,
						},
						move = {
							enable = true,
							set_jumps = true, -- whether to set jumps in the jumplist
							goto_next_start = {
								["]m"] = "@function.outer",
								["]]"] = { query = "@class.outer", desc = "Next class start" },
								--
								-- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
								["]o"] = "@loop.*",
								-- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
								--
								-- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
								-- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
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
							-- Below will go to either the start or the end, whichever is closer.
							-- Use if you want more granular movements
							-- Make it even more gradual by adding multiple queries and regex.
							goto_next = {
								["]d"] = "@conditional.outer",
							},
							goto_previous = {
								["[d"] = "@conditional.outer",
							},
						},
						lsp_interop = {
							enable = true,
							-- border = "none",
							-- floating_preview_opts = {},
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
							-- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
							keymaps = {
								smart_rename = "<F2>",
							},
						},
						navigation = {
							enable = true,
							goto_definition_lsp_fallback = true,
							-- Assign keymaps to false to disable them, e.g. `goto_definition = false`.
							-- keymaps = {
							-- 	goto_definition = "gnd",
							-- 	list_definitions = "gnD",
							-- 	list_definitions_toc = "gO",
							-- 	goto_next_usage = "<a-*>",
							-- 	goto_previous_usage = "<a-#>",
							-- },
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
