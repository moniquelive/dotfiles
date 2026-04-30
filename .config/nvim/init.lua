-- This is MoniqueLive's init.lua file
-- vim:set ts=2 sts=2 sw=2 expandtab:

------------------------------------------------------------ local plugins --
require("config.lazy")
-----------------------------------------------------------------------------

vim.opt.iskeyword:remove({ ".", "#", "-" })
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

local autocomplete_min_chars = 3

local function completion_context()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local line = vim.api.nvim_get_current_line()
	local before_cursor = line:sub(1, cursor[2])
	local prefix = vim.fn.matchstr(before_cursor, [[\k\+$]])
	local trigger_char

	if #before_cursor > #prefix then
		local index = #before_cursor - #prefix
		trigger_char = before_cursor:sub(index, index)
	end

	return vim.fn.strchars(prefix), trigger_char
end

local function has_lsp_trigger_char(char)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		local provider = client.server_capabilities.completionProvider
		if provider and provider.triggerCharacters then
			for _, trigger in ipairs(provider.triggerCharacters) do
				if trigger == char then return true end
			end
		end
	end

	return false
end

local function should_enable_insert_autocomplete()
	if vim.bo.buftype ~= "" then return false, 0, false end

	local prefix_len, trigger_char = completion_context()
	if prefix_len >= autocomplete_min_chars then return true, prefix_len, false end
	if trigger_char and has_lsp_trigger_char(trigger_char) then return true, prefix_len, true end

	return false, prefix_len, false
end

local function update_insert_autocomplete()
	local enabled, prefix_len, from_lsp_trigger = should_enable_insert_autocomplete()
	vim.opt_local.autocomplete = enabled

	if not enabled and vim.fn.pumvisible() == 1 then
		vim.api.nvim_feedkeys(vim.keycode("<C-e>"), "n", false)
		return
	end

	if
		enabled
		and vim.fn.pumvisible() == 0
		and (prefix_len == autocomplete_min_chars or (from_lsp_trigger and prefix_len == 0))
	then
		vim.schedule(function()
			if vim.api.nvim_get_mode().mode ~= "i" then return end
			local still_enabled, still_prefix_len, still_from_trigger = should_enable_insert_autocomplete()
			if not still_enabled or vim.fn.pumvisible() == 1 then return end
			if still_prefix_len == autocomplete_min_chars or (still_from_trigger and still_prefix_len == 0) then
				vim.api.nvim_feedkeys(vim.keycode("<C-n>"), "n", false)
			end
		end)
	end
end

vim.keymap.set({ "i", "s" }, "<Tab>", function()
	local has_supermaven, suggestion = pcall(require, "supermaven-nvim.completion_preview")
	local has_suggestion = has_supermaven and suggestion.has_suggestion()

	if vim.fn.pumvisible() == 1 then
		if has_suggestion and vim.fn.complete_info({ "selected" }).selected == -1 then
			vim.schedule(suggestion.on_accept_suggestion)
			return ""
		end

		return "<C-n>"
	end

	if has_suggestion then
		vim.schedule(suggestion.on_accept_suggestion)
		return ""
	end

	if vim.snippet.active({ direction = 1 }) then
		vim.snippet.jump(1)
		return ""
	end

	return "<Tab>"
end, { expr = true, silent = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
	if vim.fn.pumvisible() == 1 then return "<C-p>" end

	if vim.snippet.active({ direction = -1 }) then
		vim.snippet.jump(-1)
		return ""
	end

	return "<S-Tab>"
end, { expr = true, silent = true })

vim.keymap.set("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 then
		if vim.fn.complete_info({ "selected" }).selected ~= -1 then return "<C-y>" end
		return "<C-e><CR>"
	end

	return "<CR>"
end, { expr = true, silent = true })

vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get, { silent = true })

vim.keymap.set("i", "<C-e>", function()
	local has_supermaven, suggestion = pcall(require, "supermaven-nvim.completion_preview")
	if has_supermaven and suggestion.has_suggestion() then
		suggestion.on_dispose_inlay()
		return ""
	end

	if vim.fn.pumvisible() == 1 then return "<C-e>" end

	return ""
end, { expr = true, silent = true })

vim.keymap.set(
	"n",
	"<C-w>d",
	function()
		vim.diagnostic.open_float({
			scope = "cursor",
			source = "if_many",
			border = "rounded",
		})
	end,
	map_opts
)

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

vim.api.nvim_create_autocmd({ "TextChangedI" }, {
	group = init_lua_grp,
	callback = update_insert_autocomplete,
})

-- stylua: ignore
local cmds = {
  { "QuickFixCmdPost", "*", [[cwindow]] },    -- Open quickfix window when errors are found
  { "FocusLost",       "*", [[silent! wa]] }, -- Autosave on focus lost
  { "VimResized",      "*", [[wincmd =]] },   -- let terminal resize scale the internal windows
	{ "CmdlineChanged", "[:/\\?]", [[silent! call wildtrigger()]] },
	{
		"FileType",
		{ "qf", "fugitive", "fugitiveblame" },
		[[ nnoremap <buffer><silent> q <cmd>close<CR> ]],
	},
}
-- { { "BufRead", "BufNewFile" }, "*.gohtml", [[setlocal filetype="template"]] },
for _, c in ipairs(cmds) do
	vim.api.nvim_create_autocmd(c[1], { pattern = c[2], command = c[3], group = init_lua_grp })
end

-- [[ Highlight on yank ]]
-- See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function() vim.hl.on_yank({ higroup = "Visual", timeout = 300 }) end,
	group = init_lua_grp,
})
