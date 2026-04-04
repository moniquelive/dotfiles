return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		opts = {
			endwise = { enable = true },
			textobjects = { enable = false },
			matchup = { enable = true }, -- mandatory, false will disable the whole extension ,
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<M-UP>", -- set to `false` to disable one of the mappings
					node_incremental = "<M-UP>",
					scope_incremental = "<M-RIGHT>",
					node_decremental = "<M-DOWN>",
				},
			},
		},
		init = function()
			local ensure_installed = {
				"bash",
				"c",
				"css",
				"dockerfile",
				"elixir",
				"gitcommit",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"haskell",
				"heex",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"ruby",
				"rust",
				"swift",
				"toml",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
				"zig",
			}
			local alreadyInstalled = require("nvim-treesitter.config").get_installed()
			local parsersToInstall = vim.iter(ensure_installed)
				:filter(function(parser) return not vim.tbl_contains(alreadyInstalled, parser) end)
				:totable()
			require("nvim-treesitter").install(parsersToInstall)

			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					-- Enable treesitter highlighting and disable regex syntax
					pcall(vim.treesitter.start)
					-- Enable treesitter-based indentation
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})

			require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
				local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
				local filename = vim.fn.fnamemodify(filepath, ":t")
				return string.match(filename, ".*mise.*%.toml$") ~= nil
			end, { force = true, all = false })
		end,
	},
}
