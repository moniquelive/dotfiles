require("nvim-treesitter.configs").setup({
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
})
