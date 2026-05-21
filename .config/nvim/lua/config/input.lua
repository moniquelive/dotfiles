local M = {}

local completions = {}

local function is_insert_mode(mode) return mode:match("^[iRsS]") ~= nil end

local function input_width(prompt, default)
	local available = math.max(vim.o.columns - 4, 1)
	local wanted = math.max(vim.fn.strdisplaywidth(prompt) + 4, vim.fn.strdisplaywidth(default) + 2, 24)
	return math.min(wanted, available, 64)
end

local function input_win_config(prompt, value)
	local width = input_width(prompt, value)
	return {
		relative = "editor",
		row = math.max(math.floor((vim.o.lines - 3) * 0.25), 0),
		col = math.max(math.floor((vim.o.columns - width) / 2), 0),
		width = width,
		height = 1,
		border = "rounded",
		style = "minimal",
		title = " " .. prompt .. " ",
		title_pos = "center",
	}
end

local function restore_cursor(win, cursor)
	if not cursor then return end
	if pcall(vim.api.nvim_win_set_cursor, win, cursor) then return end

	local bufnr = vim.api.nvim_win_get_buf(win)
	local row = math.min(math.max(cursor[1], 1), vim.api.nvim_buf_line_count(bufnr))
	local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
	local col = math.min(cursor[2], #line)
	pcall(vim.api.nvim_win_set_cursor, win, { row, col })
end

local function restore_window(win, mode, cursor)
	if not vim.api.nvim_win_is_valid(win) then return end

	vim.api.nvim_set_current_win(win)
	restore_cursor(win, cursor)
	if is_insert_mode(mode) then vim.cmd.startinsert() end
end

local function stopinsert()
	if is_insert_mode(vim.api.nvim_get_mode().mode) then pcall(vim.cmd.stopinsert) end
end

function M.complete(findstart, base)
	local completion = completions[vim.api.nvim_get_current_buf()]
	if not completion then return findstart == 1 and 0 or {} end
	if findstart == 1 then return 0 end

	local ok, matches = pcall(vim.fn.getcompletion, base or "", completion)
	return ok and matches or {}
end

local function input_at_end() return vim.fn.col(".") > #vim.api.nvim_get_current_line() end

local function transpose_chars()
	local pos = vim.fn.col(".")
	local line = vim.api.nvim_get_current_line()

	local pre
	if pos > #line then
		pre = "<Left>"
		pos = pos - 1
	elseif pos <= 1 then
		pre = "<Right>"
		pos = pos + 1
	else
		pre = ""
	end

	return pre .. "<BS><Right>" .. vim.fn.matchstr(line:sub(1, pos - 1), ".$")
end

local function delete_before_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	if col > 0 then vim.fn.setreg("-", line:sub(1, col)) end
	vim.api.nvim_set_current_line(line:sub(col + 1))
	vim.api.nvim_win_set_cursor(0, { 1, 0 })

	return ""
end

local function setup_readline_keymaps(buf)
	local opts = { silent = true }
	local expr_opts = { expr = true, silent = true }

	local function set_map(lhs, rhs, map_opts)
		vim.keymap.set("i", lhs, rhs, vim.tbl_extend("force", { buffer = buf }, map_opts or opts))
	end

	vim.iter({
		{ "<C-a>", "<Home>" },
		{ "<C-x><C-a>", "<C-a>" },
		{ "<C-b>", "<Left>" },
		{ "<C-d>", function() return input_at_end() and "<C-d>" or "<Del>" end, expr_opts },
		{ "<C-e>", function() return vim.fn.pumvisible() == 1 and "<C-e>" or "<End>" end, expr_opts },
		{ "<C-f>", function() return input_at_end() and "<C-f>" or "<Right>" end, expr_opts },
		{ "<C-t>", transpose_chars, expr_opts },
		{ "<C-u>", delete_before_cursor, expr_opts },
		{ "<C-y>", function() return vim.fn.pumvisible() == 1 and "<C-y>" or "<C-r>-" end, expr_opts },
		{ "<M-b>", "<S-Left>" },
		{ "<M-f>", "<S-Right>" },
		{ "<M-d>", "<C-o>dw" },
		{ "<M-n>", "<Down>" },
		{ "<M-p>", "<Up>" },
		{ "<M-BS>", "<C-w>" },
		{ "<M-C-h>", "<C-w>" },
	}):each(function(spec) set_map(spec[1], spec[2], spec[3]) end)
end

function M.input(opts, on_confirm)
	opts = opts or {}
	assert(type(on_confirm) == "function", "vim.ui.input callback must be a function")

	local prompt = vim.trim((opts.prompt or "Input"):gsub(":$", ""))
	local default = opts.default or ""
	local parent_win = vim.api.nvim_get_current_win()
	local parent_cursor = vim.api.nvim_win_get_cursor(parent_win)
	local mode = vim.api.nvim_get_mode().mode
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, input_win_config(prompt, default))
	local done = false
	local resize_group = vim.api.nvim_create_augroup("config_input_" .. buf, { clear = true })

	vim.iter({
		bufhidden = "wipe",
		buftype = "nofile",
		swapfile = false,
		undofile = false,
		completefunc = "v:lua.require'config.input'.complete",
	}):each(function(option, value) vim.bo[buf][option] = value end)

	vim.iter({
		wrap = false,
		number = false,
		relativenumber = false,
		signcolumn = "no",
	}):each(function(option, value) vim.wo[win][option] = value end)

	if opts.completion then completions[buf] = opts.completion end

	local function finish(value)
		if done then return end
		done = true
		completions[buf] = nil
		pcall(vim.api.nvim_del_augroup_by_id, resize_group)
		stopinsert()

		if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
		if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end

		vim.schedule(function()
			restore_window(parent_win, mode, parent_cursor)
			on_confirm(value)
		end)
	end

	vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
		group = resize_group,
		callback = function()
			if not vim.api.nvim_win_is_valid(win) or not vim.api.nvim_buf_is_valid(buf) then return end

			local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
			vim.api.nvim_win_set_config(win, input_win_config(prompt, line))
		end,
	})

	local function confirm()
		local line = vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
		finish(line or "")
	end

	local function complete_next()
		if vim.fn.pumvisible() == 1 then return "<C-n>" end
		return opts.completion and "<C-x><C-u>" or "<Tab>"
	end
	local function cancel() finish(nil) end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { default })
	vim.api.nvim_win_set_cursor(win, { 1, #default })

	vim.iter({
		{ { "n", "i" }, "<CR>", confirm, { silent = true } },
		{ { "n", "i" }, "<Esc>", cancel, { silent = true } },
		{ "n", "q", cancel, { silent = true } },
		{ "i", "<Tab>", complete_next, { expr = true, silent = true } },
		{
			"i",
			"<S-Tab>",
			function() return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>" end,
			{ expr = true, silent = true },
		},
	}):each(
		function(map) vim.keymap.set(map[1], map[2], map[3], vim.tbl_extend("force", { buffer = buf }, map[4])) end
	)
	setup_readline_keymaps(buf)

	vim.cmd("startinsert!")
end

function M.setup() vim.ui.input = M.input end

return M
