-- vim:set ts=2:

-- vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
vim.diagnostic.config({
	float = { border = "single" },
	underline = false,
	virtual_text = true,
	virtual_lines = false,
})
local au = vim.api.nvim_create_autocmd

local function keymaps(bufnr)
	local nmaps = {
		["gD"] = vim.lsp.buf.declaration,
		["gd"] = vim.lsp.buf.definition,
		["K"] = vim.lsp.buf.hover,
		["[d"] = vim.diagnostic.goto_prev,
		["]d"] = vim.diagnostic.goto_next,
		["gi"] = "<cmd>Telescope lsp_implementations<CR>",
		["<F3>"] = vim.lsp.buf.code_action,
		["gr"] = "<cmd>Telescope lsp_references<CR>",
		["<leader>ca"] = vim.lsp.codelens.run,
		["<leader>d"] = "<cmd>Telescope lsp_definitions<CR>",
		["<leader>e"] = function()
			vim.diagnostic.open_float({ source = "if_many" })
		end,
		["<leader>f"] = function()
			vim.lsp.buf.format({ async = true })
		end,
		["<leader>ih"] = function()
			local ena_dis = { [true] = "enabled", [false] = "disabled" }
			local orig = vim.lsp.inlay_hint.is_enabled()
			local label = ena_dis[not orig]
			vim.lsp.inlay_hint.enable(not orig)
			vim.notify(label .. " inlay hints")
		end,
	}
	local opts = { noremap = true, silent = true, buffer = bufnr }
	for key, action in pairs(nmaps) do
		vim.keymap.set("n", key, action, opts)
	end
	vim.keymap.set("i", "<F1>", vim.lsp.buf.signature_help, opts)
end

local function highlighting(client, bufnr)
	if client.server_capabilities.documentHighlightProvider then
		vim.cmd([[
              hi! LspReferenceText cterm=bold ctermbg=red guibg=#403040
              hi! LspReferenceRead cterm=bold ctermbg=red guibg=#106010
              hi! LspReferenceWrite cterm=bold ctermbg=red guibg=#601010
            ]])
		local grp = vim.api.nvim_create_augroup("lsp_document_highlight", {})
		au({ "CursorHold", "CursorHoldI" }, { group = grp, buffer = bufnr, callback = vim.lsp.buf.document_highlight })
		au({ "CursorMoved", "CursorMovedI" }, { group = grp, buffer = bufnr, callback = vim.lsp.buf.clear_references })
	end
end

au("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
		vim.api.nvim_set_option_value("formatexpr", "v:lua.vim.lsp.formatexpr()", { buf = bufnr })

		keymaps(bufnr)
		highlighting(client, bufnr)
		if client then
			vim.notify("📡️" .. client.name .. " attached")
		end
	end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
local servers = {
	lua_ls = {
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},
				format = {
					enable = true,
					-- Put format options here
					-- NOTE: the value should be STRING!!
					defaultConfig = {
						indent_style = "space",
						indent_size = "2",
					},
				},
				diagnostics = {
					globals = { "vim" }, -- Get the language server to recognize the `vim` global
					-- neededFileStatus = {
					-- 	["codestyle-check"] = "Any",
					-- },
				},
				workspace = {
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME,
						"${3rd}/luv/library",
						"${3rd}/busted/library",
						"${3rd}/love2d/library",
						-- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
						-- library = vim.api.nvim_get_runtime_file("", true)
					},
				},
			},
		},
	},
	clangd = {
		cmd = {
			"/opt/homebrew/opt/llvm/bin/clangd",
			"--offset-encoding=utf-16",
			"--background-index",
			"--clang-tidy",
		},
	},
	gopls = {
		settings = {
			gopls = {
				completeUnimported = true,
				usePlaceholders = true,
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
				hints = {
					rangeVariableTypes = true,
					parameterNames = true,
					functionTypeParameters = true,
					constantValues = true,
					compositeLiteralTypes = true,
					compositeLiteralFields = true,
					assignVariableTypes = true,
				},
			},
		},
	},
	jsonls = {
		capabilities = vim.tbl_extend(
			"force",
			capabilities,
			{ textDocument = { completion = { completionItem = { snippetSupport = true } } } }
		),
		settings = {
			json = {
				-- schemas = require("schemastore").json.schemas(),
				validate = { enable = true },
			},
		},
	},
	yamlls = {
		capabilities = vim.tbl_extend(
			"force",
			capabilities,
			{ textDocument = { completion = { completionItem = { snippetSupport = true } } } }
		),
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
			"/Users/cyber/.local/share/nvim/mason/packages/omnisharp/OmniSharp.dll",
		},
	},
	powershell_es = {
		bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services/",
	},
	elixirls = {
		-- cmd = { vim.fn.expand("~/.elixir-ls/language_server.sh") },
		-- cmd = { vim.fn.expand("/opt/homebrew/bin/elixir-ls") },
		cmd = { vim.fn.expand("~/.local/share/nvim/mason/packages/elixir-ls/language_server.sh") },
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
		"diagnostic-languageserver",
		"djlint",
		"dockerfile-language-server",
		"elixir-ls",
		"elm-format",
		"elm-language-server",
		"flake8",
		"gitlint",
		"gofumpt",
		"goimports-reviser",
		"golangci-lint-langserver",
		"golines",
		"gotests",
		"gotestsum",
		"html-lsp",
		"iferr",
		"isort",
		"luacheck",
		"markdownlint",
		"prettierd",
		"pylint",
		"python-lsp-server",
		"revive",
		"ruby-lsp",
		"rubyfmt",
		"standardrb",
		"staticcheck",
		"stylua",
		"typescript-language-server",
		"vim-language-server",
		"yapf",
	})
	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
	require("mason-lspconfig").setup({
		handlers = {
			function(server_name)
				local server = servers[server_name] or {}
				server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
				require("lspconfig")[server_name].setup(server)
			end,
		},
	})
end

return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"neovim/nvim-lspconfig",
			"williamboman/mason-lspconfig.nvim",
			{ "WhoIsSethDaniel/mason-tool-installer.nvim", build = ":MasonToolsUpdate" },
			{ "folke/neodev.nvim",                         config = true },
		},
		cmd = { "Mason", "MasonUpdate" },
		build = ":MasonUpdate",
		config = config,
	},
}
