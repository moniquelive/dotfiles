require("nvim-treesitter.configs").setup({
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
})

vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
