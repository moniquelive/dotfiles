local cfg = vim.fn.stdpath("config")
dofile(vim.fn.expand(cfg .. "/after/ftplugin/common.lua"))

local opts = { noremap = true, silent = true, buffer = true }

vim.keymap.set("n", "<M-]>", "<C-]>", opts)
vim.keymap.set("n", "<M-[>", "<C-T>", opts)
vim.keymap.set("n", "o", [[/'\l\{2,\}'<CR>]], opts)
vim.keymap.set("n", "O", [[?'\l\{2,\}'<CR>]], opts)
vim.keymap.set("n", "s", [[/\|\zs\S\+\ze\|<CR>]], opts)
vim.keymap.set("n", "S", [[?\|\zs\S\+\ze\|<CR>]], opts)
vim.keymap.set("n", "q", [[<cmd>close<cr>]], opts)

vim.cmd.wincmd("L")
vim.cmd.wincmd("|")
