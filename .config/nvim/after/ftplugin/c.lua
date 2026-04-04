local skeleton = require("config.skeleton")

local script_header = [[/*usr/bin/env gcc "$0"; ./a.out; rm a.out; exit 0; */]]
local c_skeleton = { script_header, "", "" }

vim.cmd.compiler("gcc")
skeleton.insert_if_empty(c_skeleton, { 3, 1 })

local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
if first_line == script_header then
	vim.opt_local.makeprg = "chmod +x ./% && ./%"
else
	vim.opt_local.makeprg = "make"
end
