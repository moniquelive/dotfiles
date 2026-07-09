local path = require("config.path")
local skeleton = require("config.skeleton")

vim.cmd.compiler("ruby")
vim.opt_local.makeprg = "ruby --zjit %:p:S"

vim.cmd.iabbrev("<buffer>", "fsl", "# frozen_string_literal: true")
local undo_ftplugin = vim.b.undo_ftplugin
vim.b.undo_ftplugin = (undo_ftplugin and undo_ftplugin ~= "" and (undo_ftplugin .. " | ") or "")
	.. "silent! iunabbrev <buffer> fsl"

if path.is_exercism() then vim.opt_local.makeprg = "minitest ." end

skeleton.insert_if_empty(
	[[#! /usr/bin/env ruby
# frozen_string_literal: true

]],
	{ 4, 1 }
)
