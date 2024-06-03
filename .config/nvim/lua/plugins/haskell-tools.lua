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
			local ht = require("haskell-tools")
			local fn = {
				hs = ht.hoogle.hoogle_signature,
				bea = ht.lsp.buf_eval_all,
				q = ht.repl.quit,
				t = function()
					ht.repl.toggle(vim.api.nvim_buf_get_name(0))
				end,
				rt = function()
					ht.repl.toggle(vim.api.nvim_buf_get_name(0))
				end,
			}
			local buffnr = vim.api.nvim_get_current_buf()
			local def_opts = { noremap = true, silent = true }
			local opts = vim.tbl_extend("keep", def_opts, { buffer = buffnr })
			return {
				{ "<leader>hs", fn.hs, opts },
				{ "<leader>hea", fn.bea, opts },
				{ "<leader>hr", fn.t, opts },
				{ "<leader>hq", fn.q, opts },
				{ "<leader>hf", fn.rt, def_opts },
			}
		end,
	},
}
