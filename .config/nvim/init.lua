-- This is MoniqueLive's init.lua file
-- vim:set ts=2 sts=2 sw=2 expandtab:

------------------------------------------------------------ local plugins --
require("config.lazy")
require("config.diagnostics").setup({ keymap = "<c-w>d" })
-----------------------------------------------------------------------------

vim.g.netrw_altfile = 1 -- <C-6> returns to files

vim.opt.iskeyword:remove({ ".", "#", "-" })
vim.opt.tags:prepend({ "./.git/tags;" })
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.scriptencoding = "utf-8"

--vim.opt.backspace = "indent,eol,start"
vim.o.autoindent = true
vim.o.autoread = true
vim.o.autowriteall = true
vim.o.breakindent = true
vim.o.colorcolumn = "+1"
vim.o.copyindent = true
vim.o.cursorline = true
vim.o.encoding = "utf-8"
vim.o.equalalways = true
vim.o.errorbells = false
vim.o.expandtab = true
vim.o.foldcolumn = "0"
vim.o.foldenable = true
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.foldtext = ""
vim.o.grepformat = "%f:%l:%c:%m"
vim.o.grepprg = [[rg --vimgrep --no-heading --smart-case]]
vim.o.hidden = false
vim.o.history = 1000
vim.o.ignorecase = true
vim.o.inccommand = "split"
vim.o.incsearch = true
vim.o.joinspaces = false
vim.o.laststatus = 3
vim.o.lazyredraw = true
vim.o.magic = true
vim.o.mouse = "a"
vim.o.mousehide = true
vim.o.number = true
vim.o.scrolloff = 1
vim.o.shiftround = true
vim.o.shiftwidth = 2
vim.o.showcmd = true
vim.o.showmode = false
vim.o.showtabline = 1
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.softtabstop = 2
vim.o.spelllang = "pt_br,en_us"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.startofline = true
vim.o.statusline = table.concat({ " %t", "%r", "%m", "%=", "%{&filetype}", " %2p%%", " %3l:%-2c " })
vim.o.swapfile = false
vim.o.switchbuf = "useopen"
vim.o.tabstop = 2
vim.o.textwidth = 0
vim.o.ttimeoutlen = 10
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.viewoptions = "folds,options,cursor,unix,slash"
vim.o.visualbell = true
vim.o.winborder = "rounded"
vim.o.wrap = false

local map_opts = { noremap = true, silent = true }
for i = 0, 5 do
	vim.keymap.set("n", "z" .. i, function() vim.opt_local.foldlevel = i end, map_opts)
end

-- stylua: ignore
local maps = {
  { "n",          "<leader><leader>", "<c-^>" },
  -- system clipboard's copy/paste
  { { "n", "v" }, "<leader>y",        '"+y' },
  { { "n", "v" }, "<leader>Y",        '"+Y' },
  { { "n", "v" }, "<leader>d",        '"+d' },
  { "n",          "<leader>p",        '"+p' },
  { "n",          "<leader>P",        '"+P' },
  { "n",          "<D-v>",            '"+p' },
  { "n",          "<D-V>",            '"+P' },
  -- Disable highlight when <leader><cr> is pressed
  { "n",          "<esc>",            "<cmd>noh<CR>" },
  { "",           "<leader><cr>",     "<cmd>noh<CR>" },
  -- Move around splits with <c-hjkl>
  { "n",          "<c-j>",            "<c-w>j" },
  { "n",          "<c-k>",            "<c-w>k" },
  { "n",          "<c-h>",            "<c-w>h" },
  { "n",          "<c-l>",            "<c-w>l" },
  { "n",          "<leader>w",        "<C-w>v<C-w>l" },
  { "n",          "<leader>l",        "<C-l>" },
  -- Resize splits
  { "n",          "<c-s-j>",          "<c-w>+" },
  { "n",          "<c-s-k>",          "<c-w>-" },
  { "n",          "<m-,>",            "<c-w><" },
  { "n",          "<m-.>",            "<c-w>>" },
  -- Open window below instead of above"
  { "n",          "<c-w>N",           "<cmd>above new<CR>" },
  -- Vertical equivalent of c-w-n and c-w-N"
  { "n",          "<c-w>v",           "<cmd>vnew<CR>" },
  { "n",          "<c-w>V",           "<cmd>let spr=&spr<BAR>set nospr<BAR>vnew<BAR>let &spr=spr<CR>" },
  -- Easier split resizing (shift - and shift +)
  { "n",          "_",                "<c-w>-" },
  { "n",          "+",                "<c-w>+" },
  -- neovim, dont reinvent the wheel <3
  { "n",          "Y",                "yy" },
  -- default run behavior
  { "n",          "<F17>",            [[<cmd>echom "running..."|silent make!|echon ''<CR>]] },
  { "n",          "<F5>",             [[<cmd>make!<CR>]] },
  { "n",          "<tab>",            "za" },
}
for _, m in ipairs(maps) do
	vim.keymap.set(m[1], m[2], m[3], map_opts)
end

-- Allow saving of files as sudo when I forgot to start vim using sudo.
vim.keymap.set("c", "w!!", [[w !sudo tee > /dev/null %]])

-- Subtle search highlights
vim.cmd([[highlight Search ctermbg=black ctermfg=yellow term=underline]])
-- Italic comments
vim.cmd([[highlight Comment cterm=italic gui=italic]])

-- LSP hover colors
vim.cmd([[highlight LspReferenceText cterm=bold ctermbg=gray guibg=#404010]])
vim.cmd([[highlight LspReferenceRead cterm=bold ctermbg=green guibg=#104010]])
vim.cmd([[highlight LspReferenceWrite cterm=bold ctermbg=red guibg=#401010]])

local init_lua_grp = vim.api.nvim_create_augroup("init_lua", { clear = true })
-- stylua: ignore
local cmds = {
  { "QuickFixCmdPost", "*", [[copen]] },      -- Open quickfix window when errors are found
  { "FocusLost",       "*", [[silent! wa]] }, -- Autosave on focus lost
  { "VimResized",      "*", [[wincmd =]] },   -- let terminal resize scale the internal windows
  {
    "FileType",
    { "qf", "fugitive", "fugitiveblame", "netrw" },
    [[ nnoremap <buffer><silent> q <cmd>close<CR> ]],
  },
}
-- { { "BufRead", "BufNewFile" }, "*.gohtml", [[setlocal filetype="template"]] },
for _, c in ipairs(cmds) do
	vim.api.nvim_create_autocmd(c[1], { pattern = c[2], command = c[3], group = init_lua_grp })
end

-- enable treesitter when available
vim.api.nvim_create_autocmd("BufRead", {
	pattern = "*",
	callback = function(args)
		if nil == vim.treesitter.get_parser(args.buf, nil, { error = false }) then return end
		vim.treesitter.start(args.buf)
		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	end,
	group = init_lua_grp,
})

-- [[ Highlight on yank ]]
-- See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function() vim.hl.on_yank({ higroup = "Visual", timeout = 300 }) end,
	group = init_lua_grp,
})
