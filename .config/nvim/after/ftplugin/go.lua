local cfg = vim.fn.stdpath("config")
dofile(vim.fn.expand(cfg .. "/after/ftplugin/common.lua"))

-- Only run the ftplugin code once per buffer.
if vim.b.did_ftplugin_main_go then return end
vim.b.did_ftplugin_main_go = true

vim.cmd.compiler "go"
vim.opt_local.makeprg = "go run %"

local bufname = vim.api.nvim_buf_get_name(0)
if bufname:match("main%.go$") then
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	if #lines == 1 and lines[1] == "" then
		local skeleton = [[package main

import "fmt"

func main() {
    fmt.Println("Hello, world!")
}]]
		local skeleton_lines = vim.split(skeleton, "\n")
		vim.api.nvim_buf_set_lines(0, 0, -1, false, skeleton_lines)
	end
end
