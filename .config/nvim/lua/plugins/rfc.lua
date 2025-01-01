return {
  {
    -- dir = '~/prj/lua/rfc.nvim',
    "moniquelive/rfc.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("rfc")
    end,
  }
}
