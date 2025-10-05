-- Only run the ftplugin code once per buffer.
if vim.b.did_ftplugin_swift then return end
vim.b.did_ftplugin_swift = true

local command = ""
if string.find(vim.fn.expand("%:p:h"):lower(), "/exercism/") ~= nil then -- are we exercisming?
	command = [[let $RUNALL="true" | lcd %:p:h | setlocal makeprg=swift\ test\ -j\ 10]]
else
	command = [[lcd %:p:h | setlocal makeprg=swift\ %:p]]
end

local group = vim.api.nvim_create_augroup("swift_config", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, { group = group, pattern = "*.swift", command = command })
