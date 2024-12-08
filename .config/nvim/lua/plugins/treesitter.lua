vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = "all",
			ignore_install = { "unison" },
			auto_install = true,
			endwise = { enable = true },
			highlight = { enable = true, additional_vim_regex_highlighting = { "ruby" } },
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
			matchup = { enable = true }, -- mandatory, false will disable the whole extension ,
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-refactor",
		main = "nvim-treesitter.configs",
		opts = {
			highlight_current_scope = { enable = true },
			refactor = {
				smart_rename = { enable = true, keymaps = { smart_rename = "<F2>" } },
				navigation = { enable = true, goto_definition_lsp_fallback = true },
			},
		},
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
}
