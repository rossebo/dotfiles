local M = {}

--- Path of the current file with the cursor line, e.g. `lua/foo.lua#L12`.
---@param absolute? boolean Use the absolute path instead of one relative to the cwd
---@return string?
function M.file_path(absolute)
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return nil
	end
	local path = vim.fn.fnamemodify(name, absolute and ":p" or ":.")
	return ("%s#L%d"):format(path, vim.api.nvim_win_get_cursor(0)[1])
end

--- Copy the current file path with the cursor line to the clipboard and show it.
---@param absolute? boolean
function M.copy_path(absolute)
	local text = M.file_path(absolute)
	if not text then
		return vim.notify("This buffer has no file", vim.log.levels.WARN)
	end
	vim.fn.setreg("+", text)
	vim.notify("Copied " .. text)
end

local SHORT_FILETYPES = {
	typescriptreact = "tsx",
	javascriptreact = "jsx",
	typescript = "ts",
	javascript = "js",
}

--- Copy the visual selection as a Markdown code block with filename and line attributes.
function M.copy_code_block()
	local name = vim.api.nvim_buf_get_name(0)
	local start_pos, end_pos = vim.fn.getpos("v"), vim.fn.getpos(".")
	local lines = vim.fn.getregion(start_pos, end_pos, { type = vim.fn.mode() })
	vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
	if #lines == 0 then
		return
	end

	local filetype = vim.bo.filetype
	local lang = SHORT_FILETYPES[filetype] or filetype
	local filename = name == "" and "" or vim.fn.fnamemodify(name, ":.")
	local text = ('```%s filename="%s" line=%d\n%s\n```'):format(
		lang,
		filename,
		math.min(start_pos[2], end_pos[2]),
		table.concat(lines, "\n")
	)
	vim.fn.setreg("+", text)
	vim.notify("Copied code block")
end

local PROJECT_FILES = { "package.json", "appsettings.json", "requirements.txt" }

--- Open the project's package.json, appsettings.json or requirements.txt in a centered float.
function M.open_project_file()
	local root = vim.fs.root(0, PROJECT_FILES) or vim.fs.root(vim.uv.cwd(), PROJECT_FILES)
	local path
	for _, file in ipairs(PROJECT_FILES) do
		if root and vim.uv.fs_stat(vim.fs.joinpath(root, file)) then
			path = vim.fs.joinpath(root, file)
			break
		end
	end
	if not path then
		return vim.notify("No package.json, appsettings.json or requirements.txt found", vim.log.levels.WARN)
	end

	local win = Snacks.win({
		file = path,
		width = 0.8,
		height = 0.8,
		border = "rounded",
		keys = { q = "close", ["<Esc>"] = "close" },
	})

	-- The file buffer outlives the float, so drop the close keys again (q would otherwise stop recording macros)
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(win.win),
		once = true,
		callback = function()
			for _, key in ipairs({ "q", "<Esc>" }) do
				pcall(vim.keymap.del, "n", key, { buffer = win.buf })
			end
		end,
	})
end

return M
