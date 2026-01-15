vim.cmd.compiler("gcc")
vim.opt_local.makeprg = "chmod +x ./% && ./%"

local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
if #lines == 1 and lines[1] == "" then
	local skeleton = [[/*usr/bin/env gcc "$0"; ./a.out; rm a.out; exit 0; */

]]
	local skeleton_lines = vim.split(skeleton, "\n")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, skeleton_lines)
	vim.api.nvim_win_set_cursor(0, { 3, 1 })
end
