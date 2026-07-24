local path = require("config.path")
local skeleton = require("config.skeleton")

vim.cmd.compiler("go")
if path.is_exercism() then
	vim.opt_local.makeprg = "go test -v ."
elseif path.is_lein(vim.fn.expand("%:p:h")) then
	vim.opt_local.makeprg = "go run %:p:S"
end

local bufname = vim.api.nvim_buf_get_name(0)
if bufname:match("main%.go$") then
	skeleton.insert_if_empty([[package main

import "fmt"

func main() {
    fmt.Println("Hello, world!")
}]])
end
