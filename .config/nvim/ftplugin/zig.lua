-- Only run the ftplugin code once per buffer.
if vim.b.did_ftplugin_zig then return end
vim.b.did_ftplugin_zig = true

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

local local_path = vim.fn.expand("%:p:h")
local command = ""
if string.find(local_path:lower(), "/exercism/") ~= nil then     -- are we exercisming?
	command = [[lcd %:p:h | compiler zig_test | setlocal makeprg=zig\ test\ test_%:t]]
elseif #vim.fn.findfile("build.zig", local_path .. ";") > 0 then -- are we in a project?
	command = [[setlocal makeprg=zig\ build\ run]]
else                                                             -- standalone
	command = [[setlocal makeprg=zig\ run\ %]]
end

local group = vim.api.nvim_create_augroup("zig_config", { clear = true });
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" },
	{ group = group, pattern = "*.zig", command = command })
