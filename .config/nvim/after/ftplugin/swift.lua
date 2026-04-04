-- Only run the ftplugin code once per buffer.
if vim.b.did_ftplugin_swift then return end
vim.b.did_ftplugin_swift = true

local path = require("config.path")

if path.is_exercism(vim.fn.expand("%:p:h")) then
	vim.opt_local.makeprg = "cd %:p:h && RUNALL=true swift test -j 10"
else
	vim.opt_local.makeprg = "swift %:p"
end
