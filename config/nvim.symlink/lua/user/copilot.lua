local ok, copilot = pcall(require, "copilot")
if not ok then
	return
end

copilot.setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
})

local ok_cmp, copilot_cmp = pcall(require, "copilot_cmp")
if not ok_cmp then
	return
end
copilot_cmp.setup({})

vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
