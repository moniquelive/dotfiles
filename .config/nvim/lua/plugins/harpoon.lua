return {
	{
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = function()
			local K = {
				{ "<M-0>", require("harpoon.ui").toggle_quick_menu },
				{ "<M-9>", require("harpoon.mark").add_file },
			}
			for i = 1, 8 do
				table.insert(K, {
					string.format("<M-%d>", i), -- <M-{1..8}>
					function()
						require("harpoon.ui").nav_file(i)
					end,
				})
			end
			return K
		end,
	},
}
