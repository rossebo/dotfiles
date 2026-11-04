local M = {}

local ROOT_MARKERS = { ".git", "lua", "package.json", "Makefile", "Cargo.toml", "go.mod", "pyproject.toml" }

local function root()
	local name = vim.api.nvim_buf_get_name(0)
	local start = name ~= "" and name or vim.uv.cwd()
	return vim.fs.root(start, ROOT_MARKERS)
end

--- Project root name, only when it differs from the cwd.
function M.root_name()
	local dir = root()
	if not dir or dir == vim.uv.cwd() then
		return ""
	end
	return vim.fs.basename(dir)
end

--- File path relative to the project root, with long directory chains shortened.
function M.pretty_path()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return "[No Name]"
	end

	local dir = root() or vim.uv.cwd()
	local path = vim.fs.relpath(dir, name) or vim.fn.fnamemodify(name, ":~")

	local parts = vim.split(path, "/", { plain = true })
	if #parts > 3 then
		parts = { "…", parts[#parts - 2], parts[#parts - 1], parts[#parts] }
	end
	return table.concat(parts, "/")
end

--- Register being recorded, empty when not recording.
function M.recording()
	local reg = vim.fn.reg_recording()
	return reg ~= "" and ("recording @" .. reg) or ""
end

function M.location()
	local pos = vim.api.nvim_win_get_cursor(0)
	return pos[1] .. ":" .. (pos[2] + 1)
end

return M
