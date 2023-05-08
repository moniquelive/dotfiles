return {
	"olexsmir/gopher.nvim",
	build = ":GoInstallDeps",
	dependencies = { -- dependencies
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	ft = "go",
	keys = {
		{ "<leader>gsj", "<cmd>GoTagAdd json<cr>" },
	},
}
