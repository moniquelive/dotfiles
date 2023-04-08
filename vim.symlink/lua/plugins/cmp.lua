vim.o.completeopt = "menu,menuone,noselect"

local lspkind = require("lspkind")
local types = require("cmp.types")
local cmp = require("cmp")
cmp.setup({
  window = {
    -- completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-k>"] = cmp.mapping.scroll_docs(-4),
    ["<C-j>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }, { "i", "s", "c" }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
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
    { name = "cmp_tabnine" },
    { name = "nvim_lua" },
    {
      name = "nvim_lsp",
      entry_filter = function(entry)
        return types.lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
      end,
    },
    { name = "path" },
    { name = "luasnip" }, -- For luasnip users.
    { name = "buffer", keyword_length = 5 },
  }),
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  formatting = {
    format = lspkind.cmp_format({
      menu = {
        tabnine = "[tn]",
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[api]",
        path = "[path]",
        luasnip = "[snip]",
      },
    }),
  },
  experimental = {
    ghost_text = true,
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