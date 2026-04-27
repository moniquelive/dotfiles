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
	end,
}
