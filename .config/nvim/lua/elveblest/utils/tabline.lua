local M = {}

-- Both edges slant outward going down, so each tab is wider at the bottom.
local SEP_LEFT = "\u{e0ba}"
local SEP_RIGHT = "\u{e0b8}"
local MAX_NAME = 20

local function set_highlights()
	local c = require("solarized-osaka.colors").setup()
	local set = vim.api.nvim_set_hl
	set(0, "ElveblestTabSel", { fg = c.base4, bg = c.yellow, bold = true })
	set(0, "ElveblestTabSelSep", { fg = c.yellow, bg = "NONE" })
	set(0, "ElveblestTab", { fg = c.base0, bg = c.base02 })
	set(0, "ElveblestTabSep", { fg = c.base02, bg = "NONE" })
	set(0, "TabLineFill", { fg = "NONE", bg = "NONE" })
end

local function label(tab)
	local buf = vim.fn.tabpagebuflist(tab)[vim.fn.tabpagewinnr(tab)]
	local name = vim.fn.bufname(buf)
	local icon = ""

	if vim.bo[buf].buftype == "terminal" then
		name = "[Terminal]"
	elseif vim.bo[buf].filetype == "oil" then
		local dir = require("oil").get_current_dir(buf)
		name = dir and vim.fn.fnamemodify(dir, ":~"):gsub("(.)/$", "%1") or name
		if vim.fn.strchars(name) > MAX_NAME then
			name = "…" .. vim.fn.strcharpart(name, vim.fn.strchars(name) - (MAX_NAME - 3))
		end
	elseif name == "" then
		name = "[No Name]"
	else
		name = vim.fn.fnamemodify(name, ":t")
		icon = MiniIcons.get("file", name) .. " "
	end

	if vim.fn.strchars(name) > MAX_NAME then
		name = vim.fn.strcharpart(name, 0, MAX_NAME - 3) .. "…"
	end

	local modified = vim.bo[buf].modified and "[+] " or ""
	return "   " .. modified .. icon .. name .. "   "
end

function M.render()
	local current = vim.fn.tabpagenr()
	local parts = {}
	for tab = 1, vim.fn.tabpagenr("$") do
		local suffix = tab == current and "Sel" or ""
		local sep = "%#ElveblestTab" .. suffix .. "Sep#"
		table.insert(parts, sep .. SEP_LEFT)
		table.insert(parts, "%#ElveblestTab" .. suffix .. "#" .. label(tab):gsub("%%", "%%%%"))
		table.insert(parts, sep .. SEP_RIGHT)
	end
	table.insert(parts, "%#TabLineFill#")
	return table.concat(parts)
end

function M.setup()
	set_highlights()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("elveblest-tabline", { clear = true }),
		callback = set_highlights,
	})
	vim.o.showtabline = 1
	vim.o.tabline = "%!v:lua.Elveblest.tabline.render()"
end

return M
