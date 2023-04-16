local opts = { noremap = true, silent = true, expr = false }
local call = [[ lua require('refactoring').refactor ]]

return {
	{
		"ThePrimeagen/refactoring.nvim",
		keys = {
			-- Remaps for the refactoring operations currently offered by the plugin
			{ "<leader>ref", [[ <Esc><Cmd> ]] .. call .. [[ ('Extract Function')<CR> ]], mode = "v", opts },
			{ "<leader>rff", [[ <Esc><Cmd> ]] .. call .. [[ ('Extract Function To File')<CR> ]], mode = "v", opts },
			{ "<leader>rev", [[ <Esc><Cmd> ]] .. call .. [[ ('Extract Variable')<CR> ]], mode = "v", opts },
			{ "<leader>riv", [[ <Esc><Cmd> ]] .. call .. [[ ('Inline Variable')<CR> ]], mode = "v", opts },

			-- Inline variable can also pick up the identifier currently under the cursor without visual mode
			{ "<leader>riv", [[ <Cmd> ]] .. call .. [[ ('Inline Variable')<CR> ]], opts },

			-- -- Extract block doesn't need visual mode
			{ "<leader>reb", [[ <Cmd> ]] .. call .. [[ ('Extract Block')<CR>]], opts },
			{ "<leader>rbf", [[ <Cmd> ]] .. call .. [[ ('Extract Block To File')<CR>]], opts },
		},
	},
}
