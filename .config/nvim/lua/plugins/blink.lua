return {
	"saghen/blink.cmp",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"rafamadriz/friendly-snippets",
		{
			"supermaven-inc/supermaven-nvim",
			opts = {
				disable_inline_completion = true, -- disables inline completion for use with cmp
				disable_keymaps = true, -- disables built in keymaps for more manual control
			},
		},
		{ "huijiro/blink-cmp-supermaven" },
	},

	version = "1.*",
	event = { "CmdlineEnter" },

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = { preset = "super-tab" },
		cmdline = {
			completion = { list = { selection = { preselect = false } } },
			keymap = { preset = "enter" },
		},

		appearance = {
			highlight_ns = vim.api.nvim_create_namespace("blink_cmp"),
			use_nvim_cmp_as_default = false,
			nerd_font_variant = "mono",
			kind_icons = {
				Supermaven = "",
				Text = "󰉿",
				Method = "󰊕",
				Function = "󰊕",
				Constructor = "󰒓",

				Field = "󰜢",
				Variable = "󰆦",
				Property = "󰖷",

				Class = "󱡠",
				Interface = "󱡠",
				Struct = "󱡠",
				Module = "󰅩",

				Unit = "󰪚",
				Value = "󰦨",
				Enum = "󰦨",
				EnumMember = "󰦨",

				Keyword = "󰻾",
				Constant = "󰏿",

				Snippet = "󱄽",
				Color = "󰏘",
				File = "󰈔",
				Reference = "󰬲",
				Folder = "󰉋",
				Event = "󱐋",
				Operator = "󰪚",
				TypeParameter = "󰬛",
			},
		},

		completion = {
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
			trigger = { show_in_snippet = false },
			menu = {
				-- stylua: ignore
				auto_show = function(_ --[[ctx]]) return not vim.tbl_contains({ "/", "?" }, vim.fn.getcmdtype()) end,

				-- nvim-cmp style menu
				draw = {
					treesitter = { "lsp" },
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind" },
					},
					components = {
						-- no icons for cmdline
						kind_icon = {
							text = function(ctx) return ctx.item.source_id == "cmdline" and "" or ctx.kind_icon end,
						},
						kind = { text = function(ctx) return ctx.item.source_id == "cmdline" and "" or ctx.kind end },
					},
				},
			},
			ghost_text = { enabled = false },
			list = {
				selection = {
					preselect = function(ctx) return ctx.mode ~= "cmdline" end,
					auto_insert = function(ctx) return ctx.mode ~= "cmdline" end,
				},
			},
		},
		signature = { enabled = true },
		sources = {
			default = function()
				local success, node = pcall(vim.treesitter.get_node)
				if
					success
					and node
					and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type())
				then
					return { "buffer" }
				end
				return { "lazydev", "lsp", "path", "supermaven", "snippets" }
			end,
			providers = {
				lsp = { fallbacks = { "lazydev" } }, -- dont show LuaLS require statements when lazydev has items
				lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
				snippets = {
					opts = {
						extended_filetypes = {
							markdown = { "jekyll" },
							sh = { "shelldoc" },
							ruby = { "rails" },
						},
					},
				},
				supermaven = {
					name = "supermaven",
					module = "blink-cmp-supermaven",
					async = true,
				},
			},
		},
		fuzzy = { implementation = "prefer_rust" },
	},
	opts_extend = { "sources.default" },
}
