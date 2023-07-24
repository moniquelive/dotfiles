return {
	{
		"kyazdani42/nvim-tree.lua",
		--dir = "~/prj/lua/nvim-tree.lua",
		opts = {
			hijack_netrw = false,
			respect_buf_cwd = true,
			--sort_by = "extension",
			--sort_by = "filetype",
			sort_by = "suffix",
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
		},
		cmd = "NvimTreeToggle",
		keys = {
			{ "<s-tab>", "<cmd>NvimTreeToggle<cr>", { noremap = true, silent = true } },
		},
	},
}
