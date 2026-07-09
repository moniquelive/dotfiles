local function match_any(str, patterns)
	return vim.iter(patterns):any(function(pattern) return str:match(pattern) ~= nil end)
end

local function is_ansible()
	local fullpath, filename = vim.fn.expand("%:p"), vim.fn.expand("%:t")
	if fullpath == "" then return false end

	local path = vim.fn.fnamemodify(fullpath, ":h")
	local ext = vim.fn.expand("%:e")

	local shebang_patterns = {
		"^#!.*bin/env%s+ansible%-playbook",
		"^#!.*bin/ansible%-playbook",
	}
	if match_any(vim.fn.getline(1), shebang_patterns) then return true end
	if ext ~= "yml" and ext ~= "yaml" then return false end

	if #vim.fs.find("ansible.cfg", { path = path, upward = true, stop = vim.env.HOME }) > 0 then return true end
	if vim.g.ansible_ftdetect_filename_regex and filename:match(vim.g.ansible_ftdetect_filename_regex) ~= nil then
		return true
	end

	return match_any(fullpath, {
		"/group_vars/[^/]*%.ya?ml$",
		"/host_vars/[^/]*%.ya?ml$",
		"/playbooks/[^/]*%.ya?ml$",
		"/roles/[^/]+/defaults/[^/]*%.ya?ml$",
		"/roles/[^/]+/handlers/[^/]*%.ya?ml$",
		"/roles/[^/]+/tasks/[^/]*%.ya?ml$",
		"/roles/[^/]+/vars/[^/]*%.ya?ml$",
	})
end

local ansible_group = vim.api.nvim_create_augroup("config_ansible_ftdetect", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	group = ansible_group,
	pattern = "*",
	callback = function()
		if is_ansible() then vim.bo.filetype = "yaml.ansible" end
	end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	group = ansible_group,
	pattern = "*.j2",
	callback = function()
		local syntaxes = vim.g.ansible_template_syntaxes or {}
		local fullpath = vim.fn.expand("%:p")
		local _, syntax = vim.iter(syntaxes):find(
			function(pattern) return vim.regex(vim.fn.glob2regpat(pattern)):match_str(fullpath) ~= nil end
		)

		vim.bo.filetype = syntax and (syntax .. ".jinja2") or "jinja2"
	end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	group = ansible_group,
	pattern = "hosts",
	callback = function() vim.bo.filetype = "ansible_hosts" end,
})
