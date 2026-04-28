-- stylua: ignore
return {
  { "tpope/vim-characterize", keys = "ga" },
  { "tpope/vim-repeat",       event = { "BufRead", "BufNewFile" } },
  { "tpope/vim-rsi",          event = { "InsertEnter", "CmdlineEnter" } },
  { "tpope/vim-sleuth",       event = { "BufRead", "BufNewFile" } },
}
