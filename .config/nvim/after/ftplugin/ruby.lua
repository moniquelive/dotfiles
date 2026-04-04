local path = require("config.path")
local skeleton = require("config.skeleton")

vim.cmd.compiler("ruby")
vim.opt_local.makeprg = "ruby --zjit %"

vim.cmd.iabbrev("fsl", "# frozen_string_literal: true")

if path.is_exercism() then
	vim.opt_local.makeprg = "minitest ."
end

skeleton.insert_if_empty([[#! /usr/bin/env ruby
# frozen_string_literal: true

]], { 4, 1 })
