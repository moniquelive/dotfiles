return {
	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {
			default_file_explorer = true,
			delete_to_trash = true,
			watch_for_changes = true,
			keymaps = {
				["q"] = "actions.close",
				["<C-v>"] = "actions.select_vsplit",
				["<C-x>"] = "actions.select_split",
				["<C-l>"] = false,
				["<C-h>"] = false,
			},
		},
		-- cmd = "Oil",
		lazy = false,
		keys = { { "-", [[<cmd>Oil<cr>]] } },
	},
}
