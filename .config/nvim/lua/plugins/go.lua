-- Run gofmt + goimport on save

local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		require("go.format").goimport()
	end,
	group = format_sync_grp,
})

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
