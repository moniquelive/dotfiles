local M = {}
local mini_hipatterns = require("config.mini_hipatterns")

function M.setup(mini)
	vim.iter({
		function() require("mini.icons").setup() end,
		function() require("mini.animate").setup() end,
		function() require("mini.ai").setup() end,
		function()
			require("mini.align").setup({
				mappings = {
					start = "gl",
					start_with_preview = "gL",
				},
			})
		end,
		function() require("mini.bracketed").setup() end,
		function()
			require("mini.move").setup({
				mappings = {
					left = "<C-M-h>",
					right = "<C-M-l>",
					down = "<C-M-j>",
					up = "<C-M-k>",
					line_left = "<C-M-h>",
					line_right = "<C-M-l>",
					line_down = "<C-M-j>",
					line_up = "<C-M-k>",
				},
			})
		end,
		function() require("mini.splitjoin").setup() end,
		function() require("mini.surround").setup() end,
		function() require("mini.diff").setup() end,
		function()
			mini.pick.setup()
			mini.pick.registry.undo = function() return require("config.mini_undotree").pick(mini.pick) end
			mini.pick.registry.rfc = function(...)
				require("lazy").load({ plugins = { "rfc.nvim" } })
				return require("rfc").picker(...)
			end
			mini.pick.registry.man = function(...)
				require("lazy").load({ plugins = { "man.nvim" } })
				return require("man_nvim").picker(...)
			end
		end,
		function() mini.extra.setup() end,
		function()
			mini.notify.setup({
				content = {
					format = function(notif) return notif.msg end,
				},
			})
		end,
		function()
			mini.indentscope.setup({
				symbol = "│",
				mappings = {
					object_scope = "",
					object_scope_with_border = "",
					goto_top = "",
					goto_bottom = "",
				},
			})
		end,
		function() mini_hipatterns.setup() end,
		function()
			local statusline = require("mini.statusline")
			statusline.setup()
			local default_active = statusline.active
			statusline.active = function()
				local content = default_active()
				return content == "" and content or content .. "%S"
			end
		end,
		function()
			local trailspace = require("mini.trailspace")
			local trim_filetypes = {
				bash = true,
				c = true,
				clojure = true,
				cpp = true,
				cs = true,
				css = true,
				dockerfile = true,
				elixir = true,
				elm = true,
				fish = true,
				go = true,
				haskell = true,
				heex = true,
				html = true,
				javascript = true,
				javascriptreact = true,
				json = true,
				jsonc = true,
				lua = true,
				python = true,
				ruby = true,
				rust = true,
				scss = true,
				sh = true,
				svelte = true,
				swift = true,
				toml = true,
				typescript = true,
				typescriptreact = true,
				vue = true,
				yaml = true,
				zig = true,
				zsh = true,
			}
			trailspace.setup()

			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("UserMiniTrailspace", { clear = true }),
				callback = function(event)
					local bo = vim.bo[event.buf]
					if not trim_filetypes[bo.filetype] or vim.b[event.buf].trim_trailing_whitespace == false then
						return
					end
					if bo.buftype ~= "" or bo.readonly or not bo.modifiable then return end
					trailspace.trim()
					trailspace.trim_last_lines()
				end,
			})
		end,
		function() mini.misc.setup_termbg_sync() end,
		function() require("mini.visits").setup() end,
		function()
			local files = require("mini.files")
			files.setup({
				mappings = {
					close = "<S-Tab>",
				},
				options = {
					permanent_delete = false,
					use_as_default_explorer = false,
				},
			})

			local function map_open(buf_id, lhs, split_command, desc)
				vim.keymap.set("n", lhs, function()
					local entry = files.get_fs_entry()
					if entry == nil then return end
					if entry.fs_type == "directory" then
						files.go_in()
						return
					end

					local state = files.get_explorer_state()
					if state == nil then return end
					local target_window = vim.api.nvim_win_call(state.target_window, function()
						vim.cmd(split_command .. " split")
						return vim.api.nvim_get_current_win()
					end)
					files.set_target_window(target_window)
					files.go_in({ close_on_file = true })
				end, { buffer = buf_id, desc = desc })
			end

			vim.api.nvim_create_autocmd("User", {
				group = vim.api.nvim_create_augroup("UserMiniFilesMappings", { clear = true }),
				pattern = "MiniFilesBufferCreate",
				callback = function(event)
					local buf_id = event.data.buf_id
					vim.keymap.set("n", "<CR>", function() files.go_in({ close_on_file = true }) end, {
						buffer = buf_id,
						desc = "Open entry",
					})
					vim.keymap.set("n", "<Esc>", files.close, { buffer = buf_id, desc = "Close" })
					map_open(buf_id, "<C-x>", "belowright", "Open in horizontal split")
					map_open(buf_id, "<C-v>", "belowright vertical", "Open in vertical split")
					map_open(buf_id, "<C-t>", "tab", "Open in tab")
				end,
			})
		end,
	}):each(function(setup) setup() end)
end

return M
