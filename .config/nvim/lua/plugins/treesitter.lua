return {
	{ "RRethy/nvim-treesitter-endwise", event = "InsertEnter" },
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter")

			-- stylua: ignore
			local ensure_installed = {
				"bash", "c", "clojure", "css", "dockerfile", "elixir",
				"gitcommit", "go", "gomod", "gosum", "gowork",
				"haskell", "heex", "html", "javascript", "json",
				"lua", "markdown", "markdown_inline",
				"python", "query", "ruby", "rust",
				"swift", "toml", "tsx", "typescript",
				"vim", "vimdoc", "yaml", "zig",
			}

			local already_installed = treesitter.get_installed("parsers") or {}
			local installed_set = {}
			vim.iter(already_installed):each(function(parser) installed_set[parser] = true end)

			local parsers_to_install = vim.iter(ensure_installed)
				:filter(function(parser) return not installed_set[parser] end)
				:totable()
			if #parsers_to_install > 0 then treesitter.install(parsers_to_install) end

			local treesitter_group = vim.api.nvim_create_augroup("treesitter_features", { clear = true })

			vim.api.nvim_create_autocmd("FileType", {
				group = treesitter_group,
				callback = function(ev)
					-- Enable treesitter highlighting and disable regex syntax
					local ok = pcall(vim.treesitter.start, ev.buf)
					-- Enable treesitter-based indentation
					if ok then vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
				end,
			})

			vim.keymap.set("n", "<M-UP>", "van", { silent = true, desc = "Treesitter init selection" })
			vim.keymap.set("x", "<M-UP>", "an", { silent = true, desc = "Treesitter expand selection" })
			vim.keymap.set("x", "<M-RIGHT>", "]n", { silent = true, desc = "Treesitter next node" })
			vim.keymap.set("x", "<M-DOWN>", "in", { silent = true, desc = "Treesitter shrink selection" })

			vim.treesitter.query.add_predicate("is-mise?", function(_, _, bufnr, _)
				local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
				local filename = vim.fn.fnamemodify(filepath, ":t")
				return string.match(filename, "^%.?mise%.toml$") ~= nil
			end, { force = true, all = false })
		end,
	},
}
