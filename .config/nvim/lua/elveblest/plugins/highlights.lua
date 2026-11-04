require("todo-comments").setup()

-- Neovim's own LSP document colors are off, so colors aren't painted twice.
vim.lsp.document_color.enable(false)

require("nvim-highlight-colors").setup({
	render = "background",
	enable_hex = true,
	enable_rgb = true,
	enable_hsl = true,
	enable_ansi = true,
	enable_var_usage = true,
	enable_tailwind = false,
})
