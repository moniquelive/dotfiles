local M = {}

---@param path? string
---@return boolean
function M.is_exercism(path)
	path = (path or vim.api.nvim_buf_get_name(0)):lower()
	return path:find("/exercism/", 1, true) ~= nil
end

---@param path? string
---@return boolean
function M.is_lein(path)
	path = path or vim.api.nvim_buf_get_name(0)
	if path == "" then return false end
	if vim.fn.isdirectory(path) == 0 then path = vim.fn.fnamemodify(path, ":h") end

	return #vim.fs.find("project.clj", { path = path, upward = true, stop = vim.env.HOME }) > 0
end

return M
