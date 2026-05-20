local M = {}

function M.setup()
	local mini = {
		pick = require("mini.pick"),
		extra = require("mini.extra"),
		notify = require("mini.notify"),
		indentscope = require("mini.indentscope"),
		misc = require("mini.misc"),
	}

	require("config.mini_modules").setup(mini)
	require("config.mini_mappings").setup(mini)
end

return M
