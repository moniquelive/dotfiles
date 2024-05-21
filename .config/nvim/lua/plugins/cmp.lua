local function config()
	vim.o.completeopt = "menu,menuone,noselect"

	local cmp = require("cmp")
	local cmp_autopairs = require("nvim-autopairs.completion.cmp")
	cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

	cmp.setup({
		view = { entries = "native" },
		window = {
			completion = cmp.config.window.bordered(),
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
				elseif vim.snippet.active({ direction = 1 }) then
					vim.snippet.jump(1)
				else
					fallback()
				end
			end, { "i", "s", "c" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif vim.snippet.active({ direction = -1 }) then
					vim.snippet.jump(-1)
				else
					fallback()
				end
			end, { "i", "s", "c" }),
		}),
		sources = cmp.config.sources({
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
			fields = { "kind", "abbr", "menu" },
			format = require("lspkind").cmp_format({
				menu = {
					buffer = "[buf]",
					nvim_lsp = "[LSP]",
					nvim_lua = "[api]",
					path = "[path]",
					snippet = "[snip]",
				},
			}),
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
			"onsails/lspkind.nvim",
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
