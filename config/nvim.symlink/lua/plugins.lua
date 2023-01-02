------------------------------------------------------------- ToggleTerm {{{1
require("toggleterm").setup {
  direction = 'horizontal',
  open_mapping = '<leader>tt',
}
function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end

vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

local Terminal  = require('toggleterm.terminal').Terminal
local gotestsum = Terminal:new {
  cmd = "gotestsum --watch -f dots-v2",
  hidden = true,
  direction = 'horizontal',
  on_open = function(_term)
    local winnr = vim.fn['winnr']('#')
    local winid = vim.fn['win_getid'](winnr)
    vim.fn['win_gotoid'](winid)
    vim.cmd('stopinsert')
  end
}
function _G._gotestsum_toggle()
  gotestsum:toggle()
end

vim.api.nvim_set_keymap("n", "<leader>gt", [[<cmd>lua _gotestsum_toggle()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<leader>tt", [[<cmd>ToggleTerm<CR>]], { noremap = true, silent = true })

------------------------------------------------------------ Refactoring {{{1
require 'refactoring'.setup {
}
-- Remaps for the refactoring operations currently offered by the plugin
vim.api.nvim_set_keymap("v", "<leader>re",
  [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]],
  { noremap = true, silent = true, expr = false })
vim.api.nvim_set_keymap("v", "<leader>rf",
  [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]],
  { noremap = true, silent = true, expr = false })
vim.api.nvim_set_keymap("v", "<leader>rv",
  [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]],
  { noremap = true, silent = true, expr = false })
vim.api.nvim_set_keymap("v", "<leader>ri",
  [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
  { noremap = true, silent = true, expr = false })

-- Extract block doesn't need visual mode
vim.api.nvim_set_keymap("n", "<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]],
  { noremap = true, silent = true, expr = false })
vim.api.nvim_set_keymap("n", "<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]],
  { noremap = true, silent = true, expr = false })

-- Inline variable can also pick up the identifier currently under the cursor without visual mode
vim.api.nvim_set_keymap("n", "<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
  { noremap = true, silent = true, expr = false })

------------------------------------------------------------ Tree plugin {{{1
require "nvim-tree".setup {
  hijack_netrw = false,
  respect_buf_cwd = true,
  sort_by = 'extension',
  reload_on_bufenter = true,
  update_focused_file = {
    enable = true
  }
}

------------------------------------------------------------------ Mason {{{1
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-null-ls").setup({
  -- ensure_installed = nil,
  -- automatic_installation = true,
  automatic_setup = true,
})

-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
vim.o.updatetime = 250
vim.cmd [[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

local lspconfig_on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<F3>', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
  -- vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  -- vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  -- vim.keymap.set('n', '<leader>wl', function()
  -- print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  -- end, bufopts)
  -- vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)

  if client.server_capabilities.documentHighlightProvider then
    vim.cmd [[
      hi! LspReferenceRead cterm=bold ctermbg=red guibg=#403000
      hi! LspReferenceText cterm=bold ctermbg=red guibg=#403000
      hi! LspReferenceWrite cterm=bold ctermbg=red guibg=#403000
    ]]
    vim.api.nvim_create_augroup('lsp_document_highlight', {
      clear = false
    })
    vim.api.nvim_clear_autocmds({
      buffer = bufnr,
      group = 'lsp_document_highlight',
    })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      group = 'lsp_document_highlight',
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      group = 'lsp_document_highlight',
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

require "mason-lspconfig".setup_handlers {
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function(server_name) -- default handler (optional)
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    require("lspconfig")[server_name].setup {
      on_attach = lspconfig_on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = { 'vim' },
          },
        },
      },
    }
  end,
  -- Next, you can provide a dedicated handler for specific servers.
  -- For example, a handler override for the `rust_analyzer`:
  ["rust_analyzer"] = function()
    require("rust-tools").setup {}
  end
}

require('mason-tool-installer').setup {

  -- a list of all tools you want to ensure are installed upon
  -- start; they should be the names Mason uses for each tool
  ensure_installed = {
    -- { '' , version = '1.8.0.0' }, you can pin a tool to a particular version

    'autopep8',
    'css-lsp',
    'diagnostic-languageserver',
    'djlint',
    'dockerfile-language-server',
    'elixir-ls',
    'elm-format',
    'elm-language-server',
    'emmet-ls',
    'flake8',
    'gitlint',
    'gofumpt',
    'goimports',
    'gopls',
    'gotests',
    'gotestsum',
    'haskell-language-server', 'html-lsp',
    'iferr',
    'jedi-language-server',
    'json-lsp',
    'lua-language-server',
    'luacheck',
    'markdownlint',
    'prettierd',
    'pylint',
    'python-lsp-server',
    'revive',
    'semgrep',
    'solargraph',
    'standardrb',
    'staticcheck',
    'stylua',
    'tailwindcss-language-server',
    'vim-language-server',
    'yaml-language-server',
    'yamlfmt',
    'yamllint',
    'yapf',
  },
}

------------------------------------------------------------- Treesitter {{{1
require 'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash",
    "comment", "css",
    "dockerfile",
    "eex", "elixir", "elm",
    "gitcommit", "gitignore", "go",
    "haskell", "heex", "help", "html",
    "javascript", "json",
    "lua",
    "markdown",
    "python",
    "ruby",
    "vim",
    "yaml",
  },

  highlight = {
    enable = true,
    disable = {},
  },

  indent = {
    enable = true,
    disable = {},
  },
}

--------------------------------------------------------------- nvim-cmp {{{1
vim.o.completeopt = 'menu,menuone,noselect'
-- Set up nvim-cmp.
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }, { "i", "s", "c" }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<TAB>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s", "c" }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s", "c" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp',
      entry_filter = function(entry, ctx)
        return require('cmp.types').lsp.CompletionItemKind[entry:get_kind()] ~= 'Text'
      end
    },
    { name = 'emoji' },
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer' },
  })
}

-- `/` cmdline setup.
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  completion = { autocomplete = false },
  sources = {
    {
      name = 'buffer',
      option = {
        keyword_pattern = [=[[^(\v)?[:blank:]].*]=]
      }
    }
  }
})
-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } })
})

--------------------------------------------------------------- Prettier {{{1
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls_on_attach = function(client, bufnr)
  if client.supports_method "textDocument/formatting" then
    vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end
end

local null_ls = require 'null-ls'
null_ls.setup {
  sources = {
    null_ls.builtins.formatting.prettierd.with {
      filetypes = {
        "bash",
        "comment", "css",
        "dockerfile",
        "eex", "elixir", "elm",
        "gitcommit", "gitignore", "go", "golangci_lint",
        "haskell", "heex", "help", "html", "stylish_haskell",
        "javascript", "json", "jq",
        "lua",
        "markdown",
        "python",
        "ruby",
        "standardrb",
        "vim",
        "yaml",
      },
    },
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.completion.spell,
  },
  on_attach = null_ls_on_attach,
}
