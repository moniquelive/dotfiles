local function config(_, opts)
	require("toggleterm").setup(opts)

	---@diagnostic disable-next-line: duplicate-set-field
	function _G.set_terminal_keymaps()
		local opts = { buffer = 0 }
		local k = vim.keymap.set
		k("t", "<esc>", [[<C-\><C-n>]], opts)
		-- vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
		k("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
		k("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
		-- vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
	end

	vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")

	local Terminal = require("toggleterm.terminal").Terminal
	local gotestsum = Terminal:new({
		cmd = "gotestsum --watch -f dots-v2",
		hidden = true,
		direction = "horizontal",
		---@diagnostic disable-next-line: unused-local
		on_open = function(term)
			local winnr = vim.fn["winnr"]("#")
			local winid = vim.fn["win_getid"](winnr)
			vim.fn["win_gotoid"](winid)
			vim.cmd("stopinsert")
		end,
	})
	---@diagnostic disable-next-line: duplicate-set-field
	function _G._gotestsum_toggle()
		gotestsum:toggle()
	end

	vim.api.nvim_set_keymap("n", "<leader>gt", [[<cmd>lua _gotestsum_toggle()<CR>]], { noremap = true, silent = true })
end

return {
	{
		"akinsho/toggleterm.nvim",
		config = config,
		opts = {
			direction = "horizontal",
			open_mapping = "<leader>tt",
		},
		keys = {
			"<leader>tt",
			"<leader>gt",
		},
	},
}
