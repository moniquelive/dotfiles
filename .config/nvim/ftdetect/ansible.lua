local M = {}

local function match_any(str, patterns)
	return vim.tbl_contains(
		vim.tbl_map(function(p)
			return str:match(p)
		end, patterns),
		true
	)
end

local function is_ansible()
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

	local path, filepath, filename = vim.fn.expand("%:h"), vim.fn.expand("%:p"), vim.fn.expand("%:t")
	local ext = vim.fn.expand("%:e")
	local has_cfg = vim.fn.filereadable(vim.fs.joinpath(path, "ansible.cfg")) == 1

	local yaml = { yml = true, yaml = true }
	local root = yaml[ext] and has_cfg
	-- vim.print(
	-- 	root,
	-- 	match_any(filepath, file_patterns),
	-- 	match_any(filename, filename_patterns),
	-- 	match_any(vim.fn.getline(1), shebang_patterns)
	-- )

	return root
		or match_any(filepath, file_patterns)
		or match_any(filename, filename_patterns)
		or match_any(vim.fn.getline(1), shebang_patterns)
end

local function setup_template()
	local syntaxes = vim.g.ansible_template_syntaxes or {}
	local filepath = vim.fn.expand("%:p")

	for pattern, syntax in pairs(syntaxes) do
		if filepath:match(vim.fn.glob2regpat(pattern)) then
			vim.bo.filetype = syntax .. ".jinja2"
			return
		end
	end

	vim.bo.filetype = "jinja2"
end

local function create_autocmd(events, pattern, callback)
	vim.api.nvim_create_autocmd(events, { pattern = pattern, callback = callback })
end

create_autocmd({ "BufNewFile", "BufRead" }, "*", function()
	if is_ansible() then
		vim.bo.filetype = "yaml.ansible"
	end
end)

create_autocmd({ "BufNewFile", "BufRead" }, "*.j2", setup_template)

create_autocmd({ "BufNewFile", "BufRead" }, "hosts", function()
	vim.bo.filetype = "ansible_hosts"
end)

return M
