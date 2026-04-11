local M = {}
local mini_starter = require("config.mini_starter")

function M.setup(mini)
	vim.iter({
		function() require("mini.icons").setup() end,
		function() require("mini.ai").setup() end,
		function()
			require("mini.align").setup({
				mappings = {
					start = "gl",
					start_with_preview = "gL",
				},
			})
		end,
		function() require("mini.bracketed").setup() end,
		function() require("mini.comment").setup() end,
		function()
			require("mini.move").setup({
				mappings = {
					left = "<C-M-h>",
					right = "<C-M-l>",
					down = "<C-M-j>",
					up = "<C-M-k>",
					line_left = "<C-M-h>",
					line_right = "<C-M-l>",
					line_down = "<C-M-j>",
					line_up = "<C-M-k>",
				},
			})
		end,
		function() require("mini.splitjoin").setup() end,
		function() require("mini.surround").setup() end,
		function() require("mini.diff").setup() end,
		function() mini.pick.setup() end,
		function() mini.extra.setup() end,
		function() mini.notify.setup() end,
		function() mini_starter.setup(mini.starter) end,
		function()
			mini.indentscope.setup({
				symbol = "│",
				mappings = {
					object_scope = "",
					object_scope_with_border = "",
					goto_top = "",
					goto_bottom = "",
				},
			})
		end,
		function() require("mini.statusline").setup() end,
		function() require("mini.trailspace").setup() end,
		function() mini.misc.setup_restore_cursor() end,
		function() mini.misc.setup_termbg_sync() end,
	}):each(function(setup)
		setup()
	end)
end

return M
