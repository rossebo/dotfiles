local M = {}

--- Open the current file as of the commit that last touched the cursor line, in a new tab.
function M.open_blame_commit()
	local file = vim.api.nvim_buf_get_name(0)
	local dir = vim.fs.dirname(file)
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local filetype = vim.bo.filetype

	local blame = vim.system(
		{ "git", "blame", "--porcelain", "-L", line .. "," .. line, "--", file },
		{ cwd = dir, text = true }
	):wait()
	if blame.code ~= 0 then
		return vim.notify("git blame failed: " .. vim.trim(blame.stderr), vim.log.levels.ERROR)
	end

	local lines = vim.split(blame.stdout, "\n", { plain = true })
	local sha, original_line = lines[1]:match("^(%x+) (%d+)")
	if not sha or sha:match("^0+$") then
		return vim.notify("This line is not committed yet", vim.log.levels.INFO)
	end
	local path
	for _, l in ipairs(lines) do
		path = l:match("^filename (.+)$") or path
	end

	local show = vim.system({ "git", "show", sha .. ":" .. path }, { cwd = dir, text = true }):wait()
	if show.code ~= 0 then
		return vim.notify("git show failed: " .. vim.trim(show.stderr), vim.log.levels.ERROR)
	end

	vim.cmd("tabnew")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(show.stdout:gsub("\n$", ""), "\n", { plain = true }))
	vim.api.nvim_buf_set_name(buf, ("%s@%s"):format(vim.fs.basename(path), sha:sub(1, 8)))
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = filetype
	vim.api.nvim_win_set_cursor(0, { tonumber(original_line), 0 })
	vim.cmd("normal! zz")
end

return M
