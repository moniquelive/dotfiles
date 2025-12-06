vim.cmd.compiler("ruby")
vim.opt_local.makeprg = "ruby --yjit %"

vim.cmd.iabbrev("fsl", "# frozen_string_literal: true")

local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
if #lines == 1 and lines[1] == "" then
	local skeleton = [[#! /usr/bin/env ruby
# frozen_string_literal: true

]]
	local skeleton_lines = vim.split(skeleton, "\n")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, skeleton_lines)
	vim.api.nvim_win_set_cursor(0, { 4, 1 })
end
