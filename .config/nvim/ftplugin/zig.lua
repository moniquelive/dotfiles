vim.cmd.compiler "zig"
vim.opt_local.makeprg = "zig run %"

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

local group = vim.api.nvim_create_augroup("exercism_zig", { clear = true });

-- are we exercisming?
if string.find(vim.fn.expand("%:p"):lower(), "/exercism/") ~= nil then
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		group = group,
		pattern = "*.zig",
		command = [[lcd %:p:h]]
	})
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = "*.zig",
		command = [[!zig test test_*.zig]]
	})
end
