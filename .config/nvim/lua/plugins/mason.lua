-- vim:set ts=2:

-- vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
vim.diagnostic.config({
	float = { border = "single" },
	underline = false,
	virtual_text = true,
	virtual_lines = false,
})

local function keymaps(bufnr)
	local nmaps = {
		["gD"] = vim.lsp.buf.declaration,
		["gd"] = vim.lsp.buf.definition,
		["K"] = vim.lsp.buf.hover,
		["[d"] = vim.diagnostic.goto_prev,
		["]d"] = vim.diagnostic.goto_next,
		["<F2>"] = vim.lsp.buf.rename,
		["<F3>"] = vim.lsp.buf.code_action,
		["<F4>"] = vim.lsp.codelens.run,
		["gi"] = "<cmd>Telescope lsp_implementations<CR>",
		["gr"] = "<cmd>Telescope lsp_references<CR>",
		["<leader>d"] = "<cmd>Telescope lsp_definitions<CR>",
		["<leader>e"] = function() vim.diagnostic.open_float({ source = "if_many" }) end,
		["<leader>f"] = function() vim.lsp.buf.format({ async = true }) end,
		["<leader>ih"] = function()
			local curr = vim.lsp.inlay_hint.is_enabled()
			vim.lsp.inlay_hint.enable(not curr)
			vim.notify((curr and "disabled" or "enabled") .. " inlay hints")
		end,
	}
	local opts = { noremap = true, silent = true, buffer = bufnr }
	for key, action in pairs(nmaps) do
		vim.keymap.set("n", key, action, opts)
	end
	vim.keymap.set("i", "<F1>", vim.lsp.buf.signature_help, opts)
end

local au = vim.api.nvim_create_autocmd
-- local function highlighting(client, bufnr)
-- 	if client.server_capabilities.documentHighlightProvider then
-- 		vim.cmd([[
--               hi! LspReferenceText cterm=bold ctermbg=red guibg=#403040
--               hi! LspReferenceRead cterm=bold ctermbg=red guibg=#106010
--               hi! LspReferenceWrite cterm=bold ctermbg=red guibg=#601010
--             ]])
-- 		local grp = vim.api.nvim_create_augroup("lsp_document_highlight", {})
-- 		au({ "CursorHold", "CursorHoldI" }, { group = grp, buffer = bufnr, callback = vim.lsp.buf.document_highlight })
-- 		au({ "CursorMoved", "CursorMovedI" }, { group = grp, buffer = bufnr, callback = vim.lsp.buf.clear_references })
-- 	end
-- end

au("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
		vim.api.nvim_set_option_value("formatexpr", "v:lua.vim.lsp.formatexpr()", { buf = bufnr })

		keymaps(bufnr)
		-- highlighting(client, bufnr)
		if client then
			vim.notify("📡️" .. client.name .. " attached")
		end
	end,
})

local servers = {
	lua_ls = {},
	clangd = {
		cmd = {
			"/opt/homebrew/opt/llvm/bin/clangd",
			"--offset-encoding=utf-16",
			"--background-index",
			"--clang-tidy",
		},
	},
	gopls = {
		init_options = {
			usePlaceholders = true,
		},
		settings = {
			gopls = {
				completeUnimported = true,
				-- usePlaceholders = true,
				semanticTokens = true,
				experimentalPostfixCompletions = true,
				staticcheck = true,
				analyses = {
					useany = true,
					unusedparams = true,
					shadow = true,
					nilness = true,
					unusedvariable = true,
				},
				-- hints = {
				-- 	rangeVariableTypes = true,
				-- 	parameterNames = true,
				-- 	functionTypeParameters = true,
				-- 	constantValues = true,
				-- 	compositeLiteralTypes = true,
				-- 	compositeLiteralFields = true,
				-- 	assignVariableTypes = true,
				-- },
			},
		},
	},
	jsonls = {
		capabilities = { textDocument = { completion = { completionItem = { snippetSupport = true } } } },
		settings = {
			json = {
				-- schemas = require("schemastore").json.schemas(),
				validate = { enable = true },
			},
		},
	},
	yamlls = {
		capabilities = { textDocument = { completion = { completionItem = { snippetSupport = true } } } },
		settings = {
			yaml = {
				schemaStore = { url = "", enable = false },
				-- schemas = require("schemastore").yaml.schemas(),
			},
		},
	},
	omnisharp = {
		cmd = {
			"/usr/local/share/dotnet/dotnet",
			vim.fn.expand("~/.local/share/nvim/mason/packages/omnisharp/OmniSharp.dll"),
		},
	},
	powershell_es = {
		bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services/",
	},
	ruby_lsp = {
		init_options = {
			rubyVersionManager = "mise",
			formatter = "rubocop",
			linters = { "rubocop" },
			enabledFeatures = {
				codeActions = true,
				codeLens = true,
				completion = true,
				definition = true,
				diagnostics = true,
				documentHighlights = true,
				documentSymbols = true,
				foldingRanges = true,
				formatting = true,
				hover = true,
				-- inlayHint = true,
				onTypeFormatting = true,
				selectionRanges = true,
				semanticHighlighting = true,
				signatureHelp = true,
			},
			featuresConfiguration = {
				inlayHint = {
					implicitHashValue = true,
					implicitRescue = true,
				},
			},
		},
	},
	elixirls = {
		-- cmd = { vim.fn.expand("~/.elixir-ls/language_server.sh") },
		-- cmd = { vim.fn.expand("/opt/homebrew/bin/elixir-ls") },
		-- cmd = { vim.fn.expand("~/.local/share/nvim/mason/packages/elixir-ls/language_server.sh") },
		settings = {
			elixirLS = {
				autoBuild = true,
				dialyzerEnabled = true,
				incrementalDialyzer = true,
				fetchDeps = true,
			},
		},
	},
	emmet_ls = {
		filetypes = { "html", "css", "heex", "eelixir" },
	},
	tailwindcss = {
		init_options = {
			userLanguages = {
				elixir = "html-eex",
				eelixir = "html-eex",
				heex = "html-eex",
			},
		},
		root_dir = require("lspconfig.util").root_pattern(
			"tailwind.config.js",
			"tailwind.config.cjs",
			"tailwind.config.mjs",
			"tailwind.config.ts",
			"postcss.config.js",
			"postcss.config.cjs",
			"postcss.config.mjs",
			"postcss.config.ts",
			"package.json",
			"node_modules",
			"mix.exs",
			".git"
		),
		settings = {
			experimental = {
				classRegex = {
					[[class= "([^"]*)]],
					[[class: "([^"]*)]],
					'~H""".*class="([^"]*)".*"""',
					'~F""".*class="([^"]*)".*"""',
				},
			},
		},
	},
}

local function config()
	require("mason").setup()
	local ensure_installed = vim.tbl_keys(servers or {})
	vim.list_extend(ensure_installed, {
		"autopep8",
		"bash-language-server",
		"css-lsp",
		"djlint",
		"dockerfile-language-server",
		"elixir-ls",
		"elm-format",
		"elm-language-server",
		"flake8",
		"gitlint",
		"goimports-reviser",
		"golangci-lint-langserver",
		"gopls",
		"html-lsp",
		"iferr",
		"isort",
		"luacheck",
		"markdownlint",
		"prettierd",
		"pylint",
		"python-lsp-server",
		"revive",
		"rubocop",
		"ruby-lsp",
		"staticcheck",
		"stylua",
		"typescript-language-server",
		"vim-language-server",
		"yapf",
		"zls",
	})
	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
	require("mason-lspconfig").setup({
		handlers = {
			function(server_name)
				local server = servers[server_name] or {}
				server.capabilities = require('blink.cmp').get_lsp_capabilities(server.capabilities or {}, true)
				require("lspconfig")[server_name].setup(server)
			end,
		},
	})
	-- Unmanaged LSPs
	local external_servers = {
		ghcide = {},
		hls = { cmd = { vim.fn.expand("~/.ghcup/bin/haskell-language-server-wrapper") } }
	}
	for server, cfg in pairs(external_servers) do
		require('lspconfig')[server].setup(cfg)
	end
end

return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"saghen/blink.cmp",
			"neovim/nvim-lspconfig",
			"williamboman/mason-lspconfig.nvim",
			{ "WhoIsSethDaniel/mason-tool-installer.nvim", build = ":MasonToolsUpdate" },
		},
		event = { "BufRead", "BufNewFile" },
		cmd = { "Mason", "MasonUpdate" },
		build = ":MasonUpdate",
		config = config,
	},
}
