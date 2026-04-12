local M = {}

local function line_text(line)
	return vim.iter(line)
		:map(function(unit)
			return unit.string:gsub("\n", " ")
		end)
		:fold("", function(acc, part)
			return acc .. part
		end)
end

local function line_width(line)
	return vim.fn.strdisplaywidth(line_text(line))
end

local function is_item_line(line)
	return vim.iter(line):any(function(unit)
		return unit.type == "item"
	end)
end

local function merge_item_block(block)
	if #block < 2 then
		return vim.deepcopy(block)
	end

	local split_at = math.ceil(#block / 2)
	local left = vim.list_slice(block, 1, split_at)
	local right = vim.list_slice(block, split_at + 1, #block)
	local left_width = vim.iter(left):fold(0, function(acc, line)
		return math.max(acc, line_width(line))
	end)

	local merged = {}
	for idx, left_line in ipairs(left) do
		local row = vim.deepcopy(left_line)
		local right_line = right[idx]

		if right_line then
			local padding = math.max(left_width - line_width(left_line) + 4, 4)
			row[#row + 1] = { type = "empty", string = string.rep(" ", padding) }
			vim.list_extend(row, vim.deepcopy(right_line))
		end

		merged[#merged + 1] = row
	end

	return merged
end

local function two_column_layout(content)
	if vim.api.nvim_win_get_width(0) < 120 then
		return content
	end

	local result, block = {}, {}
	local function flush_block()
		if #block == 0 then
			return
		end
		vim.list_extend(result, merge_item_block(block))
		block = {}
	end

	for _, line in ipairs(content) do
		if is_item_line(line) then
			block[#block + 1] = line
		else
			flush_block()
			result[#result + 1] = line
		end
	end

	flush_block()
	return result
end

local function compact_path(path)
	return " (" .. vim.fn.pathshorten(vim.fn.fnamemodify(path, ":~"), 1) .. ")"
end

local function align_with_right_padding(starter, right, horizontal, vertical)
	right = math.max(right or 0, 0)
	horizontal = horizontal or "left"
	vertical = vertical or "top"

	local horiz_coef = ({ left = 0, center = 0.5, right = 1.0 })[horizontal] or 0
	local vert_coef = ({ top = 0, center = 0.5, bottom = 1.0 })[vertical] or 0

	return function(content, buf_id)
		local win_id = vim.fn.bufwinid(buf_id)
		if win_id < 0 then
			return content
		end

		local line_strings = starter.content_to_lines(content)
		local lines_width = vim.iter(line_strings)
			:map(function(line)
				return vim.fn.strdisplaywidth(line)
			end)
			:totable()
		local max_line_width = vim.iter(lines_width):fold(0, function(acc, width)
			return math.max(acc, width)
		end)

		local available_width = math.max(vim.api.nvim_win_get_width(win_id) - right, 0)
		local free_width = available_width - max_line_width
		local left_pad = math.max(math.floor(horiz_coef * free_width), 0)

		local bottom_space = vim.api.nvim_win_get_height(win_id) - #line_strings
		local top_pad = math.max(math.floor(vert_coef * bottom_space), 0)

		return starter.gen_hook.padding(left_pad, top_pad)(content)
	end
end

local function relabel(section_name, section)
	return function()
		local items = type(section) == "function" and section() or section
		return vim.iter(items):map(function(item)
			local result = vim.deepcopy(item)
			result.section = section_name
			return result
		end):totable()
	end
end

local function header()
	local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
	local date = os.date("%a %d %b %Y")
	local startup_time = "n/a"

	local ok, lazy = pcall(require, "lazy")
	if ok then
		local stats = lazy.stats()
		if type(stats) == "table" and type(stats.startuptime) == "number" then
			startup_time = string.format("%.2fms", stats.startuptime)
		end
	end

	return table.concat({
		[[ _   _                 _         ]],
		[[| \ | | _____   _(_)_ __ ___   ]],
		[[|  \| |/ _ \ \ / / | '_ ` _ \  ]],
		[[| |\  |  __/\ V /| | | | | | |]],
		[[|_| \_|\___| \_/ |_|_| |_| |_|]],
		"",
		"cwd: " .. cwd,
		"date: " .. date,
		"startup: " .. startup_time,
	}, "\n")
end

local function should_open()
	if #vim.api.nvim_list_uis() == 0 then
		return false
	end

	if vim.fn.argc() > 0 then
		return false
	end

	if #vim.api.nvim_list_wins() ~= 1 then
		return false
	end

	local buf = vim.api.nvim_get_current_buf()
	if vim.api.nvim_buf_get_name(buf) ~= "" then
		return false
	end

	if vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype ~= "" then
		return false
	end

	local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, false)
	if (lines[1] or "") ~= "" or (lines[2] or "") ~= "" then
		return false
	end

	return true
end

function M.setup(starter)
	starter.setup({
		autoopen = false,
		evaluate_single = true,
		header = header,
		footer = "",
		items = {
			relabel("Pickers", starter.sections.pick()),
			relabel("MRU (cwd)", starter.sections.recent_files(8, true, false)),
			relabel("Recent files", starter.sections.recent_files(8, false, compact_path)),
			relabel("Quick actions", starter.sections.builtin_actions()),
		},
		content_hooks = {
			starter.gen_hook.adding_bullet("| ", false),
			starter.gen_hook.indexing("all", { "Quick actions" }),
			two_column_layout,
			starter.gen_hook.padding(3, 1),
			align_with_right_padding(starter, 3, "center", "center"),
		},
	})

	vim.schedule(function()
		if should_open() then
			starter.open()
		end
	end)
end

return M
