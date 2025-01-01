-- recipes from https://cmp.saghen.dev/recipes.html#hide-copilot-on-suggestion
vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpCompletionMenuOpen',
  callback = function()
    local api = require("supermaven-nvim.api")
    if api.is_running() then
      require('supermaven-nvim.completion_preview').on_dispose_inlay()
      api.stop()
    end
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpCompletionMenuClose',
  callback = function()
    local api = require("supermaven-nvim.api")
    if not api.is_running() then api.start() end
  end,
})

return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    {
      "supermaven-inc/supermaven-nvim",
      opts = {
        keymaps = {
          accept_suggestion = "<C-CR>",
          clear_suggestion = "<C-e>",
          accept_word = "<Tab>",
        }
      },
    },
  },

  version = '*',
  event = { "CmdlineEnter" },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = 'super-tab' },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
      kind_icons = {
        Supermaven = "",
        Text = '󰉿',
        Method = '󰊕',
        Function = '󰊕',
        Constructor = '󰒓',

        Field = '󰜢',
        Variable = '󰆦',
        Property = '󰖷',

        Class = '󱡠',
        Interface = '󱡠',
        Struct = '󱡠',
        Module = '󰅩',

        Unit = '󰪚',
        Value = '󰦨',
        Enum = '󰦨',
        EnumMember = '󰦨',

        Keyword = '󰻾',
        Constant = '󰏿',

        Snippet = '󱄽',
        Color = '󰏘',
        File = '󰈔',
        Reference = '󰬲',
        Folder = '󰉋',
        Event = '󱐋',
        Operator = '󰪚',
        TypeParameter = '󰬛',
      },
    },

    completion = {
      menu = {
        -- nvim-cmp style menu
        draw = {
          columns = {
            { "label",     "label_description", gap = 1 },
            { "kind_icon", "kind" }
          },
        }
      },
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      ghost_text = { enabled = true },
      list = {
        selection = function(ctx)
          return ctx.mode == 'cmdline' and 'auto_insert' or 'preselect'
        end
      },
    },

    signature = { enabled = true },

    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lsp = { fallbacks = { "lazydev" } }, -- dont show LuaLS require statements when lazydev has items
        lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
      },
    },
  },
  opts_extend = { "sources.default" },
}
