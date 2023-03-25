local ok, nvim_tree = pcall(require, "nvim-tree")
if not ok then
  return
end
nvim_tree.setup({
  hijack_netrw = false,
  respect_buf_cwd = true,
  sort_by = "extension",
  reload_on_bufenter = true,
  update_focused_file = {
    enable = true,
  },
  view = {
    width = 40,
  },
  renderer = {
    group_empty = true,
    highlight_git = true,
  },
  diagnostics = {
    enable = true,
  },
})
local api = require("nvim-tree.api")
local bufopts = { noremap = true, silent = true }
vim.keymap.set("n", "<s-tab>", api.tree.toggle, bufopts)
