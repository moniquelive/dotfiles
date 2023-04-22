local opts = { noremap = true, silent = true, expr = false }

return {
	"Wansmer/treesj",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = { use_default_keymaps = false, max_join_length = 150 },
	cmd = { "TSJToggle", "TSJJoin", "TSJSplit" },
	keys = {
		{ "gM", "<cmd>TSJToggle<cr>", opts },
		{ "gJ", "<cmd>TSJJoin<cr>", opts },
		{ "gS", "<cmd>TSJSplit<cr>", opts },
	},
}
