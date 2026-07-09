local path = require("config.path")

vim.opt_local.makeprg = "lua %:p:S"

vim.cmd.iabbrev("<buffer>", "tbl", "setmetatable({}, { __index = table })")
local undo_ftplugin = vim.b.undo_ftplugin
vim.b.undo_ftplugin = (undo_ftplugin and undo_ftplugin ~= "" and (undo_ftplugin .. " | ") or "")
	.. "silent! iunabbrev <buffer> tbl"
require("config.mappings").setup_lua()

if path.is_exercism() then vim.opt_local.makeprg = "busted" end
