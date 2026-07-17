local M = {}

local function buffer_text(buf_id)
	local text = table.concat(vim.api.nvim_buf_get_lines(buf_id, 0, -1, false), "\n")
	return vim.bo[buf_id].endofline and text .. "\n" or text
end

local function layout()
	local has_tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
	local has_statusline = vim.o.laststatus > 0
	local available_height = vim.o.lines - vim.o.cmdheight - (has_tabline and 1 or 0) - (has_statusline and 1 or 0)
	local margin = math.max(1, math.floor(vim.o.columns * 0.04))
	local gap = 1
	local content_width = math.max(vim.o.columns - 2 * margin - gap - 4, 2)
	local picker_width = math.max(math.floor(content_width * 0.35), math.min(28, content_width - 1))
	local preview_width = math.max(content_width - picker_width, 1)
	local height = math.max(math.floor(available_height * 0.8) - 2, 1)
	local row = (has_tabline and 1 or 0) + math.max(math.floor((available_height - height - 2) * 0.5), 0)

	return {
		picker = {
			relative = "editor",
			anchor = "NW",
			row = row,
			col = margin,
			width = picker_width,
			height = height,
			border = "rounded",
		},
		preview = {
			relative = "editor",
			anchor = "NW",
			row = row,
			col = margin + picker_width + gap + 2,
			width = preview_width,
			height = height,
			border = "rounded",
			style = "minimal",
			focusable = false,
			zindex = 250,
		},
	}
end

local function undo_items(tree)
	local items = {}
	local seen = {}

	local function add(seq, timestamp, depth, entry)
		if seen[seq] then return end
		seen[seq] = true

		local markers = {}
		if seq == tree.seq_cur then markers[#markers + 1] = "current" end
		if entry and entry.save then markers[#markers + 1] = "saved" end
		local suffix = #markers > 0 and " [" .. table.concat(markers, ", ") .. "]" or ""
		local label = seq == 0 and "initial state" or os.date("%Y-%m-%d %H:%M:%S", timestamp)
		items[#items + 1] = {
			seq = seq,
			text = string.format("%s#%-5d %s%s", string.rep("  ", depth), seq, label, suffix),
		}
	end

	local function visit(entries, depth)
		for _, entry in ipairs(entries or {}) do
			add(entry.seq, entry.time, depth, entry)
			visit(entry.alt, depth + 1)
		end
	end

	add(0, 0, 0)
	visit(tree.entries, 0)

	table.sort(items, function(a, b) return a.seq > b.seq end)
	return items
end

local function create_history_buffer(source_buf, tree)
	local clone_buf = vim.api.nvim_create_buf(false, true)
	local undo_path
	vim.bo[clone_buf].bufhidden = "wipe"
	vim.bo[clone_buf].swapfile = false
	vim.bo[clone_buf].undofile = false
	vim.bo[clone_buf].endofline = vim.bo[source_buf].endofline
	vim.bo[clone_buf].fileformat = vim.bo[source_buf].fileformat
	vim.api.nvim_buf_set_lines(clone_buf, 0, -1, false, vim.api.nvim_buf_get_lines(source_buf, 0, -1, false))

	if tree.seq_last == 0 then return clone_buf end

	local ok, err = pcall(function()
		undo_path = vim.fn.tempname() .. ".undo"
		vim.api.nvim_buf_call(source_buf, function() vim.cmd("silent wundo! " .. vim.fn.fnameescape(undo_path)) end)
		vim.api.nvim_buf_call(clone_buf, function() vim.cmd("silent rundo " .. vim.fn.fnameescape(undo_path)) end)
	end)
	if not ok then
		if vim.api.nvim_buf_is_valid(clone_buf) then vim.api.nvim_buf_delete(clone_buf, { force = true }) end
		if undo_path then vim.fn.delete(undo_path) end
		error(err)
	end

	return clone_buf, undo_path
end

function M.pick(pick)
	pick = pick or require("mini.pick")

	local source_buf = vim.api.nvim_get_current_buf()
	local source_win = vim.api.nvim_get_current_win()
	local tree = vim.fn.undotree()
	local base_seq = tree.seq_cur
	local base_text = buffer_text(source_buf)
	local history_buf, undo_path
	local ok, err = pcall(function()
		history_buf, undo_path = create_history_buffer(source_buf, tree)
	end)
	if not ok then
		if history_buf and vim.api.nvim_buf_is_valid(history_buf) then
			vim.api.nvim_buf_delete(history_buf, { force = true })
		end
		if undo_path then vim.fn.delete(undo_path) end
		vim.notify("Could not prepare undo preview: " .. err, vim.log.levels.ERROR)
		return
	end

	local preview_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[preview_buf].bufhidden = "wipe"
	vim.bo[preview_buf].filetype = "diff"
	vim.bo[preview_buf].swapfile = false
	local preview_win
	local last_seq
	local cleaned = false
	local stop_autocmd

	local function cleanup()
		if cleaned then return end
		cleaned = true
		if stop_autocmd then pcall(vim.api.nvim_del_autocmd, stop_autocmd) end
		if preview_win and vim.api.nvim_win_is_valid(preview_win) then vim.api.nvim_win_close(preview_win, true) end
		if vim.api.nvim_buf_is_valid(preview_buf) then vim.api.nvim_buf_delete(preview_buf, { force = true }) end
		if history_buf and vim.api.nvim_buf_is_valid(history_buf) then
			vim.api.nvim_buf_delete(history_buf, { force = true })
		end
		if undo_path then vim.fn.delete(undo_path) end
	end

	local function ensure_preview()
		if cleaned then return end

		local config = layout().preview
		if preview_win and vim.api.nvim_win_is_valid(preview_win) then
			vim.api.nvim_win_set_config(preview_win, config)
			return
		end

		preview_win = vim.api.nvim_open_win(preview_buf, false, config)
		vim.wo[preview_win].foldenable = false
		vim.wo[preview_win].number = false
		vim.wo[preview_win].relativenumber = false
		vim.wo[preview_win].wrap = false
	end

	local function render_preview(item)
		if cleaned or item == nil or item.seq == last_seq then return end
		last_seq = item.seq

		local state_ok, selected_text = true, base_text
		if item.seq ~= base_seq then
			state_ok, selected_text = pcall(function()
				vim.api.nvim_buf_call(history_buf, function() vim.cmd("silent noautocmd undo " .. item.seq) end)
				return buffer_text(history_buf)
			end)
		end
		if not state_ok then selected_text = "Could not read undo state #" .. item.seq .. ":\n" .. selected_text end

		local diff = state_ok and vim.diff(base_text, selected_text, { result_type = "unified", ctxlen = 3 })
			or selected_text
		local lines = {
			string.format("--- current (#%d)", base_seq),
			string.format("+++ undo (#%d)", item.seq),
		}
		if diff == "" then
			lines[#lines + 1] = ""
			lines[#lines + 1] = "No changes"
		else
			vim.list_extend(lines, vim.split(diff, "\n", { plain = true, trimempty = true }))
		end

		vim.bo[preview_buf].modifiable = true
		vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
		vim.bo[preview_buf].modifiable = false
		if preview_win and vim.api.nvim_win_is_valid(preview_win) then
			vim.api.nvim_win_set_cursor(preview_win, { 1, 0 })
		end
	end

	local function show(buf_id, items, query)
		pick.default_show(buf_id, items, query)
		ensure_preview()
		local matches = pick.get_picker_matches()
		render_preview(matches and matches.current)
	end

	local function choose(item)
		if item.seq == vim.api.nvim_buf_call(source_buf, vim.fn.undotree).seq_cur then return end

		local apply = function() vim.cmd("silent undo " .. item.seq) end
		if vim.api.nvim_win_is_valid(source_win) and vim.api.nvim_win_get_buf(source_win) == source_buf then
			vim.api.nvim_win_call(source_win, apply)
		elseif vim.api.nvim_buf_is_valid(source_buf) then
			vim.api.nvim_buf_call(source_buf, apply)
		end
	end

	stop_autocmd = vim.api.nvim_create_autocmd("User", {
		pattern = "MiniPickStop",
		once = true,
		callback = cleanup,
	})

	local start_ok, result = pcall(pick.start, {
		mappings = { toggle_preview = "" },
		window = { config = function() return layout().picker end },
		source = {
			items = undo_items(tree),
			name = "Undo tree",
			show = show,
			choose = choose,
		},
	})
	cleanup()
	if not start_ok then error(result) end

	return result
end

return M
