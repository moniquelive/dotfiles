---@module 'snacks'

---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
local progress = vim.defaulttable()
vim.api.nvim_create_autocmd("LspProgress", {
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
    local value = ev.data.params.value
    if not client or type(value) ~= "table" then return end
    local p = progress[client.id]

    for i = 1, #p + 1 do
      if i == #p + 1 or p[i].token == ev.data.params.token then
        p[i] = {
          token = ev.data.params.token,
          msg = ("[%3d%%] %s%s"):format(
            value.kind == "end" and 100 or value.percentage or 100,
            value.title or "",
            value.message and (" **%s**"):format(value.message) or ""
          ),
          done = value.kind == "end",
        }
        break
      end
    end

    local msg = {} ---@type string[]
    progress[client.id] = vim.tbl_filter(function(v)
      return table.insert(msg, v.msg) or not v.done
    end, p)

    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    vim.notify(table.concat(msg, "\n"), "info", {
      id = "lsp_progress",
      title = client.name,
      opts = function(notif)
        notif.icon = #progress[client.id] == 0 and " "
            or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
      end,
    })
  end,
})

return {
  {
    "folke/snacks.nvim",
    dependencies = {
      { "lewis6991/gitsigns.nvim", opts = {} },
    },
    priority = 1000,
    lazy = false,
    keys = {
      { "<leader>lg",      function() Snacks.lazygit() end,                                        desc = "Lazygit" },
      { "<leader>fn",      function() Snacks.notifier.show_history() end,                          desc = "Notifier" },
      { "<leader>fs",      function() Snacks.scratch() end,                                        desc = "Toggle Scratch Buffer" },
      { "<leader>hn",      function() Snacks.notifier.hide() end,                                  desc = "Dismiss All Notifications" },
      { "<m-right>",       function() Snacks.words.jump(vim.v.count1, true) end,                   desc = "Next Reference",           mode = { "n", "t" } },
      { "<m-left>",        function() Snacks.words.jump(-vim.v.count1, true) end,                  desc = "Prev Reference",           mode = { "n", "t" } },
      { "<c-p>",           function() Snacks.picker.files() end,                                   desc = "Find Files",               mode = { "n", "t" } },
      { "<leader>fb",      function() Snacks.picker.buffers() end,                                 desc = "List buffers",             mode = { "n", "t" } },
      { "<leader>fd",      function() Snacks.picker.diagnostics_buffer() end,                      desc = "List diagnostics",         mode = { "n", "t" } },
      { "<leader>fl",      function() Snacks.picker.grep() end,                                    desc = "Grep",                     mode = { "n", "t" } },
      { "<leader>fr",      function() Snacks.picker.registers() end,                               desc = "List registers",           mode = { "n", "t" } },
      { "<leader>fh",      function() Snacks.picker.help() end,                                    desc = "Search help tags",         mode = { "n", "t" } },
      { "<leader>fm",      function() Snacks.picker.keymaps() end,                                 desc = "List keymaps",             mode = { "n", "t" } },
      { "<leader>qf",      function() Snacks.picker.qflist() end,                                  desc = "List quickfix items",      mode = { "n", "t" } },
      { "<leader>fgf",     function() Snacks.picker.git_files() end,                               desc = "Find git files",           mode = { "n", "t" } },
      { "<leader>fk",      function() Snacks.picker.marks() end,                                   mode = { "n", "t" } },
      { "<leader>fo",      function() Snacks.picker.commands() end,                                mode = { "n", "t" } },
      { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find config files",        mode = { "n", "t" } },
      { "<leader><space>", function() Snacks.picker.lines() end,                                   mode = { "n", "t" } },
      { "<leader>ft",      function() Snacks.picker.colorschemes() end,                            mode = { "n", "t" } },
      { "<s-tab>",         function() Snacks.explorer() end,                                       mode = { "n", "t" } },
    },
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true, notify = true, size = 1024 * 1024 },
      dashboard = {
        enabled = true,
        sections = {
          { title = "MRU", padding = 1 },
          { file = vim.fn.fnamemodify(".", ":~"), padding = 1 },
          { section = "recent_files", cwd = true, limit = 8, padding = 1 },
          { icon = " ", section = "recent_files", title = "Recent Files", limit = 8, padding = 1 },
          { section = "startup" },
          { pane = 2, section = "terminal", cmd = "fortune -s computers", hl = "header", padding = 1 },
          { pane = 2, section = "projects", padding = 1, icon = " ", title = "Projects" },
        },
      },
      explorer = { enabled = true },
      image = { enabled = true },
      indent = {
        indent = { enabled = true },
        animate = { easing = "inOutCubic" }, -- https://github.com/kikito/tween.lua?tab=readme-ov-file#easing-functions
      },
      input = { enabled = true },
      lazygit = { enabled = true },
      notifier = { enabled = true },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            auto_close = true,
            replace_netrw = false,
            sort = { fields = { "ext" } }, -- does this work?
            win = { list = { keys = { ["<s-tab>"] = "cancel" } } }
          }
        },
        win = { input = { keys = { ["<c-.>"] = { "toggle_hidden", mode = { "n", "i" } }, ["<Esc>"] = { "close", mode = { "n", "i" } } } } }
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scratch = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true, folds = { open = true, git_hl = true } },
      words = { enabled = true },
      styles = { notification = { wo = { wrap = true } } },
    },
  }
}
