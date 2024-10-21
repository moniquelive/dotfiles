local function k(name)
	return function()
		local harpoon = require("harpoon")
		harpoon:setup()
		return (name == "menu" and harpoon.ui:toggle_quick_menu(harpoon:list()))
			or (name == "add" and harpoon:list():add())
			or (name == "nav1" and harpoon:list():select(1))
			or (name == "nav2" and harpoon:list():select(2))
			or (name == "nav3" and harpoon:list():select(3))
			or (name == "nav4" and harpoon:list():select(4))
			or (name == "nav5" and harpoon:list():select(5))
			or (name == "nav6" and harpoon:list():select(6))
			or (name == "nav7" and harpoon:list():select(7))
			or (name == "nav8" and harpoon:list():select(8))
	end
end

local o = { noremap = true, silent = true, expr = false }
return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<M-0>", k("menu"), o },
			{ "<M-1>", k("nav1"), o },
			{ "<M-2>", k("nav2"), o },
			{ "<M-3>", k("nav3"), o },
			{ "<M-4>", k("nav4"), o },
			{ "<M-5>", k("nav5"), o },
			{ "<M-5>", k("nav6"), o },
			{ "<M-7>", k("nav7"), o },
			{ "<M-8>", k("nav8"), o },
			{ "<M-9>", k("add"), o },
		},
	},
}
