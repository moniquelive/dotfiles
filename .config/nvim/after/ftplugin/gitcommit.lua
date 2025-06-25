local cfg = vim.fn.stdpath("config")
dofile(vim.fn.expand(cfg .. "/after/ftplugin/common.lua"))

vim.opt_local.spell = true
