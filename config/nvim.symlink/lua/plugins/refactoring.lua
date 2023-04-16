local opts = { noremap = true, silent = true, expr = false }
local k = vim.api.nvim_set_keymap

-- Remaps for the refactoring operations currently offered by the plugin
k("v", "<leader>ref", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR> ]], opts)
k("v", "<leader>rff", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR> ]], opts)
k("v", "<leader>rev", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR> ]], opts)
k("v", "<leader>riv", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR> ]], opts)

-- Inline variable can also pick up the identifier currently under the cursor without visual mode
k("n", "<leader>riv", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR> ]], opts)

-- -- Extract block doesn't need visual mode
k("n", "<leader>reb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]], opts)
k("n", "<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]], opts)

return {
	{ "ThePrimeagen/refactoring.nvim", config = true },
}
