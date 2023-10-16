return {
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
}
