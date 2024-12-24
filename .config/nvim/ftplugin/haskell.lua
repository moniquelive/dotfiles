-- ~/.config/nvim/after/ftplugin/haskell.lua
local ht = require("haskell-tools")
local opts = { noremap = true, silent = true, buffer = true }

local bufnr = vim.api.nvim_get_current_buf()
ht.lsp.start(bufnr)

-- haskell-language-server relies heavily on codeLenses,
-- vim.keymap.set("n", "<f1>", ht.hoogle.hoogle_signature, opts)  -- Hoogle search for the type signature of the definition under the cursor
vim.keymap.set("n", "<leader>hcl", vim.lsp.codelens.run, opts) -- so auto-refresh (see advanced configuration) is enabled by default
vim.keymap.set("n", "<leader>hea", ht.lsp.buf_eval_all, opts)  -- Evaluate all code snippets
vim.keymap.set("n", "<leader>hr", ht.repl.toggle, opts)        -- Toggle a GHCi repl for the current package
vim.keymap.set("n", "<leader>hf", function()                   -- Toggle a GHCi repl for the current buffer
	ht.repl.toggle(vim.api.nvim_buf_get_name(0))
end, opts)
vim.keymap.set("n", "<leader>hq", ht.repl.quit, opts)

require("telescope").load_extension("ht")
