local cfg = vim.fn.stdpath("config")
dofile(vim.fn.expand(cfg .. "/after/ftplugin/common.lua"))

vim.cmd.compiler "pylint"
vim.opt_local.makeprg = "python %"
