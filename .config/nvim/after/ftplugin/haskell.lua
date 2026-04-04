local path = require("config.path")

vim.opt_local.makeprg = "cabal run"
if path.is_exercism() then
	vim.opt_local.makeprg = "cabal test"
end
