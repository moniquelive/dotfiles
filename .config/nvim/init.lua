-- This is MoniqueLive's init.lua file
-- vim:set ts=2 sts=2 sw=2 expandtab:

require("config.lazy")

-----------------------------------------------------------------------------

vim.g.netrw_altfile = 1 -- <C-6> returns to files

vim.opt.iskeyword:remove({ ".", "#", "-" })
vim.opt.tags:prepend({ "./.git/tags;" })

vim.scriptencoding = "utf-8"

local opts = {
  --backspace = "indent,eol,start",
  --termencoding = "utf-8",
  --termguicolors = true,
  autoindent = true,
  autoread = true,
  autowriteall = true,
  breakindent = true,
  colorcolumn = "+1",
  copyindent = true,
  cursorline = true,
  encoding = "utf-8",
  equalalways = true,
  errorbells = false,
  expandtab = true,
  foldenable = true,
  foldlevel = 99,
  foldmethod = "expr",
  foldexpr = "v:lua.vim.treesitter.foldexpr()",
  foldtext = "",
  foldcolumn = "0",
  grepprg = [[rg --vimgrep --no-heading --smart-case]],
  grepformat = "%f:%l:%c:%m",
  hidden = false,
  history = 1000,
  ignorecase = true,
  incsearch = true,
  inccommand = "split",
  joinspaces = false,
  laststatus = 3,
  listchars = { tab = "» ", trail = "·", nbsp = "␣" },
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
  textwidth = 0,
  undofile = true,
  updatetime = 250,
  viewoptions = "folds,options,cursor,unix,slash",
  visualbell = true,
  winborder = 'rounded',
  wrap = false,
}
for key, value in pairs(opts) do
  vim.opt[key] = value
end

-- Temp hack
vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopeFindPre",
  callback = function()
    vim.opt_local.winborder = "none"
    vim.api.nvim_create_autocmd("WinLeave", {
      once = true,
      callback = function() vim.opt_local.winborder = "rounded" end,
    })
  end,
})

-- Keymaps
local k = vim.keymap

-- See http://stevelosh.com/blog/2010/09/coming-home-to-vim
vim.o.magic = true
-- k.set("n", "/", [[/\v]])
-- k.set("v", "/", [[/\v]])

local map_opts = { noremap = true, silent = true }
for i = 0, 5 do
  k.set("n", "z" .. i, function() vim.opt_local.foldlevel = i end, map_opts)
end

local maps = {
  { "n", "<leader><leader>", "<c-^>" },
  { "n", "yow",              "<cmd>set wrap!<cr>" },
  { "n", "yon",              "<cmd>set number!<cr>" },
  -- system clipboard's copy/paste
  { "v", "<leader>y",        '"+y' },
  { "n", "<leader>y",        '"+y' },
  { "n", "<leader>Y",        '"+Y' },
  { "n", "<leader>p",        '"+p' },
  { "n", "<leader>P",        '"+P' },
  { "n", "<D-v>",            '"+p' },
  { "n", "<D-V>",            '"+P' },
  -- Disable highlight when <leader><cr> is pressed
  { "n", "<esc>",            "<cmd>noh<CR>" },
  { "",  "<leader><cr>",     "<cmd>noh<CR>" },
  -- Move around splits with <c-hjkl>
  { "n", "<c-j>",            "<c-w>j" },
  { "n", "<c-k>",            "<c-w>k" },
  { "n", "<c-h>",            "<c-w>h" },
  { "n", "<c-l>",            "<c-w>l" },
  { "n", "<leader>w",        "<C-w>v<C-w>l" },
  { "n", "<leader>l",        "<C-l>" },
  -- Resize splits
  { "n", "<c-s-j>",          "<c-w>+" },
  { "n", "<c-s-k>",          "<c-w>-" },
  { "n", "<m-,>",            "<c-w><" },
  { "n", "<m-.>",            "<c-w>>" },
  -- Open window below instead of above"
  { "n", "<c-w>N",           "<cmd>let sb=&sb<BAR>set sb<BAR>new<BAR>let &sb=sb<CR>" },
  -- Vertical equivalent of c-w-n and c-w-N"
  { "n", "<c-w>v",           "<cmd>vnew<CR>" },
  { "n", "<c-w>V",           "<cmd>let spr=&spr<BAR>set nospr<BAR>vnew<BAR>let &spr=spr<CR>" },
  -- Easier split resizing (shift - and shift +)
  { "n", "_",                "<c-w>-" },
  { "n", "+",                "<c-w>+" },
  -- neovim, dont reinvent the wheel <3
  { "n", "Y",                "yy" },
  -- default run behavior
  { "n", "<F17>",            [[<cmd>echom "running..."|silent make!|echon ''<CR>]] },
  { "n", "<F5>",             [[<cmd>make!<CR>]] },
  { "n", "<tab>",            "za" },
}
for _, m in ipairs(maps) do
  k.set(m[1], m[2], m[3], map_opts)
end

-- Allow saving of files as sudo when I forgot to start vim using sudo.
k.set("c", "w!!", [[w !sudo tee > /dev/null %]])

-- Subtle search highlights
vim.cmd([[highlight Search ctermbg=black ctermfg=yellow term=underline]])
vim.cmd([[highlight Comment cterm=italic gui=italic]])

-- LSP hover colors
vim.cmd([[highlight LspReferenceText cterm=bold ctermbg=gray guibg=#404010]])
vim.cmd([[highlight LspReferenceRead cterm=bold ctermbg=green guibg=#104010]])
vim.cmd([[highlight LspReferenceWrite cterm=bold ctermbg=red guibg=#401010]])

local init_lua_grp = vim.api.nvim_create_augroup("init_lua", { clear = true })
local au = vim.api.nvim_create_autocmd
local myvimrc = vim.fn.expand("$MYVIMRC")
local cmds = {
  { "QuickFixCmdPost", "*", [[copen]] },      -- Open quickfix window when errors are found
  { "FocusLost",       "*", [[silent! wa]] }, -- Autosave on focus lost
  { "VimResized",      "*", [[wincmd =]] },   -- let terminal resize scale the internal windows
  {
    "FileType",
    { "qf", "fugitive", "fugitiveblame", "netrw" },
    [[ nnoremap <buffer><silent> q <cmd>close<CR> ]],
  },
  { { "BufRead", "BufNewFile" }, myvimrc, "source " .. myvimrc },
}
-- { { "BufRead", "BufNewFile" }, "*.gohtml", [[setlocal filetype="template"]] },
for _, c in ipairs(cmds) do
  au(c[1], { pattern = c[2], command = c[3], group = init_lua_grp })
end

if vim.fn.has("gui_running") == 0 then
  vim.o.ttimeoutlen = 10
  vim.o.lazyredraw = true
  au("InsertEnter", { pattern = "*", command = [[set timeoutlen=0]], group = init_lua_grp })
  au("InsertLeave", { pattern = "*", command = [[set tm=1000]], group = init_lua_grp })
end

-- [[ Highlight on yank ]]
-- See `:help vim.hl.on_yank()`
vim.cmd([[ autocmd TextYankPost * silent! lua vim.hl.on_yank {higroup='Visual', timeout=300} ]])

-- Status Line
vim.o.statusline = [[%h%m%r%=%<%f%=%b 0x%B  %l,%c%V %P]]

-- Grep: https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3
vim.cmd([[
function! Grep(...)
  return system(join([&grepprg] + [expandcmd(join(a:000, ' '))], ' '))
endfunction

command! -nargs=+ -complete=file_in_path -bar Grep  cgetexpr Grep(<f-args>)
command! -nargs=+ -complete=file_in_path -bar LGrep lgetexpr Grep(<f-args>)

cnoreabbrev <expr> gr    (getcmdtype() ==# ':' && getcmdline() ==# 'gr')  ? 'Grep'  : 'grep'
cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'

augroup quickfix
  autocmd!
  autocmd QuickFixCmdPost cgetexpr cwindow
  autocmd QuickFixCmdPost lgetexpr lwindow
augroup END
]])
