return {
	{ "RRethy/nvim-treesitter-endwise", event = { "BufReadPre", "BufNewFile" } },
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
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

			local treesitter_group = vim.api.nvim_create_augroup("treesitter_features", { clear = true })
			local function enable_features(bufnr)
				if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].filetype == "" then return end

				-- Enable treesitter highlighting and disable regex syntax.
				local ok = pcall(vim.treesitter.start, bufnr)
				if not ok then return end

				local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
				local query_ok, query = pcall(vim.treesitter.query.get, lang, "indents")
				if query_ok and query then vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = treesitter_group,
				callback = function(event) enable_features(event.buf) end,
			})

			local installed_set = {}
			vim.iter(treesitter.get_installed("parsers") or {}):each(function(parser) installed_set[parser] = true end)
			local parsers_to_install = vim.iter(ensure_installed)
				:filter(function(parser) return not installed_set[parser] end)
				:totable()
			if #parsers_to_install > 0 then
				treesitter.install(parsers_to_install):await(function(err, installed)
					vim.schedule(function()
						if err or not installed then
							vim.notify("Treesitter parser installation failed: " .. tostring(err), vim.log.levels.ERROR)
							return
						end

						vim.iter(vim.api.nvim_list_bufs()):each(enable_features)
					end)
				end)
			end

			require("config.mappings").setup_treesitter()

			vim.treesitter.query.add_predicate("is-mise?", function(_, _, bufnr, _)
				local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
				local filename = vim.fn.fnamemodify(filepath, ":t")
				return string.match(filename, "^%.?mise%.toml$") ~= nil
			end, { force = true })
		end,
	},
}
