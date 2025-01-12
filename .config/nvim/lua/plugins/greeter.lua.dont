return {
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VimEnter",
		init = function()
			local function lines(str)
				local result = {}
				for line in str:gmatch("[^\n]+") do
					table.insert(result, line)
				end
				return result
			end

			local startify = require("alpha.themes.startify")
			local handle = io.popen("fortune -s")
			if handle then
				local fortune = handle:read("*a")
				handle:close()
				startify.section.header.val = lines(fortune)
			end
			vim.cmd([[autocmd User AlphaReady set showtabline=0 | autocmd BufUnload <buffer> set showtabline=1]])
			vim.cmd([[autocmd User AlphaReady set laststatus=0 | autocmd BufUnload <buffer> set laststatus=3]])
			require("alpha").setup(startify.config)
			vim.cmd([[autocmd User AlphaReady echo 'ready']])
		end,
	},
}
