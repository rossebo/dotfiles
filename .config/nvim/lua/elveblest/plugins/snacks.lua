require("snacks").setup({
	notifier = { enabled = true },
	indent = { enabled = true },
	picker = { enabled = true },
	statuscolumn = { enabled = true },
	words = { enabled = true },
	lazygit = {
		theme = {
			activeBorderColor = { fg = "WarningMsg", bold = true },
		},
		config = {
			os = {
				-- Quit lazygit, focus the window it was launched from, then open the file there.
				-- Written with sh so it works whatever $SHELL is. Outside Neovim it just runs nvim <file>.
				editPreset = "",
				edit = [[sh -c 'if [ -z "$NVIM" ]; then nvim -- "$1"; else nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote-send "<C-\><C-n>:lua vim.api.nvim_set_current_win(vim.g.lazygit_win)<CR>" && nvim --server "$NVIM" --remote "$1"; fi' sh {{filename}}]],
			},
			gui = { nerdFontsVersion = "3" },
		},
	},
	scroll = { enabled = false },
})
