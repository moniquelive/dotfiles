local cfg = vim.fn.stdpath("config")
dofile(vim.fn.expand(cfg .. "/after/ftplugin/common.lua"))

vim.opt_local.makeprg = "lua %"

if vim.fn.executable("love") == 1 and vim.fn.search("function love", "n") > 0 then
	vim.keymap.set("n", "<f5>", "<cmd>!love .<cr>", { silent = true, buffer = true })
end
