-- vim:set ts=2:

-- vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
vim.diagnostic.config({
	float = { border = "single" },
	underline = false,
	virtual_text = false,
	virtual_lines = false,
})
local au = vim.api.nvim_create_autocmd

-- vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
local grp_diag_hold = vim.api.nvim_create_augroup("cursor_hold_diagnostic", {})
au({ "CursorHold", "CursorHoldI" }, {
	group = grp_diag_hold,
	callback = function()
		local diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
		if not next(diagnostics) then
			return
		end
		-- vim.print(diagnostics[1])
		local msg = vim.split(diagnostics[1].message, "\n")
		vim.api.nvim_echo({ { string.sub(msg[1], 1, vim.v.echospace) } }, false, {})
	end,
})
au({ "CursorMoved", "CursorMovedI" }, { group = grp_diag_hold, command = [[echo ""]] })

vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
	config = config or {}
	config.focus_id = ctx.method
	if not (result and result.contents) then
		return
	end
	local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
	markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
	if vim.tbl_isempty(markdown_lines) then
		return
	end
	return vim.lsp.util.open_floating_preview(markdown_lines, "markdown", config)
end

local function keymaps(bufnr)
	local keys = {
		["gD"] = vim.lsp.buf.declaration,
		["gd"] = vim.lsp.buf.definition,
		["K"] = vim.lsp.buf.hover,
		["[d"] = vim.diagnostic.goto_prev,
		["]d"] = vim.diagnostic.goto_next,
		["gi"] = "<cmd>Telescope lsp_implementations<CR>",
		["<F3>"] = vim.lsp.buf.code_action,
		["gr"] = "<cmd>Telescope lsp_references<CR>",
		["<leader>d"] = "<cmd>Telescope lsp_definitions<CR>",
		["<leader>e"] = function()
			vim.diagnostic.open_float({ source = "if_many" })
		end,
		["<leader>f"] = function()
			vim.lsp.buf.format({ async = true })
		end,
	}
	local opts = { noremap = true, silent = true, buffer = bufnr }
	for key, action in pairs(keys) do
		vim.keymap.set("n", key, action, opts)
	end
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
				diagnostics = {
					globals = { "vim" }, -- Get the language server to recognize the `vim` global
				},
				workspace = {
					library = {
						"${3rd}/love2d/library",
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
	hls = {
		settings = {
			haskell = { formattingProvider = "fourmolu" },
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
		-- cmd = { vim.fn.expand("~/.local/share/nvim/mason/packages/elixir-ls/language_server.sh") },
		settings = {
			elixirLS = { dialyzerEnabled = false, fetchDeps = false },
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
return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"neovim/nvim-lspconfig",
			"williamboman/mason-lspconfig.nvim",
			{ "WhoIsSethDaniel/mason-tool-installer.nvim", build = ":MasonToolsUpdate" },
			{ "folke/neodev.nvim", config = true },
		},
		cmd = { "Mason", "MasonUpdate" },
		build = ":MasonUpdate",
		config = function()
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
		end,
	},
}
