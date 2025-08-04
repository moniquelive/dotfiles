return {
	"ray-x/go.nvim",
	dependencies = {
		"ray-x/guihua.lua",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		golangci_lint = {
			default = 'standard', -- set to one of { 'standard', 'fast', 'all', 'none' }
			enable = { 'govet', 'ineffassign', 'revive', 'gosimple' },
		}
	},
	ft = { "go", "gomod", "gotext", "gohtml" },
	keys = {
		{ "<leader>ca", "<cmd>GoCodeLenAct<cr>" },
	},
	build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
}
