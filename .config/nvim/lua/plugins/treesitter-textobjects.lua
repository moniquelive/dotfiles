local function repeat_last_move_next()
	return require("nvim-treesitter.textobjects.repeatable_move").repeat_last_move_next()
end
local function repeat_last_move_previous()
	return require("nvim-treesitter.textobjects.repeatable_move").repeat_last_move_previous()
end
local function builtin_f_expr()
	return require("nvim-treesitter.textobjects.repeatable_move").builtin_f_expr()
end
local function builtin_F_expr()
	return require("nvim-treesitter.textobjects.repeatable_move").builtin_F_expr()
end
local function builtin_t_expr()
	return require("nvim-treesitter.textobjects.repeatable_move").builtin_t_expr()
end
local function builtin_T_expr()
	return require("nvim-treesitter.textobjects.repeatable_move").builtin_T_expr()
end

local function keys()
	local m = { "n", "x", "o" }
	return {
		{ ";", repeat_last_move_next, mode = m },
		{ ",", repeat_last_move_previous, mode = m },
		{ "f", builtin_f_expr, mode = m, expr = true },
		{ "F", builtin_F_expr, mode = m, expr = true },
		{ "t", builtin_t_expr, mode = m, expr = true },
		{ "T", builtin_T_expr, mode = m, expr = true },
	}
end

local function opts()
	return {
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
	}
end

return {
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		main = "nvim-treesitter.configs",
		keys = keys,
		opts = opts,
		event = { "BufRead", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-refactor",
			"RRethy/nvim-treesitter-endwise",
			"theHamsta/nvim-treesitter-pairs",
		},
	},
}
