local path = require("config.path")

vim.opt_local.makeprg = "lua %"

vim.cmd.iabbrev("tbl", "setmetatable({}, { __index = table })")
require("config.mappings").setup_lua()

if path.is_exercism() then vim.opt_local.makeprg = "busted" end
