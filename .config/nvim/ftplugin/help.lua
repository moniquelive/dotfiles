local k = vim.keymap
local kv = {
	["<CR>"] = "<C-]>",
	["<BS>"] = "<C-T>",
	["o"] = [[/'\l\{2,\}'<CR>]],
	["O"] = [[?'\l\{2,\}'<CR>]],
	["s"] = [[/\|\zs\S\+\ze\|<CR>]],
	["S"] = [[?\|\zs\S\+\ze\|<CR>]],
	["<ESC>"] = [[<cmd>close<cr>]],
	["q"] = [[<cmd>close<cr>]],
}
for key, value in pairs(kv) do
	k.set("n", key, value, { noremap = true, silent = true, buffer = true })
end
vim.cmd.wincmd "L"
