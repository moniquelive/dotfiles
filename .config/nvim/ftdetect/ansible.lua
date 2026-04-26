local function match_any(str, patterns)
	return vim.iter(patterns):any(function(pattern) return str:match(pattern) ~= nil end)
end

local function is_ansible()
	local fullpath, filename = vim.fn.expand("%:p"), vim.fn.expand("%:t")
	if fullpath == "" then return false end

	local path = vim.fn.fnamemodify(fullpath, ":h")
	local ext = vim.fn.expand("%:e")
	local has_cfg = #vim.fs.find({ "ansible.cfg" }, { path = path, upward = true, stop = vim.env.HOME }) > 0

	local yaml = { yml = true, yaml = true }
	local root = yaml[ext] and has_cfg

	local file_patterns = {
		"/tasks/[^/]*%.ya?ml$",
		"/roles/[^/]*%.ya?ml$",
		"/handlers/[^/]*%.ya?ml$",
		"/defaults/[^/]*%.ya?ml$",
		"/vars/[^/]*%.ya?ml$",
		"/group_vars/",
		"/host_vars/",
	}

	local filename_patterns = vim.g.ansible_ftdetect_filename_regex and { vim.g.ansible_ftdetect_filename_regex }
		or { "^playbook%.ya?ml$", "^site%.ya?ml$", "^main%.ya?ml$", "^local%.ya?ml$", "^requirements%.ya?ml$" }

	local shebang_patterns = {
		"^#!.*bin/env%s+ansible%-playbook",
		"^#!.*bin/ansible%-playbook",
	}

	return root
		or match_any(fullpath, file_patterns)
		or match_any(filename, filename_patterns)
		or match_any(vim.fn.getline(1), shebang_patterns)
end

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*",
	callback = function()
		if is_ansible() then vim.bo.filetype = "yaml.ansible" end
	end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
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
	pattern = "hosts",
	callback = function() vim.bo.filetype = "ansible_hosts" end,
})
