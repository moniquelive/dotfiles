local M = {}

-- TODO: h: plenary-test
local function match_any(str, patterns)
	return vim.tbl_contains(vim.tbl_map(function(p) return str:match(p) ~= nil end, patterns), true)
end

local function is_ansible()
	local path, fullpath, filename = vim.fn.expand("%:h"), vim.fn.expand("%:p"), vim.fn.expand("%:t")
	local ext = vim.fn.expand("%:e")
	local has_cfg = vim.fn.filereadable(vim.fs.joinpath(path, "ansible.cfg")) == 1

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

	-- vim.print(
	-- 	filename_patterns ,
	-- 	filename,
	-- 	root,
	-- 	match_any(fullpath, file_patterns),
	-- 	match_any(filename, filename_patterns),
	-- 	match_any(vim.fn.getline(1), shebang_patterns)
	-- )

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
		for pattern, syntax in pairs(syntaxes) do
			if fullpath:match(vim.fn.glob2regpat(pattern)) then
				vim.bo.filetype = syntax .. ".jinja2"
				return
			end
		end
		vim.bo.filetype = "jinja2"
	end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "hosts",
	callback = function() vim.bo.filetype = "ansible_hosts" end,
})

return M
