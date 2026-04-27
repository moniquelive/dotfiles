local path = require("config.path")

vim.opt_local.makeprg = "bb %"
if path.is_exercism() then vim.opt_local.makeprg = "lein test" end
