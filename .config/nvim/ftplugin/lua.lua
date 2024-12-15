vim.opt_local.makeprg = "lua %"

if vim.fn.executable("love") == 1 and vim.fn.search("function love", "n") > 0 then
	vim.keymap.set("n", "<f5>", "<cmd>!love .<cr>", { silent = true, buffer = true })
end
