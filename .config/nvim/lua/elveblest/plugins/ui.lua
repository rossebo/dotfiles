require("solarized-osaka").setup({
	style = "vivid",
	transparent = true,
})
vim.cmd.colorscheme("solarized-osaka")

require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

Elveblest.tabline.setup()

local statusline = Elveblest.statusline
require("lualine").setup({
	options = {
		theme = "auto",
		globalstatus = true,
		section_separators = "",
		component_separators = "",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = {
			{ statusline.root_name },
			{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
			{ statusline.pretty_path },
		},
		lualine_x = {
			{ statusline.recording },
			{ "diagnostics" },
			{ "diff" },
		},
		lualine_y = { "progress" },
		lualine_z = { statusline.location },
	},
})

-- The recording indicator replaces the hidden command line, so refresh when a macro starts or stops.
vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
	group = vim.api.nvim_create_augroup("elveblest-statusline", { clear = true }),
	callback = function()
		vim.defer_fn(function()
			require("lualine").refresh({ place = { "statusline" } })
		end, 50)
	end,
})

require("incline").setup({
	hide = { cursorline = true },
	render = function(props)
		local name = vim.api.nvim_buf_get_name(props.buf)
		local filename = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
		local icon = name ~= "" and MiniIcons.get("file", filename) or nil
		local modified = vim.bo[props.buf].modified and "[+] " or ""
		return { " ", modified, icon and (icon .. " ") or "", filename, " " }
	end,
})

require("tiny-cmdline").setup({
	position = { x = "50%", y = "20%" },
})
