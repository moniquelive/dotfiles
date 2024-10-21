local function k(name)
	return function()
		return require("nvim-treesitter.textobjects.repeatable_move")[name]()
	end
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
		keys = {
			{ ";", k("repeat_last_move_next"), mode = { "n", "x", "o" } },
			{ ",", k("repeat_last_move_previous"), mode = { "n", "x", "o" } },
			{ "f", k("builtin_f_expr"), mode = { "n", "x", "o" }, expr = true },
			{ "F", k("builtin_F_expr"), mode = { "n", "x", "o" }, expr = true },
			{ "t", k("builtin_t_expr"), mode = { "n", "x", "o" }, expr = true },
			{ "T", k("builtin_T_expr"), mode = { "n", "x", "o" }, expr = true },
		},
		opts = opts,
		event = { "BufRead", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-refactor",
			"RRethy/nvim-treesitter-endwise",
			"theHamsta/nvim-treesitter-pairs",
		},
	},
}
