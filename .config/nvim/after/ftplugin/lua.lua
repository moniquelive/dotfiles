local path = require("config.path")

vim.opt_local.makeprg = "lua %"

vim.cmd.iabbrev("tbl", "setmetatable({}, { __index = table })")

if vim.fn.executable("love") == 1 and vim.fn.search("function love", "n") > 0 then
	vim.keymap.set("n", "<f5>", "<cmd>!love .<cr>", { silent = true, buffer = true })
end

if path.is_exercism() then
	vim.opt_local.makeprg = "busted"
end
