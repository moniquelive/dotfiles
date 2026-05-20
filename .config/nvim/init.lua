-- This is MoniqueLive's init.lua file
-- vim:set ts=2 sts=2 sw=2 expandtab:

------------------------------------------------------------ local plugins --
require("config.lazy")
-- Experimental core cmdline/messages UI.
require("vim._core.ui2").enable()
-----------------------------------------------------------------------------

vim.opt.iskeyword:remove({ ".", "#", "-" })
vim.opt.shortmess:append("I")
vim.opt.tags:prepend({ "./.git/tags;" })
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

--vim.opt.backspace = "indent,eol,start"
vim.o.autoindent = true
vim.o.autoread = true
vim.o.autowriteall = true
vim.o.autocomplete = true
vim.o.complete = ".,w,b,u,t,o"
vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.wildmode = "noselect:lastused,full"
vim.o.wildoptions = "pum,fuzzy,tagfile"
vim.o.breakindent = true
vim.o.colorcolumn = "+1"
vim.o.cmdheight = 0
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

require("config.mappings").setup()

-- Subtle search highlights
vim.cmd([[highlight Search ctermbg=black ctermfg=yellow term=underline]])
-- Italic comments
vim.cmd([[highlight Comment cterm=italic gui=italic]])

-- LSP hover colors
vim.cmd([[highlight LspReferenceText cterm=bold ctermbg=gray guibg=#404010]])
vim.cmd([[highlight LspReferenceRead cterm=bold ctermbg=green guibg=#104010]])
vim.cmd([[highlight LspReferenceWrite cterm=bold ctermbg=red guibg=#401010]])

local init_lua_grp = vim.api.nvim_create_augroup("init_lua", { clear = true })

vim.iter({
	-- { { "BufRead", "BufNewFile" }, "*.gohtml", [[setlocal filetype="template"]] },
	{ "QuickFixCmdPost", "*", [[cwindow]] }, -- Open quickfix window when errors are found
	{ "FocusLost", "*", [[silent! wa]] }, -- Autosave on focus lost
	{ "VimResized", "*", [[wincmd =]] }, -- let terminal resize scale the internal windows
	{ "CmdlineChanged", "[:/\\?]", [[silent! call wildtrigger()]] },
}):each(
	function(cmd) vim.api.nvim_create_autocmd(cmd[1], { pattern = cmd[2], command = cmd[3], group = init_lua_grp }) end
)

-- [[ Highlight on yank ]]
-- See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function() vim.hl.on_yank({ higroup = "Visual", timeout = 300 }) end,
	group = init_lua_grp,
})
