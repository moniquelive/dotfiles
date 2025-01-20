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

local command = ""
if string.find(vim.fn.expand("%:p"):lower(), "/exercism/") ~= nil then -- are we exercisming?
	command = [[lcd %:p:h | compiler zig_test | setlocal makeprg=zig\ test\ test_%:t]]
elseif #vim.fn.findfile("build.zig", vim.fn.expand("%:p:h") .. ";") > 0 then
	command = [[setlocal makeprg=zig\ build\ run\ %]]
else
	command = [[setlocal makeprg=zig\ run\ %]]
end

local group = vim.api.nvim_create_augroup("zig_config", { clear = true });
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	group = group,
	pattern = "*.zig",
	command = command,
})
