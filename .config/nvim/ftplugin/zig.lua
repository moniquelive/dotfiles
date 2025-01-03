vim.cmd.compiler "zig"
vim.opt_local.makeprg = "zig run %"

vim.api.nvim_create_autocmd('BufWritePre', {
	pattern = { "*.zig", "*.zon" },
	callback = function()
		vim.lsp.buf.code_action({
			context = {
				diagnostics = {},
				only = { "source.organizeImports" }
			},
			apply = true,
		})
	end
})

-- are we exercisming?
if string.find(vim.fn.expand("%:p"):lower(), "exercism") ~= nil then
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("exercism_zig", { clear = true }),
		pattern = "*.zig",
		command = [[!zig test test_%]]
	})
end
