local M = {}

local unpack_fn = table.unpack or unpack
local map_defaults = { noremap = true, silent = true }
local is_list = vim.islist or vim.tbl_islist

local function as_list(value)
	if value == nil then return {} end
	return is_list(value) and value or { value }
end

local function diagnostics_is_enabled()
	local ok, enabled = pcall(vim.diagnostic.is_enabled, { bufnr = 0 })
	return ok and enabled or true
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

local function compare_position(lhs, rhs)
	if lhs.file ~= rhs.file then return lhs.file < rhs.file and -1 or 1 end
	if lhs.lnum ~= rhs.lnum then return lhs.lnum < rhs.lnum and -1 or 1 end
	if lhs.col ~= rhs.col then return lhs.col < rhs.col and -1 or 1 end
	return 0
end

local function collect_reference_locations(results)
	local locations = {}
	local seen = {}

	vim.iter(results or {}):each(function(client_id, response)
		if response.err or not response.result then return end

		local client = vim.lsp.get_client_by_id(tonumber(client_id))
		local encoding = client and client.offset_encoding or "utf-16"
		local raw_locations = as_list(response.result)
		local items = vim.lsp.util.locations_to_items(raw_locations, encoding)

		vim.iter(items):enumerate():each(function(index, item)
			local raw_location = raw_locations[index]
			if raw_location == nil then return end

			local file = vim.fn.fnamemodify(item.filename, ":p")
			local key = string.format("%s:%d:%d", file, item.lnum, item.col)
			if seen[key] then return end

			seen[key] = true
			locations[#locations + 1] = {
				file = file,
				lnum = item.lnum,
				col = item.col,
				location = raw_location,
				encoding = encoding,
			}
		end)
	end)

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
	local params = vim.lsp.util.make_position_params()
	params.context = { includeDeclaration = false }
	local steps = math.max(math.abs(direction), 1)

	vim.lsp.buf_request_all(0, "textDocument/references", params, function(results)
		local locations = collect_reference_locations(results)
		if #locations == 0 then
			vim.notify("No references found", vim.log.levels.INFO)
			return
		end

		local cursor = vim.api.nvim_win_get_cursor(0)
		local current = {
			file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p"),
			lnum = cursor[1],
			col = cursor[2] + 1,
		}

		local target_index
		if direction > 0 then
			target_index = find_next_index(locations, current) or 1
			target_index = ((target_index - 1 + steps - 1) % #locations) + 1
		else
			target_index = find_previous_index(locations, current) or #locations
			target_index = ((target_index - 1 - (steps - 1)) % #locations) + 1
		end

		local target = locations[target_index]
		vim.lsp.util.jump_to_location(target.location, target.encoding, true)
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

function M.setup(mini)
	local map = vim.keymap.set

	local function set_map(modes, lhs, rhs, opts)
		map(modes, lhs, rhs, vim.tbl_extend("force", map_defaults, opts or {}))
	end

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
		{ "<s-tab>", function() mini.extra.pickers.explorer({ cwd = explorer_cwd() }) end, "File explorer" },
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
		{ "yoc", function() set_codelens_enabled(not codelens_is_enabled()) end, "Toggle codelens" },
		{ "<leader>ih", function() set_inlay_hints_enabled(not inlay_hints_is_enabled()) end, "Toggle inlay hints" },
		{ "yoz", toggle_zoom, "Toggle zoom" },
	}):each(function(spec) set_map("n", spec[1], spec[2], spec[3] and { desc = spec[3] } or nil) end)
end

return M
