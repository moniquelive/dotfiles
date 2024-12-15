vim.opt_local.makeprg = "lua %"

if vim.fn.executable("love") == 1 then
	vim.keymap.set("n", "<f5>", "<cmd>!love .<cr>", { silent = true })
end
