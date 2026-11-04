local augroup = vim.api.nvim_create_augroup("elveblest", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	desc = "Flash yanked text",
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
	group = augroup,
	desc = "Show the cursorline in the active window only",
	callback = function()
		vim.wo.cursorline = true
	end,
})

vim.api.nvim_create_autocmd("WinLeave", {
	group = augroup,
	desc = "Hide the cursorline in inactive windows",
	callback = function()
		vim.wo.cursorline = false
	end,
})
