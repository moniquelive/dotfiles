local M = {}

local function keymaps(bufnr)
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	--vim.keymap.set("n", "<c-k>", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
	-- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", bufopts)
	-- treesitter-rename: vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, bufopts)
	vim.keymap.set("n", "<F3>", vim.lsp.buf.code_action, bufopts)
	-- vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
	vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", bufopts)
	vim.keymap.set(
		"v",
		"<leader>frr",
		[[ <ESC><cmd>lua require("telescope").extensions.refactoring.refactors()<CR> ]],
		{}
	)
	vim.keymap.set("n", "<leader>f", function()
		vim.lsp.buf.format({ timeout = 15000 })
	end, bufopts)
	-- vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
end

function M.on_attach(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Mappings.
	keymaps(bufnr)

	if client.server_capabilities.documentHighlightProvider then
		vim.cmd([[
      hi! LspReferenceText cterm=bold ctermbg=red guibg=#403040
      hi! LspReferenceRead cterm=bold ctermbg=red guibg=#106010
      hi! LspReferenceWrite cterm=bold ctermbg=red guibg=#601010
    ]])
		local augroup = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
		vim.api.nvim_clear_autocmds({ buffer = bufnr, group = augroup })
		vim.api.nvim_create_autocmd(
			{ "CursorHold", "CursorHoldI" },
			{ group = augroup, buffer = bufnr, callback = vim.lsp.buf.document_highlight }
		)
		vim.api.nvim_create_autocmd(
			{ "CursorMoved", "CursorMovedI" },
			{ group = augroup, buffer = bufnr, callback = vim.lsp.buf.clear_references }
		)
	end

	if client.supports_method("textDocument/formatting") then
		local augroup = vim.api.nvim_create_augroup("lsp_document_formatting", { clear = false })
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 15000 })
			end,
		})
	end
end

return M
