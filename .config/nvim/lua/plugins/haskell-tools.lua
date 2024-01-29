local function hs()
	require("haskell-tools").hoogle.hoogle_signature()
end
local function bea()
	require("haskell-tools").lsp.buf_eval_all()
end
local function t()
	require("haskell-tools").repl.toggle(vim.api.nvim_buf_get_name(0))
end
local function q()
	require("haskell-tools").repl.quit()
end
local function rt()
	require("haskell-tools").repl.toggle(vim.api.nvim_buf_get_name(0))
end
return {
	{
		"mrcjkb/haskell-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "akinsho/toggleterm.nvim" },
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
			local buffnr = vim.api.nvim_get_current_buf()
			local def_opts = { noremap = true, silent = true }
			local opts = vim.tbl_extend("keep", def_opts, { buffer = buffnr })
			return {
				{ "<leader>ca", vim.lsp.codelens.run, opts },
				{ "<leader>hs", hs, opts },
				{ "<leader>ea", bea, opts },
				{ "<leader>hr", t, opts },
				{ "<leader>hq", q, opts },
				{ "<leader>hf", rt, def_opts },
			}
		end,
	},
}
