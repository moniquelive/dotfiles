local M = {}

---@param skeleton string|string[]
---@param cursor? integer[]
---@return boolean
function M.insert_if_empty(skeleton, cursor)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	if #lines ~= 1 or lines[1] ~= "" then return false end

	local skeleton_lines = skeleton
	if type(skeleton) == "string" then
		skeleton_lines = vim.split(skeleton, "\n", { plain = true })
	end

	vim.api.nvim_buf_set_lines(0, 0, -1, false, skeleton_lines)

	if cursor then
		vim.api.nvim_win_set_cursor(0, cursor)
	end

	return true
end

return M
