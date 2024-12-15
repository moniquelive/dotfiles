local k = vim.keymap
local kv = {
	["<M-Right>"] = "<C-]>",
	["<M-Left>"] = "<C-T>",
	["o"] = [[/'\l\{2,\}'<CR>]],
	["O"] = [[?'\l\{2,\}'<CR>]],
	["s"] = [[/\|\zs\S\+\ze\|<CR>]],
	["S"] = [[?\|\zs\S\+\ze\|<CR>]],
	["q"] = [[<cmd>close<cr>]],
}
local opts = { noremap = true, silent = true, buffer = true }
for key, value in pairs(kv) do
	k.set("n", key, value, opts)
end
vim.cmd.wincmd("L")
vim.cmd.wincmd("|")
