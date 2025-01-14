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

local group = vim.api.nvim_create_augroup("zig_config", { clear = true });
if string.find(vim.fn.expand("%:p"):lower(), "/exercism/") ~= nil then -- are we exercisming?
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		group = group,
		pattern = "*.zig",
		command = [[lcd %:p:h | compiler zig_test | setlocal makeprg=zig\ test\ test_%:t]],
	})
else
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		group = group,
		pattern = "*.zig",
		command = [[setlocal makeprg=zig\ run\ %]],
	})
end
