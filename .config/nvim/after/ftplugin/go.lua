local skeleton = require("config.skeleton")

vim.cmd.compiler("go")
vim.opt_local.makeprg = "go run %"

local bufname = vim.api.nvim_buf_get_name(0)
if bufname:match("main%.go$") then
	skeleton.insert_if_empty([[package main

import "fmt"

func main() {
    fmt.Println("Hello, world!")
}]])
end
