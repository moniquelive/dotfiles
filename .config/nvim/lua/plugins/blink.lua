local group = vim.api.nvim_create_augroup("supermaven-blink", { clear = true })

-- recipes from https://cmp.saghen.dev/recipes.html#hide-copilot-on-suggestion
vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpMenuOpen',
  group = group,
  callback = function(ev)
    -- TODO: hacky, but works
    local ns_id = vim.api.nvim_create_namespace("supermaven")
    vim.api.nvim_buf_del_extmark(ev.buf, ns_id, 1)

    local api = require("supermaven-nvim.api")
    if api.is_running() then api.stop() end
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpMenuClose',
  group = group,
  callback = function(ev)
    -- TODO: hacky, but works
    local ns_id = vim.api.nvim_create_namespace("supermaven")
    vim.api.nvim_buf_del_extmark(ev.buf, ns_id, 1)

    local api = require("supermaven-nvim.api")
    if not api.is_running() then api.start() end
  end,
})

return {
  'saghen/blink.cmp',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
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

  version = '1.*',
  event = { "CmdlineEnter" },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = 'super-tab' },
    cmdline = {
      completion = { list = { selection = { preselect = false } } },
      keymap = { preset = 'enter', },
    },

    appearance = {
      highlight_ns = vim.api.nvim_create_namespace('blink_cmp'),
      use_nvim_cmp_as_default = false,
      nerd_font_variant = 'mono',
      kind_icons = {
        -- Supermaven = "",
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
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      trigger = { show_in_snippet = false },
      menu = {
        auto_show = function(_ --[[ctx]]) return not vim.tbl_contains({ '/', '?' }, vim.fn.getcmdtype()) end,

        -- nvim-cmp style menu
        draw = {
          treesitter = { 'lsp' },
          columns = {
            { "label",     "label_description", gap = 1 },
            { "kind_icon", "kind" }
          },
          components = {
            -- no icons for cmdline
            kind_icon = { text = function(ctx) return ctx.item.source_id == "cmdline" and "" or ctx.kind_icon end },
            kind = { text = function(ctx) return ctx.item.source_id == "cmdline" and "" or ctx.kind end },
          },
        }
      },
      ghost_text = { enabled = false },
      list = {
        selection = {
          preselect = function(ctx) return ctx.mode ~= 'cmdline' end,
          auto_insert = function(ctx) return ctx.mode ~= 'cmdline' end
        },
      },
    },
    signature = { enabled = true, window = { border = 'rounded' } },
    sources = {
      default = function()
        local success, node = pcall(vim.treesitter.get_node)
        if vim.bo.filetype == 'lua' then
          return { 'lazydev', 'lsp', 'path' }
        elseif success and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
          return { 'buffer' }
        else
          return { 'lsp', 'path', 'snippets' }
        end
      end,
      providers = {
        lsp = { fallbacks = { "lazydev" } }, -- dont show LuaLS require statements when lazydev has items
        lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        snippets = {
          should_show_items = function(ctx) return ctx.trigger.initial_kind ~= 'trigger_character' end
        },
      },
    },
    fuzzy = { implementation = "prefer_rust" }
  },
  opts_extend = { "sources.default" },
}
