return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim" },
		-- stylua: ignore
		ft = {
			"bash", "c", "cabal", "clojure", "cpp", "cs", "css",
			"dockerfile", "elixir", "elm", "fish",
			"go", "gomod", "gowork", "haskell", "heex", "html",
			"javascript", "javascriptreact", "json", "jsonc",
			"lhaskell", "lua", "ps1", "psd1", "psm1", "python",
			"ruby", "sass", "scss", "sh", "svelte", "swift",
			"toml", "typescript", "typescriptreact", "vue",
			"yaml", "zig", "zsh",
		},
		config = function()
			local completion_kind = vim.lsp.protocol.CompletionItemKind

			local function set_completion_source_highlights()
				vim.api.nvim_set_hl(0, "PmenuKindSourceLsp", { link = "Type" })
				vim.api.nvim_set_hl(0, "PmenuKindSourceSnippet", { link = "Special" })
				vim.api.nvim_set_hl(0, "PmenuKindSourcePath", { link = "Directory" })
			end

			local function completion_source_style(item)
				if
					item.kind == completion_kind.Snippet
					or item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet
				then
					return "[SNIP]", "PmenuKindSourceSnippet"
				end

				if item.kind == completion_kind.File or item.kind == completion_kind.Folder then
					return "[PATH]", "PmenuKindSourcePath"
				end

				return "[LSP]", "PmenuKindSourceLsp"
			end

			local function completion_detail_text(item)
				local detail = vim.tbl_get(item, "labelDetails", "description")
				if detail == nil or detail == vim.NIL or detail == "" then detail = item.detail end

				if detail == nil or detail == vim.NIL then return "" end
				if type(detail) ~= "string" then return "" end

				return detail
			end

			local function convert_completion_item(item)
				local source_label, source_hl = completion_source_style(item)
				local detail = completion_detail_text(item)
				if detail ~= "" then detail = " " .. detail end

				local converted = { menu = source_label .. detail }
				if item.kind ~= completion_kind.Color then converted.kind_hlgroup = source_hl end

				return converted
			end

			local function notify_lsp_attach(client, bufnr)
				local filename = vim.api.nvim_buf_get_name(bufnr)
				filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")

				local capabilities = vim.iter({
					{ "textDocument/completion", "completion" },
					{ "textDocument/hover", "hover" },
					{ "textDocument/codeAction", "actions" },
					{ "textDocument/formatting", "formatting" },
				}):fold(setmetatable({}, { __index = table }), function(acc, feature)
					if client:supports_method(feature[1], bufnr) then acc:insert("- " .. feature[2]) end
					return acc
				end)

				local suffix = #capabilities > 0 and ("\n\n" .. capabilities:concat("\n")) or ""
				vim.notify(
					string.format("📡 %s attached to %s%s", client.name, filename, suffix),
					vim.log.levels.INFO
				)
			end

			set_completion_source_highlights()
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("UserCompletionSourceColors", { clear = true }),
				callback = set_completion_source_highlights,
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(args)
					local bufnr = args.buf
					vim.lsp.codelens.enable(false, { bufnr = bufnr })
					require("config.mappings").setup_lsp(bufnr)

					local client_id = args.data.client_id
					if not client_id then return end
					local client = vim.lsp.get_client_by_id(client_id)
					if not client then return end

					if client:supports_method("textDocument/completion") then
						vim.lsp.completion.enable(true, client.id, bufnr, {
							autotrigger = true,
							convert = convert_completion_item,
						})
					end

					notify_lsp_attach(client, bufnr)
				end,
			})

			-- global config
			vim.lsp.config("*", { root_markers = { ".git" } })

			local clojure_lsp_init_options = {
				cljfmt = { ["remove-multiple-non-indenting-spaces?"] = true },
			}
			if vim.fn.executable("clojure") == 0 then
				clojure_lsp_init_options["project-specs"] = {}
				for _, spec in ipairs({
					{ "project.clj", { "lein", "classpath" } },
					{ "bb.edn", { "bb", "print-deps", "--format", "classpath" } },
				}) do
					if vim.fn.executable(spec[2][1]) == 1 then
						table.insert(clojure_lsp_init_options["project-specs"], {
							["project-path"] = spec[1],
							["classpath-cmd"] = spec[2],
						})
					end
				end
			end

			-- specific ones
			local servers = {
				clangd = {},
				clojure_lsp = {
					init_options = clojure_lsp_init_options,
					root_markers = { "bb.edn", "deps.edn", "project.clj", "build.boot", ".git" },
				},
				dockerls = {},
				elmls = {},
				expert = {},
				fish_lsp = {},
				golangci_lint_ls = {},
				gopls = {},
				hls = {
					cmd = { "haskell-language-server-wrapper", "--lsp" },
					root_markers = { "hie.yaml", "stack.yaml", "cabal.project", "*.cabal", "package.yaml" },
					on_attach = function(client) client.server_capabilities.semanticTokensProvider = nil end,
				},
				jsonls = {},
				bashls = {},

				-- LUA
				lua_ls = {},
				-- luacheck = {},
				-- stylua = {}, -- called by conform.nvim

				-- Microsoft
				omnisharp = {},
				powershell_es = {
					bundle_path = vim.fs.joinpath(
						vim.fn.stdpath("data"),
						"mason",
						"packages",
						"powershell-editor-services"
					),
					filetypes = { "ps1", "psd1", "psm1" },
				},

				-- PYTHON
				-- autopep8 = {},
				-- flake8 = {},
				-- isort = {}, -- called by conform.nvim
				pylsp = {},
				-- yapf = {},

				-- RUBY
				ruby_lsp = {},

				sourcekit = { filetypes = { "swift" } },
				tailwindcss = {},
				tombi = {},
				yamlls = {
					filetypes = { "yaml", "yaml.ansible", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
				},
				zls = { cmd = { "mise", "exec", "--", "zls" } },
			}
			vim.iter(servers):each(function(server, config)
				vim.lsp.config(server, config)
				vim.lsp.enable(server)
			end)
		end,
	},
}
