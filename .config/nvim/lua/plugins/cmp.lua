local function config()
	vim.o.completeopt = "menu,menuone,noselect"

	local cmp = require("cmp")
	cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())

	vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { bg = "NONE", fg = "#6CC644" })
	-- gray
	vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
	-- blue
	vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg = "NONE", fg = "#569CD6" })
	vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpIntemAbbrMatch" })
	-- light blue
	vim.api.nvim_set_hl(0, "CmpItemKindVariable", { bg = "NONE", fg = "#9CDCFE" })
	vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
	vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })
	-- pink
	vim.api.nvim_set_hl(0, "CmpItemKindFunction", { bg = "NONE", fg = "#C586C0" })
	vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })
	-- front
	vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { bg = "NONE", fg = "#D4D4D4" })
	vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
	vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })

	local cmp_kinds = {
		Text = "  ",
		Method = "  ",
		Function = "  ",
		Constructor = "  ",
		Field = "  ",
		Variable = "  ",
		Class = "  ",
		Interface = "  ",
		Module = "  ",
		Property = "  ",
		Unit = "  ",
		Value = "  ",
		Enum = "  ",
		Keyword = "  ",
		Snippet = "  ",
		Color = "  ",
		File = "  ",
		Reference = "  ",
		Folder = "  ",
		EnumMember = "  ",
		Constant = "  ",
		Struct = "  ",
		Event = "  ",
		Operator = "  ",
		TypeParameter = "  ",
		Supermaven = "  ",
	}

	cmp.setup({
		mapping = cmp.mapping.preset.insert({
			["<C-k>"] = cmp.mapping.scroll_docs(-4),
			["<C-j>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete({}),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
			["<C-n>"] = cmp.mapping.select_next_item(),
			["<C-p>"] = cmp.mapping.select_prev_item(),
		}),
		sources = cmp.config.sources({
			{ name = "supermaven", priority = 100 },
			{ name = "lazydev" },
			{ name = "nvim_lua" },
			{
				name = "nvim_lsp",
				entry_filter = function(entry)
					return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
				end,
			},
			{ name = "nvim_lsp_signature_help" },
			{ name = "path" },
			{ name = "buffer", keyword_length = 5 },
		}),
		formatting = {
			expandable_indicator = true,
			fields = { "abbr", "kind" },
			format = function(_, vim_item)
				vim_item.kind = (cmp_kinds[vim_item.kind] or "") .. vim_item.kind
				-- vim_item.menu = ({
				-- 	buffer = "[Buffer]",
				-- 	nvim_lsp = "[LSP]",
				-- 	luasnip = "[LuaSnip]",
				-- 	nvim_lua = "[Lua]",
				-- 	latex_symbols = "[LaTeX]",
				-- 	path = "[Path]",
				-- 	snippet = "[Snip]",
				-- })[entry.source.name]
				return vim_item
			end,
		},
		experimental = {
			ghost_text = true,
		},
	})

	-- `:` cmdline setup.
	cmp.setup.cmdline(":", {
		view = { entries = "custom" },
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({ { name = "cmdline" } }, { { name = "path" } }),
	})
end

return {
	{
		"hrsh7th/nvim-cmp",
		config = config,
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"windwp/nvim-autopairs",
			"rafamadriz/friendly-snippets",
		},
	},
}
