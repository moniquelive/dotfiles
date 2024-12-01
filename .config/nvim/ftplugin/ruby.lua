vim.cmd.iabbrev("fsl", "# frozen_string_literal: true")
vim.keymap.set("n", "<f5>", "<cmd>!ruby %<cr>", { silent = true })
