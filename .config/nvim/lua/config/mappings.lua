local M = {}

local unpack_fn = table.unpack or unpack
local map_defaults = { noremap = true, silent = true }
local is_list = vim.islist or vim.tbl_islist

local function set_map(modes, lhs, rhs, opts)
	vim.keymap.set(modes, lhs, rhs, vim.tbl_extend("force", map_defaults, opts or {}))
end

local function as_list(value)
	if value == nil then return {} end
	return is_list(value) and value or { value }
end

local function diagnostics_is_enabled()
	local ok, enabled = pcall(vim.diagnostic.is_enabled, { bufnr = 0 })
	if ok then return enabled end
	return true
end

local function set_diagnostics_enabled(enabled)
	if pcall(vim.diagnostic.enable, enabled, { bufnr = 0 }) then return end

	if enabled then
		pcall(vim.diagnostic.enable, 0)
		return
	end

	if type(vim.diagnostic.disable) == "function" then pcall(vim.diagnostic.disable, 0) end
end

local function inlay_hints_is_enabled()
	local inlay_hint = vim.lsp.inlay_hint
	if type(inlay_hint) ~= "table" or type(inlay_hint.is_enabled) ~= "function" then return false end

	local ok, enabled = pcall(inlay_hint.is_enabled, { bufnr = 0 })
	if ok then return enabled end

	ok, enabled = pcall(inlay_hint.is_enabled, 0)
	return ok and enabled or false
end

local function set_inlay_hints_enabled(enabled)
	local inlay_hint = vim.lsp.inlay_hint
	if type(inlay_hint) ~= "table" or type(inlay_hint.enable) ~= "function" then return end

	if pcall(inlay_hint.enable, enabled, { bufnr = 0 }) then return end

	pcall(inlay_hint.enable, 0, enabled)
end

local function codelens_is_enabled()
	local codelens = vim.lsp.codelens
	if type(codelens) ~= "table" or type(codelens.is_enabled) ~= "function" then return false end

	local ok, enabled = pcall(codelens.is_enabled, { bufnr = 0 })
	if ok then return enabled end

	ok, enabled = pcall(codelens.is_enabled, 0)
	return ok and enabled or false
end

local function set_codelens_enabled(enabled)
	local codelens = vim.lsp.codelens
	if type(codelens) ~= "table" or type(codelens.enable) ~= "function" then return end

	if pcall(codelens.enable, enabled, { bufnr = 0 }) then return end

	pcall(codelens.enable, 0, enabled)
end

local function toggle_codelens()
	set_codelens_enabled(not codelens_is_enabled())
	local status = codelens_is_enabled() and "enabled" or "disabled"
	vim.notify(string.format("CodeLens %s", status), vim.log.levels.INFO)
end

local function compare_position(lhs, rhs)
	if lhs.file ~= rhs.file then return lhs.file < rhs.file and -1 or 1 end
	if lhs.lnum ~= rhs.lnum then return lhs.lnum < rhs.lnum and -1 or 1 end
	if lhs.col ~= rhs.col then return lhs.col < rhs.col and -1 or 1 end
	return 0
end

local function compare_buffer_position(lhs, rhs)
	if lhs.row ~= rhs.row then return lhs.row < rhs.row and -1 or 1 end
	if lhs.col ~= rhs.col then return lhs.col < rhs.col and -1 or 1 end
	return 0
end

local function collect_reference_locations(results)
	local locations = {}
	local seen = {}

	for client_id, response in pairs(results or {}) do
		if not response.err and response.result then
			local client = vim.lsp.get_client_by_id(tonumber(client_id))
			local encoding = client and client.offset_encoding or "utf-16"
			local items = vim.lsp.util.locations_to_items(as_list(response.result), encoding)

			vim.iter(items):each(function(item)
				if item.user_data == nil then return end

				local file = vim.fn.fnamemodify(item.filename, ":p")
				local key = string.format("%s:%d:%d", file, item.lnum, item.col)
				if seen[key] then return end

				seen[key] = true
				locations[#locations + 1] = {
					file = file,
					lnum = item.lnum,
					col = item.col,
					location = item.user_data,
					encoding = encoding,
				}
			end)
		end
	end

	table.sort(locations, function(lhs, rhs) return compare_position(lhs, rhs) < 0 end)

	return locations
end

local function find_next_index(locations, current)
	local index = vim.iter(locations)
		:enumerate()
		:find(function(_, location) return compare_position(location, current) > 0 end)
	return index
end

local function find_previous_index(locations, current)
	return vim.iter(locations):enumerate():fold(nil, function(acc, index, location)
		if compare_position(location, current) < 0 then return index end
		return acc
	end)
end

local function jump_reference(direction)
	local origin_buf = vim.api.nvim_get_current_buf()
	local origin_win = vim.api.nvim_get_current_win()
	local origin_cursor = vim.api.nvim_win_get_cursor(origin_win)
	local current = {
		file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(origin_buf), ":p"),
		lnum = origin_cursor[1],
		col = origin_cursor[2] + 1,
	}
	local steps = math.max(math.abs(direction), 1)
	local clients = vim.iter(vim.lsp.get_clients({ bufnr = origin_buf }))
		:filter(function(client) return client:supports_method("textDocument/references", origin_buf) end)
		:totable()
	if #clients == 0 then
		vim.notify("No LSP client supports references", vim.log.levels.INFO)
		return
	end

	local pending = #clients
	local results = {}
	local function handle_results()
		pending = pending - 1
		if pending > 0 then return end

		if
			not vim.api.nvim_buf_is_valid(origin_buf)
			or not vim.api.nvim_win_is_valid(origin_win)
			or vim.api.nvim_win_get_buf(origin_win) ~= origin_buf
		then
			vim.notify("Reference request cancelled: source buffer changed", vim.log.levels.INFO)
			return
		end

		local locations = collect_reference_locations(results)
		if #locations == 0 then
			vim.notify("No references found", vim.log.levels.INFO)
			return
		end

		local target_index
		if direction > 0 then
			target_index = find_next_index(locations, current) or 1
			target_index = ((target_index - 1 + steps - 1) % #locations) + 1
		else
			target_index = find_previous_index(locations, current) or #locations
			target_index = ((target_index - 1 - (steps - 1)) % #locations) + 1
		end

		local target = locations[target_index]
		vim.api.nvim_win_call(
			origin_win,
			function() vim.lsp.util.jump_to_location(target.location, target.encoding, true) end
		)
	end

	vim.iter(clients):each(function(client)
		local params = vim.lsp.util.make_position_params(origin_win, client.offset_encoding)
		params.context = { includeDeclaration = false }
		local success = client:request("textDocument/references", params, function(err, result)
			results[client.id] = { err = err, result = result }
			vim.schedule(handle_results)
		end, origin_buf)
		if success then return end

		results[client.id] = { err = "request failed" }
		vim.schedule(handle_results)
	end)
end

local function browse_github()
	if vim.fn.executable("gh") ~= 1 then
		vim.notify("gh is not installed", vim.log.levels.ERROR)
		return
	end

	local file = vim.api.nvim_buf_get_name(0)
	local root = vim.fs.root(file ~= "" and file or vim.fn.getcwd(), ".git")
	if not root then
		vim.notify("Not inside a git repository", vim.log.levels.WARN)
		return
	end

	local cmd = { "gh", "browse" }
	if file ~= "" and vim.fn.filereadable(file) == 1 then
		local relpath = vim.fs.relpath(root, file)
		if relpath and relpath ~= "" and not relpath:match("^%.%./") then
			table.insert(cmd, relpath)
			table.insert(cmd, "-L")
			table.insert(cmd, tostring(vim.api.nvim_win_get_cursor(0)[1]))
		end
	end

	vim.system(cmd, { cwd = root }, function(result)
		if result.code == 0 then return end

		local message = result.stderr ~= "" and result.stderr or result.stdout
		vim.schedule(function() vim.notify(message, vim.log.levels.ERROR) end)
	end)
end

local function explorer_cwd()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then return vim.fn.getcwd() end

	local cwd = vim.fn.fnamemodify(file, ":p:h")
	return vim.fn.isdirectory(cwd) == 1 and cwd or vim.fn.getcwd()
end

local function previous_char_col(row, col)
	local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
	local limit = math.min(col, #line)
	if limit <= 0 then return 0 end

	local prefix = line:sub(1, limit)
	local chars = vim.fn.strchars(prefix)
	return chars > 0 and vim.str_byteindex(prefix, chars - 1) or 0
end

local function node_finish_position(end_row, end_col)
	if end_col > 0 then return { row = end_row, col = previous_char_col(end_row, end_col) } end
	if end_row == 0 then return { row = 0, col = 0 } end

	return { row = end_row - 1, col = previous_char_col(end_row - 1, math.huge) }
end

local function node_start_position(node)
	local row, col = node:range()
	return { row = row, col = col }
end

local function node_contains_position(node, position)
	local start_row, start_col, end_row, end_col = node:range()
	return compare_buffer_position({ row = start_row, col = start_col }, position) <= 0
		and compare_buffer_position(node_finish_position(end_row, end_col), position) >= 0
end

local function node_range_size(node)
	local start_row, start_col, end_row, end_col = node:range()
	return (end_row - start_row) * 1000000 + end_col - start_col
end

local function find_definition_scope(definition, root, scopes)
	local definition_start = node_start_position(definition)
	return vim.iter(scopes)
		:filter(function(scope)
			local scope_start = node_start_position(scope)
			return scope ~= root
				and scope_start.row == definition_start.row
				and node_contains_position(scope, definition_start)
		end)
		:fold(nil, function(best, scope)
			if best == nil or node_range_size(scope) < node_range_size(best) then return scope end
			return best
		end)
end

local function add_semantic_function(definition, root, scopes, nodes, seen)
	local scope = find_definition_scope(definition, root, scopes) or definition
	local start_row, start_col, end_row, end_col = scope:range()
	local key = string.format("%d:%d:%d:%d", start_row, start_col, end_row, end_col)
	if seen[key] then return end

	seen[key] = true
	nodes[#nodes + 1] = {
		start = { row = start_row, col = start_col },
		finish = node_finish_position(end_row, end_col),
	}
end

local semantic_function_captures = {
	["local.definition.function"] = true,
	["local.definition.method"] = true,
}

local function collect_semantic_functions(parser, nodes, seen)
	local lang_ok, lang = pcall(function() return parser:lang() end)
	local query_ok, query = pcall(vim.treesitter.query.get, lang_ok and lang or "", "locals")
	query = query_ok and query or nil
	local parse_ok, trees = pcall(function() return parser:parse() end)
	if query and parse_ok then
		vim.iter(trees or {}):each(function(tree)
			local definitions = {}
			local scopes = {}
			local root = tree:root()

			for capture_id, node in query:iter_captures(root, 0, 0, -1) do
				local capture = query.captures[capture_id]
				if semantic_function_captures[capture] then
					definitions[#definitions + 1] = node
				elseif capture == "local.scope" then
					scopes[#scopes + 1] = node
				end
			end

			vim.iter(definitions)
				:each(function(definition) add_semantic_function(definition, root, scopes, nodes, seen) end)
		end)
	end

	local children_ok, children = pcall(function() return parser:children() end)
	if children_ok then
		vim.iter(children or {})
			:each(function(key_or_child, child) collect_semantic_functions(child or key_or_child, nodes, seen) end)
	end
end

local function fallback_normal(key)
	local count = vim.v.count > 0 and tostring(vim.v.count) or ""
	vim.cmd("normal! " .. count .. key)
end

local function jump_function(key, direction, edge, description)
	local ok, parser = pcall(vim.treesitter.get_parser, 0)
	if not ok or not parser then return fallback_normal(key) end

	local nodes = {}
	collect_semantic_functions(parser, nodes, {})
	if #nodes == 0 then return fallback_normal(key) end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local current = { row = cursor[1] - 1, col = cursor[2] }
	local candidates = vim.iter(nodes)
		:filter(function(node)
			local cmp = compare_buffer_position(node[edge], current)
			return direction > 0 and cmp > 0 or direction < 0 and cmp < 0
		end)
		:totable()

	table.sort(candidates, function(lhs, rhs)
		local cmp = compare_buffer_position(lhs[edge], rhs[edge])
		if direction > 0 then return cmp < 0 end
		return cmp > 0
	end)

	local target = candidates[vim.v.count1]
	if not target then
		vim.notify("No " .. description .. " function/method", vim.log.levels.INFO)
		return
	end

	vim.api.nvim_win_set_cursor(0, { target[edge].row + 1, target[edge].col })
end

local expr_opts = { expr = true }

local function cmdline_at_end() return vim.fn.getcmdpos() > #vim.fn.getcmdline() end

local function cmdline_transpose()
	local pos = vim.fn.getcmdpos()
	local line = vim.fn.getcmdline()

	if vim.fn.getcmdtype():match("[?/]") then return "<C-t>" end

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
	return vim.iter(vim.lsp.get_clients({ bufnr = 0 })):find(function(client)
		local provider = client.server_capabilities.completionProvider
		return provider
			and provider.triggerCharacters
			and vim.iter(provider.triggerCharacters):find(function(trigger) return trigger == char end) ~= nil
	end) ~= nil
end

local function should_enable_insert_autocomplete()
	if vim.bo.buftype ~= "" then return false, 0, false end

	local prefix_len, trigger_char = completion_context()
	if prefix_len >= autocomplete_min_chars then return true, prefix_len, false end
	if trigger_char and has_lsp_trigger_char(trigger_char) then return true, prefix_len, true end

	return false, prefix_len, false
end

local function update_insert_autocomplete()
	local enabled, prefix_len = should_enable_insert_autocomplete()
	vim.opt_local.autocomplete = enabled

	if not enabled and vim.fn.pumvisible() == 1 then
		vim.api.nvim_feedkeys(vim.keycode("<C-e>"), "n", false)
		return
	end

	if enabled and vim.fn.pumvisible() == 0 and prefix_len == autocomplete_min_chars then
		vim.schedule(function()
			if vim.api.nvim_get_mode().mode ~= "i" then return end
			local still_enabled, still_prefix_len, still_from_trigger = should_enable_insert_autocomplete()
			if not still_enabled or vim.fn.pumvisible() == 1 then return end
			if still_prefix_len == autocomplete_min_chars and not still_from_trigger then vim.lsp.completion.get() end
		end)
	end
end

function M.setup()
	vim.iter({ 0, 1, 2, 3, 4, 5 }):each(function(i)
		set_map("n", "z" .. i, function() vim.opt_local.foldlevel = i end)
	end)

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

	vim.iter(maps):each(function(m) set_map(m[1], m[2], m[3]) end)

	vim.iter({
		{ "<C-a>", "<Home>" },
		{ "<C-x><C-a>", "<C-a>" },
		{ "<C-b>", "<Left>" },
		{ "<C-d>", function() return cmdline_at_end() and "<C-d>" or "<Del>" end, expr_opts },
		{ "<C-e>", "<End>" },
		{ "<C-f>", function() return cmdline_at_end() and vim.o.cedit or "<Right>" end, expr_opts },
		{ "<C-t>", cmdline_transpose, expr_opts },
		{
			"<C-u>",
			function()
				local pos = vim.fn.getcmdpos()
				if pos > 1 then vim.fn.setreg("-", vim.fn.getcmdline():sub(1, pos - 1)) end
				return "<C-u>"
			end,
			expr_opts,
		},
		{ "<C-y>", function() return vim.fn.pumvisible() == 1 and "<C-y>" or "<C-r>-" end, expr_opts },
		{ "<M-b>", "<S-Left>" },
		{ "<M-f>", "<S-Right>" },
		{ "<M-d>", "<S-Right><C-w>" },
		{ "<M-n>", "<Down>" },
		{ "<M-p>", "<Up>" },
		{ "<M-BS>", "<C-w>" },
		{ "<M-C-h>", "<C-w>" },
		-- Allow saving of files as sudo when I forgot to start vim using sudo.
		{ "w!!", [[w !sudo tee > /dev/null %]], { silent = false } },
	}):each(function(spec) set_map("c", spec[1], spec[2], spec[3]) end)

	set_map({ "i", "s" }, "<Tab>", function()
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
	end, expr_opts)

	set_map({ "i", "s" }, "<S-Tab>", function()
		if vim.fn.pumvisible() == 1 then return "<C-p>" end

		if vim.snippet.active({ direction = -1 }) then
			vim.snippet.jump(-1)
			return ""
		end

		return "<S-Tab>"
	end, expr_opts)

	set_map("i", "<CR>", function()
		if vim.fn.pumvisible() == 1 then
			if vim.fn.complete_info({ "selected" }).selected ~= -1 then return "<C-y>" end
			return "<C-e><CR>"
		end

		return "<CR>"
	end, expr_opts)

	set_map("i", "<C-Space>", vim.lsp.completion.get)
	set_map("i", "<C-e>", function()
		local has_supermaven, suggestion = pcall(require, "supermaven-nvim.completion_preview")
		if has_supermaven and suggestion.has_suggestion() then
			suggestion.on_dispose_inlay()
			return ""
		end

		if vim.fn.pumvisible() == 1 then return "<C-e>" end

		return ""
	end, expr_opts)

	set_map(
		"n",
		"<C-w>d",
		function()
			vim.diagnostic.open_float({
				scope = "cursor",
				source = "if_many",
				border = "rounded",
			})
		end
	)

	set_map("n", "<leader>ll", function() require("lazy").home() end)

	local group = vim.api.nvim_create_augroup("config_mappings", { clear = true })
	vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI", "TextChangedI" }, {
		group = group,
		callback = update_insert_autocomplete,
	})
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		callback = function() vim.opt_local.autocomplete = false end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = { "qf", "fugitive", "fugitiveblame" },
		callback = function(event) set_map("n", "q", "<cmd>close<CR>", { buffer = event.buf }) end,
	})
end

function M.setup_treesitter()
	vim.iter({
		{ "n", "]m", function() jump_function("]m", 1, "start", "next") end, "Next function/method start" },
		{ "n", "[m", function() jump_function("[m", -1, "start", "previous") end, "Previous function/method start" },
		{ "n", "]M", function() jump_function("]M", 1, "finish", "next") end, "Next function/method end" },
		{ "n", "[M", function() jump_function("[M", -1, "finish", "previous") end, "Previous function/method end" },
		{ "n", "<M-UP>", "van", "Treesitter init selection" },
		{ "x", "<M-UP>", "an", "Treesitter expand selection" },
		{ "x", "<M-RIGHT>", "]n", "Treesitter next node" },
		{ "x", "<M-DOWN>", "in", "Treesitter shrink selection" },
	}):each(function(spec) set_map(spec[1], spec[2], spec[3], { desc = spec[4] }) end)
end

function M.setup_lsp(bufnr)
	vim.iter({
		{ "K", vim.lsp.buf.hover },
		{ "gD", vim.lsp.buf.declaration },
		{ "<F4>", vim.lsp.codelens.run },
	}):each(function(spec) set_map("n", spec[1], spec[2], { buffer = bufnr }) end)
end

function M.setup_help()
	vim.iter({
		{ "<M-]>", "<C-]>" },
		{ "<M-[>", "<C-T>" },
		{ "o", [[/'\l\{2,\}'<CR>]] },
		{ "O", [[?'\l\{2,\}'<CR>]] },
		{ "s", [[/\|\zs\S\+\ze\|<CR>]] },
		{ "S", [[?\|\zs\S\+\ze\|<CR>]] },
		{ "q", [[<cmd>close<cr>]] },
	}):each(function(spec) set_map("n", spec[1], spec[2], { buffer = true }) end)
end

function M.setup_lua()
	if vim.fn.executable("love") == 1 and vim.fn.search("function love", "n") > 0 then
		set_map("n", "<f5>", "<cmd>!love .<cr>", { buffer = true })
	end
end

function M.setup_mini(mini)
	local function run_from_normal_mode(fn)
		return function(...)
			local args = { ... }
			if vim.api.nvim_get_mode().mode == "t" then
				vim.cmd.stopinsert()
				vim.schedule(function() fn(unpack_fn(args)) end)
				return
			end
			fn(unpack_fn(args))
		end
	end

	local function map_nt(lhs, rhs, desc)
		set_map({ "n", "t" }, lhs, run_from_normal_mode(rhs), desc and { desc = desc } or nil)
	end

	local zoom_state = {}

	local function toggle_zoom()
		local tabpage = vim.api.nvim_get_current_tabpage()
		if zoom_state[tabpage] then
			pcall(vim.cmd, zoom_state[tabpage])
			zoom_state[tabpage] = nil
			return
		end

		zoom_state[tabpage] = vim.fn.winrestcmd()
		vim.cmd("wincmd |")
		vim.cmd("wincmd _")
	end

	local function toggle_indent_scope()
		local is_enabled = vim.b.miniindentscope_disable ~= true
		vim.b.miniindentscope_disable = is_enabled
		if is_enabled then
			mini.indentscope.undraw()
			return
		end
		mini.indentscope.draw()
	end

	vim.iter({
		{ "<c-p>", function() mini.pick.builtin.files() end, "Find Files" },
		{ "<leader>fb", function() mini.pick.builtin.buffers() end, "List buffers" },
		{ "<leader>fa", function() mini.pick.registry.man() end, "Search man pages" },
		{ "<leader>fd", function() mini.extra.pickers.diagnostic({ scope = "current" }) end, "List diagnostics" },
		{ "<leader>fl", function() mini.pick.builtin.grep_live() end, "Grep" },
		{ "<leader>fr", function() mini.extra.pickers.registers() end, "List registers" },
		{ "<leader>f/", function() mini.extra.pickers.history({ scope = "/" }) end, "Search history" },
		{ "<leader>fh", function() mini.pick.builtin.help() end, "Search help tags" },
		{ "<leader>fq", function() mini.extra.pickers.history({ scope = ":" }) end, "Command history" },
		{ "<leader>fm", function() mini.extra.pickers.keymaps() end, "List keymaps" },
		{ "<leader>qf", function() mini.extra.pickers.list({ scope = "quickfix" }) end, "List quickfix items" },
		{ "<leader>fgf", function() mini.extra.pickers.git_files() end, "Find git files" },
		{ "<leader>fk", function() mini.extra.pickers.marks() end, "List marks" },
		{ "<leader>fo", function() mini.extra.pickers.commands() end, "List commands" },
		{
			"<leader>fc",
			function() mini.pick.builtin.files({}, { source = { cwd = vim.fn.stdpath("config") } }) end,
			"Find config files",
		},
		{ "<leader><space>", function() mini.extra.pickers.buf_lines() end, "Search current buffer" },
		{ "<leader>ft", function() mini.extra.pickers.colorschemes() end, "Choose colorscheme" },
		{ "<s-tab>", function() require("oil").toggle_float(explorer_cwd()) end, "File explorer" },
		{ "ghx", browse_github, "Browse on GitHub" },
		{ "<m-right>", function() jump_reference(vim.v.count1) end, "Next Reference" },
		{ "<m-left>", function() jump_reference(-vim.v.count1) end, "Prev Reference" },
	}):each(function(spec) map_nt(spec[1], spec[2], spec[3]) end)

	vim.iter({
		{ "<leader>fn", mini.notify.show_history, "Notifier" },
		{ "<leader>hn", mini.notify.clear, "Dismiss All Notifications" },
	}):each(function(spec) set_map("n", spec[1], spec[2], { desc = spec[3] }) end)

	vim.iter({
		{ "yow", function() vim.wo.wrap = not vim.wo.wrap end, "Toggle wrap" },
		{ "yoi", toggle_indent_scope, "Toggle indent scope" },
		{ "yod", function() set_diagnostics_enabled(not diagnostics_is_enabled()) end, "Toggle diagnostics" },
		{ "yon", function() vim.wo.number = not vim.wo.number end, "Toggle line numbers" },
		{ "yoc", toggle_codelens, "Toggle codelens" },
		{ "<leader>ih", function() set_inlay_hints_enabled(not inlay_hints_is_enabled()) end, "Toggle inlay hints" },
		{ "yoz", toggle_zoom, "Toggle zoom" },
	}):each(function(spec) set_map("n", spec[1], spec[2], spec[3] and { desc = spec[3] } or nil) end)
end

return M
