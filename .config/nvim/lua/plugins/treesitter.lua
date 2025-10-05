return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = ":TSUpdate",
		opts = {
			ensure_installed = "all",
			ignore_install = { "unison", "blade", "latex", "teal", "scfg", "ocamllex", "mlir", "verilog", "ipkg" },
			auto_install = true,
			endwise = { enable = true },
			highlight = { enable = true, additional_vim_regex_highlighting = { "ruby" } },
			indent = { enable = true, disable = { "python", "ruby" } },
			textobjects = { enable = false },
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
}
