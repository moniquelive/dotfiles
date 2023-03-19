local ok, telescope = pcall(require, "telescope")
if not ok then
  return
end
telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = "close",
        ["<C-u>"] = false,
        ["<C-j>"] = "preview_scrolling_down",
        ["<C-k>"] = "preview_scrolling_up",
      },
    },
  },
  extensions = {},
})
telescope.load_extension("refactoring")
telescope.load_extension("fzf")
telescope.load_extension("emoji")
telescope.load_extension("notify")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<c-p>", builtin.find_files, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, {})
vim.keymap.set("n", "<leader>fe", "<cmd>Telescope emoji<CR>", {})
vim.keymap.set("n", "<leader>ft", builtin.tags, {})
vim.keymap.set("n", "<leader>fl", builtin.live_grep, {})
vim.keymap.set("n", "<leader>freg", builtin.registers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
vim.keymap.set("n", "<leader>fm", builtin.keymaps, {})
vim.keymap.set("n", "<leader>fgc", builtin.git_commits, {})
vim.keymap.set("n", "<leader>qf", builtin.quickfix, {})
vim.keymap.set("n", "<leader>fc", builtin.colorscheme, {})
vim.keymap.set("n", "<leader>fcmd", builtin.commands, {})
vim.keymap.set("n", "<leader>fft", builtin.filetypes, {})
vim.keymap.set("n", "<leader>fgf", builtin.git_files, {})
vim.keymap.set("n", "<leader>fhs", builtin.search_history, {})
vim.keymap.set("n", "<leader>fmark", builtin.marks, {})
vim.keymap.set("n", "<leader>fo", builtin.vim_options, {})
-- vim.keymap.set("n", "<leader>fh", builtin.command_history, {})
-- vim.keymap.set("n", "<leader>fl", builtin.current_buffer_fuzzy_find, {})
-- vim.keymap.set("n", "<leader>fgfd", nil, {}) --  :<C-u>GFiles-diff<cr>
-- vim.keymap.set("n", "<leader>fhf", nil, {}) --   :<C-u>History-files<cr>
-- vim.keymap.set("n", "<leader>fw", nil, {}) --    :<C-u>Windows<cr>
-- vim.keymap.set("n", "<leader>fs", nil, {}) --    :<C-u>Snippets<cr>
