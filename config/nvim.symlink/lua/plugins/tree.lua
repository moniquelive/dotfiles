local function config()
	local nvim_tree = require("nvim-tree")
	nvim_tree.setup({
		hijack_netrw = false,
		respect_buf_cwd = true,
		sort_by = "extension",
		reload_on_bufenter = true,
		update_focused_file = {
			enable = true,
		},
		view = {
			width = 40,
		},
		renderer = {
			group_empty = true,
			highlight_git = true,
		},
		diagnostics = {
			enable = true,
		},
	})
	local bufopts = { noremap = true, silent = true }
	vim.keymap.set("n", "<s-tab>", require("nvim-tree.api").tree.toggle, bufopts)
end

return {
	{ "kyazdani42/nvim-tree.lua", cmd = "NvimTreeToggle", keys = "<s-tab>", config = config },
}
