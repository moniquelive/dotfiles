local ok, refactoring = pcall(require, "refactoring")
if not ok then
  return
end
refactoring.setup()
-- local opts = { noremap = true, silent = true, expr = false }
-- Remaps for the refactoring operations currently offered by the plugin
-- vim.api.nvim_set_keymap( "v", "<leader>ref", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR> ]], opts)
-- vim.api.nvim_set_keymap( "v", "<leader>rff", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR> ]], opts)
-- vim.api.nvim_set_keymap( "v", "<leader>rev", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR> ]], opts)
-- vim.api.nvim_set_keymap( "v", "<leader>riv", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR> ]], opts)

-- Inline variable can also pick up the identifier currently under the cursor without visual mode
-- vim.api.nvim_set_keymap( "n", "<leader>riv", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR> ]], opts)

-- -- Extract block doesn't need visual mode
-- vim.api.nvim_set_keymap( "n", "<leader>reb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]], opts)
-- vim.api.nvim_set_keymap( "n", "<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]], opts)
