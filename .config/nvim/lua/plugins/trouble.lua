vim.cmd([[autocmd! FileType Trouble set wrap]])

local function next()
	require("trouble").next({ skip_groups = true, jump = true })
end

local function previous()
	require("trouble").previous({ skip_groups = true, jump = true })
end

return {
	{
		"folke/trouble.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		cmd = "TroubleToggle",
		keys = {
			{ "]t", next },
			{ "[t", previous },
			{ "<leader>xx", "<cmd>TroubleToggle<cr>" },
			-- { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>" },
			-- { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>" },
			-- { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>" },
			-- { "<leader>xl", "<cmd>TroubleToggle loclist<cr>" },
			--{ "gR", "<cmd>TroubleToggle lsp_references<cr>" },
		},
	},
}
