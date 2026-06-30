return {
	{
		"Olical/conjure",
		ft = { "clojure" },
		init = function()
			vim.g["conjure#filetypes"] = { "clojure" }

			-- vim.g["conjure#mapping#prefix"] = ","
			vim.g["conjure#mapping#doc_word"] = { "gK" }

			vim.g["conjure#client#clojure#nrepl#connection#auto_repl#enabled"] = true
			vim.g["conjure#client#clojure#nrepl#connection#auto_repl#cmd"] = "bb nrepl-server localhost:$port"
			vim.g["conjure#client#clojure#nrepl#connection#auto_repl#port_file"] = ".nrepl-port"
			vim.g["conjure#client#clojure#nrepl#eval#auto_require"] = false

			vim.g["conjure#log#hud#border"] = "rounded"
			vim.g["conjure#log#wrap"] = true
			vim.g["conjure#highlight#enabled"] = true
		end,
	},
}
