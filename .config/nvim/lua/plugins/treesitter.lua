vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = "all",
			ignore_install = { "unison", "blade", "latex", "teal", "scfg", "ocamllex", "swift", "mlir" },
			auto_install = true,
			endwise = { enable = true },
			highlight = { enable = true, additional_vim_regex_highlighting = { "ruby" } },
			indent = { enable = true, disable = { "python", "ruby" } },
			textobjects = { enable = true },
			matchup = { enable = true }, -- mandatory, false will disable the whole extension ,
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<M-UP>", -- set to `false` to disable one of the mappings
					node_incremental = "<M-UP>",
					scope_incremental = "<M-RIGHT>",
					node_decremental = "<M-DOWN>",
				},
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-refactor",
		main = "nvim-treesitter.configs",
		opts = {
			refactor = {
				highlight_current_scope = { enable = true },
				-- smart_rename = { enable = true, keymaps = { smart_rename = "<F2>" } },
				navigation = { enable = true, goto_definition_lsp_fallback = true },
				highlight_definitions = {
					enable = true, -- Set to false if you have an `updatetime` of ~100.
					clear_on_cursor_move = true,
				},
			},
		},
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
}
