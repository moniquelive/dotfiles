local path = require("config.path")

if path.is_exercism() then
	vim.opt_local.makeprg = "mix test"
end
