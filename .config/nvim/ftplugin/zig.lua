vim.cmd.compiler "zig"
vim.opt_local.makeprg = "zig run %"

-- are we exercisming?
if string.find(vim.fn.expand("%:p"):lower(), "exercism") ~= nil then
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("exercism_zig", { clear = true }),
		pattern = "*.zig",
		command = [[!zig test test_%]]
	})
end
