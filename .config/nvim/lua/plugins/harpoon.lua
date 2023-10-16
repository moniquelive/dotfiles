return {
	{
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<M-0>",
				function()
					require("harpoon.ui").toggle_quick_menu()
				end,
			},
			{
				"<M-1>",
				function()
					require("harpoon.ui").nav_file(1)
				end,
			},
			{
				"<M-2>",
				function()
					require("harpoon.ui").nav_file(2)
				end,
			},
			{
				"<M-3>",
				function()
					require("harpoon.ui").nav_file(3)
				end,
			},
			{
				"<M-4>",
				function()
					require("harpoon.ui").nav_file(4)
				end,
			},
			{
				"<M-5>",
				function()
					require("harpoon.ui").nav_file(5)
				end,
			},
			{
				"<leader>ha",
				function()
					require("harpoon.mark").add_file()
				end,
			},
		},
	},
}
