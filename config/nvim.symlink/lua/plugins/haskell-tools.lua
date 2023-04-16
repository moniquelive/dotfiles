local function config()
	-- local buffer = vim.api.nvim_get_current_buf()
	local ht = require("haskell-tools")
	local def_opts = { noremap = true, silent = true }
	ht.setup({
		-- tools = {
		--   log = {
		--     level = vim.log.levels.DEBUG,
		--   },
		-- },
		repl = {
			handler = "toggleterm",
		},
		definition = {
			-- Configure vim.lsp.definition to fall back to hoogle search
			-- (does not affect vim.lsp.tagfunc)
			hoogle_signature_fallback = true,
		},
		hoogle = {
			mode = "auto",
		},
		hls = {
			default_settings = {
				haskell = {
					formattingProvider = "ormolu",
				},
			},
			on_attach = function(_, bufnr)
				local opts = vim.tbl_extend("keep", def_opts, { buffer = bufnr })
				-- haskell-language-server relies heavily on codeLenses,
				-- so auto-refresh (see advanced configuration) is enabled by default
				vim.keymap.set("n", "<leader>ca", vim.lsp.codelens.run, opts)
				vim.keymap.set("n", "<leader>hs", ht.hoogle.hoogle_signature, opts)
				vim.keymap.set("n", "<leader>ea", ht.lsp.buf_eval_all, opts)
			end,
		},
	})

	-- Suggested keymaps that do not depend on haskell-language-server:
	local bufnr = vim.api.nvim_get_current_buf()
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- Toggle a GHCi repl for the current package
	vim.keymap.set("n", "<leader>hr", ht.repl.toggle, opts)
	-- Toggle a GHCi repl for the current buffer
	vim.keymap.set("n", "<leader>hf", function()
		ht.repl.toggle(vim.api.nvim_buf_get_name(0))
	end, def_opts)
	vim.keymap.set("n", "<leader>hq", ht.repl.quit, opts)
end

return {
	{ "mrcjkb/haskell-tools.nvim", config = config },
}
