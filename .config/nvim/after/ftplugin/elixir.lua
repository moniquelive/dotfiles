local cfg = vim.fn.stdpath("config")
dofile(vim.fn.expand(cfg .. "/after/ftplugin/common.lua"))

-- vim.cmd.compiler "elixir"
if string.find(vim.fn.expand("%:p"):lower(), "/exercism/") ~= nil then -- are we exercisming?
	vim.opt_local.makeprg = "mix test"
end
