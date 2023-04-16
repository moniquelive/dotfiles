local function opts()
	local ht = require("haskell-tools")
	return {
		repl = { handler = "toggleterm" },
		definition = { hoogle_signature_fallback = true },
		hoogle = { mode = "auto" },
		hls = {
			default_settings = {
				haskell = {
					formattingProvider = "ormolu",
				},
			},
			on_attach = function(_, bufnr)
				local o = { noremap = true, silent = true, buffer = bufnr }
				vim.keymap.set("n", "<leader>ca", vim.lsp.codelens.run, o)
				vim.keymap.set("n", "<leader>hs", ht.hoogle.hoogle_signature, o)
				vim.keymap.set("n", "<leader>ea", ht.lsp.buf_eval_all, o)
			end,
		},
	}
end

local function keys()
	local o = { noremap = true, silent = true }
	return {
		{
			"<leader>hr",
			function()
				require("haskell-tools").repl.toggle()
			end,
			o,
		},
		{
			"<leader>hq",
			function()
				require("haskell-tools").repl.quit()
			end,
			o,
		},
		{
			"<leader>hf",
			function()
				require("haskell-tools").repl.toggle(vim.api.nvim_buf_get_name(0))
			end,
			vim.tbl_extend("keep", o, { buffer = vim.api.nvim_get_current_buf() }),
		},
	}
end

return {
	{ "mrcjkb/haskell-tools.nvim", opts = opts, ft = "haskell", keys = keys },
}
