local function k(name)
    return function()
        local harpoon = require("harpoon")
        harpoon:setup()
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
            { "<M-0>", k("menu") },
            { "<M-9>", k("add") },
        },
        config = function()
            for i = 1, 8 do
                vim.keymap.set("n", string.format("<M-%d>", i),
                    k("nav" .. i), { noremap = true, silent = true })
            end
        end
    },
}
