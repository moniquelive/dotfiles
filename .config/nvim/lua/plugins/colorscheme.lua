return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		config = function()
			require("catppuccin").setup {
				flavour = 'mocha',
				transparent_background = true,
				show_end_of_buffer = true,
				dim_inactive = { enabled = true },
			}
			vim.cmd.colorscheme "catppuccin"
		end,
	},
	-- {
	-- 	"ellisonleao/gruvbox.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		vim.cmd.colorscheme("gruvbox")
	-- 	end,
	-- },
	-- {
	-- 	"rose-pine/neovim",
	-- 	name = "rose-pine",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("rose-pine").setup({ dark_variant = "moon" })
	-- 		vim.o.background = "dark"
	-- 		vim.cmd.colorscheme("rose-pine-main")
	-- 		vim.cmd.highlight([[StatusLine guifg=#ea9a97 guibg=#2a283e]])
	-- 	end,
	-- },
}
