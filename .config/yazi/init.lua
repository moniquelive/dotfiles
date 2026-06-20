require("full-border"):setup({
	type = ui.Border.ROUNDED,
})

require("git"):setup({
	order = 1500,
})

require("eza-preview"):setup({
	default_tree = true,
	level = 3,
	icons = true,
	follow_symlinks = true,
	git_ignore = true,
	git_status = true,
})

require("duckdb"):setup({
	mode = "summarized",
	row_id = "dynamic",
})

function Linemode:size_and_mtime()
	local mtime = math.floor(self._file.cha.mtime or 0)
	local time = mtime == 0 and "-" or os.date("%Y-%m-%d %H:%M", mtime)
	local size = self._file:size()

	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end
