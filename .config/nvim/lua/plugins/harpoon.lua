local function k(name)
	return function()
		local harpoon = require("harpoon")
		if name == "menu" then
			return harpoon.ui:toggle_quick_menu(harpoon:list())
		elseif name == "add" then
			return harpoon:list():add()
		elseif name:match("^nav%d$") then
			harpoon:list():select(tonumber(name:sub(4)))
		end
	end
end

return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<M-0>", k("menu"), desc = "Harpoon menu" },
			{ "<M-1>", k("nav1"), desc = "Harpoon file 1" },
			{ "<M-2>", k("nav2"), desc = "Harpoon file 2" },
			{ "<M-3>", k("nav3"), desc = "Harpoon file 3" },
			{ "<M-4>", k("nav4"), desc = "Harpoon file 4" },
			{ "<M-5>", k("nav5"), desc = "Harpoon file 5" },
			{ "<M-6>", k("nav6"), desc = "Harpoon file 6" },
			{ "<M-7>", k("nav7"), desc = "Harpoon file 7" },
			{ "<M-8>", k("nav8"), desc = "Harpoon file 8" },
			{ "<M-9>", k("add"), desc = "Harpoon add file" },
		},
		config = function() require("harpoon"):setup() end,
	},
}
