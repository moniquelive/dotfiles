return {
	{
		"ray-x/go.nvim",
		dependencies = {
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
		},
		config = true,
		ft = { "go", "gomod", "gotext", "gohtml" },
		keys = {
			{ "<leader>ca", "<cmd>GoCodeLenAct<cr>" },
		},
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
	},
}
