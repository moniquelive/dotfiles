local M = {}

---@param path? string
---@return boolean
function M.is_exercism(path)
	path = (path or vim.api.nvim_buf_get_name(0)):lower()
	return path:find("/exercism/", 1, true) ~= nil
end

return M
