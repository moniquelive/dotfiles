-- This is MoniqueLive's init.lua file
-- vim:set ts=2 sts=2 sw=2 expandtab:

------------------------------------------------------------ local plugins --
require("config.lazy")
-- Experimental core cmdline/messages UI.
require("vim._core.ui2").enable()
require("config.input").setup()
-----------------------------------------------------------------------------

vim.opt.iskeyword:remove({ ".", "#", "-" })
vim.opt.shortmess:append("I")
vim.opt.tags:prepend({ "./.git/tags;" })
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

--vim.opt.backspace = "indent,eol,start"
vim.iter({
	autoindent = true,
	autoread = true,
	autowriteall = true,
	autocomplete = true,
	complete = ".,w,b,u,t,o",
	completeopt = "menuone,noselect,popup,fuzzy",
	wildmode = "noselect:lastused,full",
	wildoptions = "pum,fuzzy,tagfile",
	breakindent = true,
	colorcolumn = "+1",
	cmdheight = 0,
	copyindent = true,
	cursorline = true,
	encoding = "utf-8",
	equalalways = true,
	errorbells = false,
	expandtab = true,
	foldcolumn = "0",
	foldenable = true,
	foldexpr = "v:lua.vim.treesitter.foldexpr()",
	foldlevel = 99,
	foldmethod = "expr",
	foldtext = "",
	grepformat = "%f:%l:%c:%m",
	grepprg = [[rg --vimgrep --no-heading --smart-case]],
	hidden = false,
	history = 1000,
	ignorecase = true,
	inccommand = "split",
	incsearch = true,
	joinspaces = false,
	laststatus = 3,
	lazyredraw = true,
	magic = true,
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
	ttimeoutlen = 10,
	undofile = true,
	updatetime = 250,
	viewoptions = "folds,options,cursor,unix,slash",
	visualbell = true,
	winborder = "rounded",
	wrap = false,
}):each(function(option, value) vim.o[option] = value end)

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
