return {
  'saghen/blink.cmp',
  dependencies = 'rafamadriz/friendly-snippets',

  -- version = 'v0.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = 'super-tab' },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono'
    },

    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    signature = { enabled = true }
  },
  opts_extend = { "sources.default" }
}
