local function rlmn()
	require("nvim-treesitter.textobjects.repeatable_move").repeat_last_move_next()
end
local function rlmp()
	require("nvim-treesitter.textobjects.repeatable_move").repeat_last_move_previous()
end
local function bf()
	require("nvim-treesitter.textobjects.repeatable_move").builtin_f()
end
local function bF()
	require("nvim-treesitter.textobjects.repeatable_move").builtin_F()
end
local function bt()
	require("nvim-treesitter.textobjects.repeatable_move").builtin_t()
end
local function bT()
	require("nvim-treesitter.textobjects.repeatable_move").builtin_T()
end
local m = { "n", "x", "o" }
local mm = { "n", "x" }

return {
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		main = "nvim-treesitter.configs",
		keys = {
			{ ";", rlmn, mode = m },
			{ ",", rlmp, mode = m },
			{ "f", bf, mode = mm },
			{ "F", bF, mode = mm },
			{ "t", bt, mode = mm },
			{ "T", bT, mode = mm },
		},
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
		event = { "BufRead", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-refactor",
			"RRethy/nvim-treesitter-endwise",
			"theHamsta/nvim-treesitter-pairs",
			"HiPhish/nvim-ts-rainbow2",
		},
	},
}
