vim.o.completeopt = "menu,menuone,noselect"
local types = require("cmp.types")
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }, { "i", "s", "c" }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ["<TAB>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s", "c" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s", "c" }),
  }),
  sources = cmp.config.sources({
    { name = "luasnip" }, -- For luasnip users.
    {
      name = "nvim_lsp",
      ---@diagnostic disable-next-line: unused-local
      entry_filter = function(entry, _ctx)
        return types.lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
      end,
    },
  }, {
    { name = "path" },
    { name = "buffer", keyword_length = 5 },
  }),
  experimental = {
    native_menu = false,
  },
})

-- `/` cmdline setup.
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  completion = { autocomplete = false },
  sources = {
    {
      name = "buffer",
      option = {
        keyword_pattern = [=[[^(\v)?[:blank:]].*]=],
      },
    },
  },
})
-- `:` cmdline setup.
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})
