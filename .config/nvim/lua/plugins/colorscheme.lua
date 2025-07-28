return {
	{
		"vague2k/vague.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			require("vague").setup {
				transparent = true,
				colors = {
					bg = "#232136",
					fg = "#e0def4",
					floatBorder = "#908caa",
					line = "#393552",
					comment = "#6e6a86",
					builtin = "#9ccfd8",
					func = "#eb6f92",
					string = "#f6c177",
					number = "#e0a363",
					property = "#c3c3d5",
					constant = "#aeaed1",
					parameter = "#bb9dbd",
					visual = "#333738",
					error = "#eb6f92",
					warning = "#f6c177",
					hint = "#3e8fb0",
					operator = "#90a0b5",
					keyword = "#6e94b2",
					type = "#9bb4bc",
					search = "#405065",
					plus = "#7fa563",
					delta = "#f6c177",
				},
				-- rose pine palette
				-- Base           #232136
				-- Surface        #2a273f
				-- Overlay        #393552
				-- Muted          #6e6a86
				-- Subtle         #908caa
				-- Text           #e0def4
				-- Love           #eb6f92
				-- Gold           #f6c177
				-- Rose           #ea9a97
				-- Pine           #3e8fb0
				-- Foam           #9ccfd8
				-- Iris           #c4a7e7
				-- Highlight Low  #2a283e
				-- Highlight Med  #44415a
				-- Highlight High #56526e
			}
			vim.cmd.colorscheme "vague"
			vim.cmd.highlight([[StatusLine guifg=#c4a7e7 guibg=#2a273f]])
		end,
	},
	-- {
	-- 	"catppuccin/nvim",
	-- 	name = "catppuccin",
	-- 	priority = 1000,
	-- 	lazy = false,
	-- 	config = function()
	-- 		require("catppuccin").setup {
	-- 			flavour = 'mocha',
	-- 			transparent_background = true,
	-- 			show_end_of_buffer = true,
	-- 			dim_inactive = { enabled = true },
	-- 		}
	-- 		vim.cmd.colorscheme "catppuccin"
	-- 	end,
	-- },
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
