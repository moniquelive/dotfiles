-- This is MoniqueLive's init.lua file
-- vim:set ts=2 sts=2 sw=2 expandtab:

require("restore_cursor")

-----------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
	checker = {
		enabled = true,
	},
	defaults = {
		lazy = true,
	},
})
-----------------------------------------------------------------------------

vim.g.startify_change_to_dir = 0
vim.g.startify_change_to_vcs_root = 1
vim.g.netrw_altfile = 1 -- <C-6> returns to files

vim.opt.iskeyword:remove({ ".", "#", "-" })
vim.opt.tags:prepend({ "./.git/tags;" })

vim.scriptencoding = "utf-8"

local opts = {
	autoindent = true,
	autoread = true,
	autowriteall = true,
	backspace = "indent,eol,start",
	colorcolumn = "+1",
	copyindent = true,
	cursorline = true,
	encoding = "utf-8",
	equalalways = true,
	errorbells = false,
	expandtab = true,
	foldenable = false,
	hidden = false,
	history = 1000,
	ignorecase = true,
	incsearch = true,
	joinspaces = false,
	laststatus = 3,
	mouse = "a",
	mousehide = true,
	number = true,
	scrolloff = 1,
	shiftround = true,
	shiftwidth = 2,
	showcmd = true,
	showmode = false,
	showtabline = 1,
	signcolumn = "yes",
	smartcase = true,
	smartindent = true,
	softtabstop = 2,
	spelllang = "pt_br,en_us",
	splitbelow = true,
	splitright = true,
	startofline = true,
	swapfile = false,
	switchbuf = "useopen",
	tabstop = 2,
	termencoding = "utf-8",
	termguicolors = true,
	textwidth = 0,
	undofile = true,
	viewoptions = "folds,options,cursor,unix,slash",
	visualbell = true,
	wrap = false,
}
for key, value in pairs(opts) do
	vim.opt[key] = value
end

-- Keymaps
local k = vim.keymap

-- See http://stevelosh.com/blog/2010/09/coming-home-to-vim
k.set("n", "/", [[/\v]])
k.set("v", "/", [[/\v]])

-- Commentary
k.set("n", "<leader>/", "<Plug>CommentaryLine")
k.set("x", "/", "<Plug>Commentary")
k.set("x", "<D-/>", "<Plug>Commentary")
k.set("i", "<D-/>", "<Plug>Commentary")
k.set("n", "<D-/>", "<Plug>CommentaryLine")

local map_opts = { noremap = true, silent = true }
for i = 0, 5 do
	k.set("n", "z" .. i, function()
		vim.opt_local.foldlevel = i
	end, map_opts)
end

local maps = {
	{ "n", "<leader><leader>", "<c-^>" },
	-- system clipboard's copy/paste
	{ "v", "<leader>y", '"+y' },
	{ "n", "<leader>y", '"+y' },
	{ "n", "<leader>Y", '"+Y' },
	{ "n", "<leader>p", '"+p' },
	{ "n", "<leader>P", '"+P' },
	{ "n", "<D-v>", '"+p' },
	{ "n", "<D-V>", '"+P' },
	-- Disable highlight when <leader><cr> is pressed
	{ "", "<leader><cr>", ":noh<cr>" },
	-- Move around splits with <c-hjkl>
	{ "n", "<c-j>", "<c-w>j" },
	{ "n", "<c-k>", "<c-w>k" },
	{ "n", "<c-h>", "<c-w>h" },
	{ "n", "<c-l>", "<c-w>l" },
	{ "n", "<leader>w", "<C-w>v<C-w>l" },
	{ "n", "<leader>l", "<C-l>" },
	-- Resize splits
	{ "n", "<c-s-j>", "<c-w>+" },
	{ "n", "<c-s-k>", "<c-w>-" },
	{ "n", "<m-,>", "<c-w><" },
	{ "n", "<m-.>", "<c-w>>" },
	-- Open window below instead of above"
	{ "n", "<c-w>N", ":let sb=&sb<BAR>set sb<BAR>new<BAR>let &sb=sb<CR>" },
	-- Vertical equivalent of c-w-n and c-w-N"
	{ "n", "<c-w>v", ":vnew<CR>" },
	{ "n", "<c-w>V", ":let spr=&spr<BAR>set nospr<BAR>vnew<BAR>let &spr=spr<CR>" },
	-- Easier split resizing (shift - and shift +)
	{ "n", "_", "<c-w>-" },
	{ "n", "+", "<c-w>+" },
	-- neovim, dont reinvent the wheel <3
	{ "n", "Y", "yy" },
}
for _, m in ipairs(maps) do
	k.set(m[1], m[2], m[3], map_opts)
end

-- Allow saving of files as sudo when I forgot to start vim using sudo.
k.set("c", "w!!", [[w !sudo tee > /dev/null %]])

-- Subtle search highlights
vim.cmd([[highlight Search ctermbg=black ctermfg=yellow term=underline]])
vim.cmd([[highlight Comment cterm=italic gui=italic]])

local init_lua_grp = vim.api.nvim_create_augroup("init_lua", { clear = true })
local au = vim.api.nvim_create_autocmd
local myvimrc = vim.fn.expand("$MYVIMRC")
local cmds = {
	{ "FileType", "help", [[wincmd L]] },
	{ "FileType", "gitcommit", [[set spell]] },
	{ "FileType", "ruby", [[ia fsl # frozen_string_literal: true]] },
	{ "FocusLost", "*", [[silent! wa]] }, -- Autosave on focus lost
	{ "VimResized", "*", [[wincmd =]] }, -- let terminal resize scale the internal windows
	{ { "BufRead", "BufNewFile" }, myvimrc, "source " .. myvimrc },
	{ { "BufRead", "BufNewFile" }, "*.asm", [[setlocal filetype="nasm"]] },
	{ { "BufRead", "BufNewFile" }, "*.gohtml", [[setlocal filetype="template"]] },
}
for _, c in ipairs(cmds) do
	au(c[1], { pattern = c[2], command = c[3], group = init_lua_grp })
end

vim.cmd([[autocmd FileType help,qf,fugitive,fugitiveblame,netrw nnoremap <buffer><silent> q <cmd>close<CR>]])
au("FileType", {
	pattern = "help",
	callback = function()
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
	end,
	group = init_lua_grp,
})

if vim.fn.has("gui_running") == 0 then
	vim.o.ttimeoutlen = 10
	vim.o.lazyredraw = true
	au("InsertEnter", { pattern = "*", command = [[set timeoutlen=0]], group = init_lua_grp })
	au("InsertLeave", { pattern = "*", command = [[set tm=1000]], group = init_lua_grp })
end

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
au("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank()
	end,
	group = init_lua_grp,
})
