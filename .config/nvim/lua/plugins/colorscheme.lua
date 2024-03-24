return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
		config = function()
			require("rose-pine").setup({ disable_italics = true, dark_variant = "moon" })
			vim.o.background = "dark"
			vim.cmd.colorscheme("rose-pine-main")
			vim.cmd.highlight([[StatusLine guifg=#ea9a97 guibg=#2a283e]])
		end,
	},
}
