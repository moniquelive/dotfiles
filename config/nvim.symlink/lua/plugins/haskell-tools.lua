local def_opts = { noremap = true, silent = true }

return {
	{
		"mrcjkb/haskell-tools.nvim",
		dependencies = { "akinsho/toggleterm.nvim" },
		opts = {
			tools = {
				repl = { handler = "toggleterm" },
				definition = { hoogle_signature_fallback = true },
			},
			hls = {
				on_attach = function(_, bufnr)
					local opts = vim.tbl_extend("keep", def_opts, { buffer = bufnr })
					local ht = require("haskell-tools")
					vim.keymap.set("n", "<leader>ca", vim.lsp.codelens.run, opts)
					vim.keymap.set("n", "<leader>hs", ht.hoogle.hoogle_signature, opts)
					vim.keymap.set("n", "<leader>ea", ht.lsp.buf_eval_all, opts)
				end,
			},
		},
		ft = "haskell",
		keys = function()
			local repl = require("haskell-tools.repl")
			local buffnr = vim.api.nvim_get_current_buf()
			local opts = vim.tbl_extend("keep", def_opts, { buffer = buffnr })
			return {
				{ "<leader>hr", repl.toggle, opts },
				{ "<leader>hq", repl.quit, opts },
				{
					"<leader>hf",
					function()
						repl.toggle(vim.api.nvim_buf_get_name(0))
					end,
					def_opts,
				},
			}
		end,
	},
}
