require("copilot").setup({
	suggestion = {
		auto_trigger = true,
		-- Keys are mapped in plugins/keymaps.lua
		keymap = {
			accept = false,
			accept_word = false,
			accept_line = false,
			next = false,
			prev = false,
			dismiss = false,
		},
	},
	-- Notes and docs benefit from suggestions as much as code does
	filetypes = {
		markdown = true,
		help = true,
	},
})
