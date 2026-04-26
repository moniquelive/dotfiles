local path = require("config.path")

-- vim.api.nvim_create_autocmd('BufWritePre', {
-- 	pattern = { "*.zig", "*.zon" },
-- 	callback = function()
-- 		vim.lsp.buf.code_action({
-- 			---@diagnostic disable-next-line: missing-fields
-- 			context = { only = { "source.organizeImports" } },
-- 			apply = true,
-- 		})
-- 	end
-- })

vim.g.zig_fmt_parse_errors = 0

if path.is_exercism(vim.fn.expand("%:p:h")) then
	vim.cmd.compiler("zig_test")
	vim.opt_local.makeprg = "cd %:p:h && zig test test_%:t"
elseif #vim.fs.find({ "build.zig" }, { path = vim.fn.expand("%:p:h"), upward = true, stop = vim.env.HOME }) > 0 then
	vim.opt_local.makeprg = "zig build run"
else -- standalone
	vim.opt_local.makeprg = "zig run %"
end
