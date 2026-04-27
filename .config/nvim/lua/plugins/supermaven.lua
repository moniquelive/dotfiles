return {
	"supermaven-inc/supermaven-nvim",
	event = "InsertEnter",
	opts = {
		disable_inline_completion = false,
		disable_keymaps = true,
		log_level = "off",
	},
	config = function(_, opts)
		local logger = require("supermaven-nvim.logger")
		local warn = logger.warn
		logger.warn = function() end
		require("supermaven-nvim").setup(opts)
		logger.warn = warn

		require("supermaven-nvim.document_listener").teardown()

		local function trigger_supermaven()
			if vim.bo.buftype ~= "" then return "" end

			local bufnr = vim.api.nvim_get_current_buf()
			local file_name = vim.api.nvim_buf_get_name(bufnr)
			if file_name == "" then return "" end

			local binary = require("supermaven-nvim.binary.binary_handler")
			local suggestion = require("supermaven-nvim.completion_preview")
			local util = require("supermaven-nvim.util")

			suggestion.on_dispose_inlay()

			local cursor = vim.api.nvim_win_get_cursor(0)
			local buffer_text = util.get_text(bufnr)
			binary:document_changed(file_name, buffer_text)
			binary:provide_inline_completion_items(bufnr, cursor, {
				document_text = buffer_text,
				cursor = cursor,
				file_name = file_name,
			})

			return ""
		end

		vim.keymap.set("i", "<F2>", trigger_supermaven, {
			expr = true,
			silent = true,
			desc = "Trigger Supermaven",
		})

		vim.api.nvim_create_user_command("SupermavenTrigger", function()
			trigger_supermaven()
		end, {})

		vim.api.nvim_create_autocmd({ "CursorMovedI", "TextChangedI", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("SupermavenManualMode", { clear = true }),
			callback = function()
				require("supermaven-nvim.completion_preview").on_dispose_inlay()
			end,
		})
	end,
}
