local skeleton = { [[/*usr/bin/env gcc "$0"; ./a.out; rm a.out; exit 0; */]], "", "" }
vim.cmd.compiler("gcc")

local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
if #lines == 1 and lines[1] == "" then
	vim.api.nvim_buf_set_lines(0, 0, -1, false, skeleton)
	vim.api.nvim_win_set_cursor(0, { 3, 1 })
end

local top = vim.api.nvim_buf_get_lines(0, 0, 1, false)
if top[1] == skeleton[1] then
	vim.opt_local.makeprg = "chmod +x ./% && ./%"
else
	vim.opt_local.makeprg = "make"
end
