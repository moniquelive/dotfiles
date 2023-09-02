return {
  {
    "mrcjkb/haskell-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "akinsho/toggleterm.nvim", "nvim-telescope/telescope.nvim" },
    branch = "2.x.x",
    init = function()
      vim.g.haskell_tools = {
        tools = {
          repl = { handler = "toggleterm" },
          definition = { hoogle_signature_fallback = true },
        },
      }
    end,
    ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
    keys = function()
      local ht = require("haskell-tools")
      local buffnr = vim.api.nvim_get_current_buf()
      local def_opts = { noremap = true, silent = true }
      local opts = vim.tbl_extend("keep", def_opts, { buffer = buffnr })
      return {
        { "<leader>ca", vim.lsp.codelens.run,       opts },
        { "<leader>hs", ht.hoogle.hoogle_signature, opts },
        { "<leader>ea", ht.lsp.buf_eval_all,        opts },
        { "<leader>hr", ht.repl.toggle,             opts },
        { "<leader>hq", ht.repl.quit,               opts },
        {
          "<leader>hf",
          function()
            ht.repl.toggle(vim.api.nvim_buf_get_name(0))
          end,
          def_opts,
        },
      }
    end,
  },
}
