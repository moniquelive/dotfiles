local function opts()
	vim.o.completeopt = "menu,menuone,noselect"

	local lspkind = require("lspkind")
	local types = require("cmp.types")
	local cmp = require("cmp")
	local luasnip = require("luasnip")

	-- `/` cmdline setup.
	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{
				name = "buffer",
				option = {
					keyword_pattern = [=[[^(\v)?[:blank:]].*]=],
				},
			},
		},
	})
	-- `:` cmdline setup.
	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
	})

	return {
		window = {
			-- completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		mapping = cmp.mapping.preset.insert({
			["<C-k>"] = cmp.mapping.scroll_docs(-4),
			["<C-j>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete({}),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
			["<TAB>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { "i", "s", "c" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s", "c" }),
		}),
		sources = cmp.config.sources({
			--{ name = "cmp_tabnine" },
			{ name = "nvim_lua" },
			{
				name = "nvim_lsp",
				entry_filter = function(entry)
					return types.lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
				end,
			},
			{ name = "path" },
			{ name = "luasnip" }, -- For luasnip users.
			{ name = "buffer", keyword_length = 5 },
		}),
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body) -- For `luasnip` users.
			end,
		},
		formatting = {
			format = lspkind.cmp_format({
				menu = {
					-- tabnine = "[tn]",
					buffer = "[buf]",
					nvim_lsp = "[LSP]",
					nvim_lua = "[api]",
					path = "[path]",
					luasnip = "[snip]",
				},
			}),
		},
		experimental = {
			ghost_text = true,
		},
	}
end

return {
	{
		"hrsh7th/nvim-cmp",
		opts = opts,
		event = "InsertEnter",
		dependencies = {
			"onsails/lspkind.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
			{
				"L3MON4D3/LuaSnip",
				keys = "<tab>",
				dependencies = { "rafamadriz/friendly-snippets" },
			},
		},
	},
}
