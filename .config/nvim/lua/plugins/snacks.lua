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
      { "<leader>lg", function() Snacks.lazygit() end,                 desc = "Lazygit" },
      { "<leader>fn", function() Snacks.notifier.show_history() end,   desc = "Notifier" },
      { "<leader>fs", function() Snacks.scratch() end,                 desc = "Toggle Scratch Buffer" },
      { "<leader>un", function() Snacks.notifier.hide() end,           desc = "Dismiss All Notifications" },
      { "]w",         function() Snacks.words.jump(vim.v.count1) end,  desc = "Next Reference",           mode = { "n", "t" } },
      { "[w",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference",           mode = { "n", "t" } },
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
          { title = "MRU ", icon = " ", section = "recent_files", title = "Recent Files", limit = 8, padding = 1 },
          { section = "startup" },
          { pane = 2, section = "terminal", cmd = "fortune -s computers", hl = "header", padding = 1 },
          { pane = 2, section = "projects", padding = 1, icon = " ", title = "Projects" },
        },
      },
      indent = {
        indent = { enabled = true },
        animate = { easing = "inOutCubic" }, -- https://github.com/kikito/tween.lua?tab=readme-ov-file#easing-functions
      },
      input = { enabled = true },
      lazygit = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scratch = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true, folds = { open = true } },
      words = { enabled = true },
      styles = { notification = { wo = { wrap = true } } },
    },
  }
}
