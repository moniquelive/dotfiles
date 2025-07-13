vim.cmd.compiler "ruby"
vim.opt_local.makeprg = "ruby --yjit %"

vim.cmd.iabbrev("fsl", "# frozen_string_literal: true")
