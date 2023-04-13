-- This is MoniqueLive's init.lua file
-- vim:set ts=2 sts=2 sw=2 expandtab:

---------------------------------------------------------------- startify ---
local g = vim.g
g.startify_change_to_dir = 0
g.startify_change_to_vcs_root = 1

g.netrw_altfile = 1 -- <C-6> returns to files

local o = vim.o
o.autoindent = true
o.autoread = true
o.autowriteall = true
o.backspace = "indent,eol,start"
o.colorcolumn = "+1"
o.copyindent = true
o.cursorline = true
o.encoding = "utf-8"
o.equalalways = true
o.errorbells = false
o.expandtab = true
o.history = 1000
o.ignorecase = true
o.incsearch = true
o.joinspaces = false
o.laststatus = 2
o.laststatus = 3
o.mouse = "a"
o.mousehide = true
o.number = true
o.scrolloff = 1
o.shiftround = true
o.shiftwidth = 2
o.showcmd = true
o.showmode = false
o.showtabline = 2
o.signcolumn = "yes"
o.smartcase = true
o.smartindent = true
o.softtabstop = 2
o.splitbelow = true
o.splitright = true
o.swapfile = false
o.switchbuf = "useopen"
o.tabstop = 2
o.termencoding = "utf-8"
o.termguicolors = true
o.textwidth = 0
o.viewoptions = "folds,options,cursor,unix,slash"
o.visualbell = true
o.wrap = false
vim.opt.iskeyword:remove({ ".", "#", "-" })
vim.opt.tags:prepend({ "./.git/tags;" })

vim.scriptencoding = "utf-8"

-- Remaps
local k = vim.keymap
local map_opts = { noremap = true, silent = true }
for i = 0, 5 do
	k.set("n", "z" .. i, function()
		vim.opt_local.foldlevel = i
	end, map_opts)
end
k.set("n", "<leader><leader>", "<c-^>", map_opts)

-- system clipboard's copy/paste
k.set("v", "<leader>y", '"+y', map_opts)
k.set("n", "<leader>y", '"+y', map_opts)
k.set("n", "<leader>Y", '"+Y', map_opts)
k.set("n", "<leader>p", '"+p', map_opts)
k.set("n", "<leader>P", '"+P', map_opts)
k.set("n", "<D-v>", '"+p', map_opts)
k.set("n", "<D-V>", '"+P', map_opts)

-- See http://stevelosh.com/blog/2010/09/coming-home-to-vim
k.set("n", "/", [[/\v]])
k.set("v", "/", [[/\v]])

-- Disable highlight when <leader><cr> is pressed
k.set("", "<leader><cr>", ":noh<cr>", map_opts)

-- Move around splits with <c-hjkl>
k.set("n", "<c-j>", "<c-w>j", map_opts)
k.set("n", "<c-k>", "<c-w>k", map_opts)
k.set("n", "<c-h>", "<c-w>h", map_opts)
k.set("n", "<c-l>", "<c-w>l", map_opts)
k.set("n", "<leader>w", "<C-w>v<C-w>l", map_opts)
k.set("n", "<leader>l", "<C-l>", map_opts)

-- Resize splits
k.set("n", "<C-S-j>", "<c-w>+", map_opts)
k.set("n", "<C-S-k>", "<c-w>-", map_opts)
k.set("n", "<m-,>", "<c-w><", map_opts)
k.set("n", "<m-.>", "<c-w>>", map_opts)

-- Open window below instead of above"
k.set("n", "<c-w>N", ":let sb=&sb<BAR>set sb<BAR>new<BAR>let &sb=sb<CR>", map_opts)

-- Vertical equivalent of c-w-n and c-w-N"
k.set("n", "<c-w>v", ":vnew<CR>", map_opts)
k.set("n", "<c-w>V", ":let spr=&spr<BAR>set nospr<BAR>vnew<BAR>let &spr=spr<CR>", map_opts)

-- Easier split resizing (shift - and shift +)
k.set("n", "_", "<c-w>-", map_opts)
k.set("n", "+", "<c-w>+", map_opts)

-- neovim, dont reinvent the wheel <3
k.set("n", "Y", "yy", map_opts)
vim.o.hidden = false

-- Commentary
k.set("n", "<leader>/", "<Plug>CommentaryLine")
k.set("x", "/", "<Plug>Commentary")
k.set("x", "<D-/>", "<Plug>Commentary")
k.set("i", "<D-/>", "<Plug>Commentary")
k.set("n", "<D-/>", "<Plug>CommentaryLine")

-- Allow saving of files as sudo when I forgot to start vim using sudo.
vim.cmd([[cmap w!! w !sudo tee > /dev/null %]])

-- Subtle search highlights
vim.cmd([[highlight Search ctermbg=black ctermfg=yellow term=underline]])
vim.cmd([[highlight Comment cterm=italic gui=italic]])

local init_lua_grp = vim.api.nvim_create_augroup("init_lua", { clear = true })
vim.api.nvim_create_autocmd("BufWinEnter", { pattern = "*", command = [[normal zi]], group = init_lua_grp })
vim.api.nvim_create_autocmd("FileType", { pattern = "help", command = [[wincmd L]], group = init_lua_grp })
vim.api.nvim_create_autocmd("FileType", { pattern = "gitcommit", command = [[set spell]], group = init_lua_grp })
vim.api.nvim_create_autocmd("FocusLost", { pattern = "*", command = [[silent! wa]], group = init_lua_grp }) -- Autosave on focus lost
vim.api.nvim_create_autocmd("VimResized", { pattern = "*", command = [[wincmd =]], group = init_lua_grp }) -- let terminal resize scale the internal windows

local myvimrc = vim.fn.expand("$MYVIMRC")
vim.api.nvim_create_autocmd(
	{ "BufRead", "BufNewFile" },
	{ pattern = myvimrc, command = "source " .. myvimrc, group = init_lua_grp }
)

vim.api.nvim_create_autocmd(
	{ "BufRead", "BufNewFile" },
	{ pattern = "*.asm", command = [[setlocal filetype="nasm"]], group = init_lua_grp }
)
vim.api.nvim_create_autocmd(
	{ "BufRead", "BufNewFile" },
	{ pattern = "*.gohtml", command = [[setlocal filetype="template"]], group = init_lua_grp }
)

vim.api.nvim_create_autocmd(
	"FileType",
	{ pattern = "ruby", command = [[ia fsl # frozen_string_literal: true]], group = init_lua_grp }
)

vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	callback = function()
		local kv = {
			["<CR>"] = "<C-]>",
			["<BS>"] = "<C-T>",
			["o"] = [[/'\l\{2,\}'<CR>]],
			["O"] = [[?'\l\{2,\}'<CR>]],
			["s"] = [[/\|\zs\S\+\ze\|<CR>]],
			["S"] = [[?\|\zs\S\+\ze\|<CR>]],
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
	vim.api.nvim_create_autocmd("InsertEnter", { pattern = "*", command = [[set timeoutlen=0]], group = init_lua_grp })
	vim.api.nvim_create_autocmd("InsertLeave", { pattern = "*", command = [[set tm=1000]], group = init_lua_grp })
end

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = init_lua_grp,
	pattern = "*",
})

require("plugins")
require("restore_cursor")

require("user.lualine")
require("user.notify")
require("user.toggleterm")
require("user.refactoring")
require("user.tree")
require("user.mason")
require("user.treesitter-refactor")
require("user.treesitter-textobjects")
require("user.treesitter-rainbow")
require("user.treesitter-context")
require("user.treesitter")
require("user.cmp")
require("user.haskell-tools")
require("user.telescope")
