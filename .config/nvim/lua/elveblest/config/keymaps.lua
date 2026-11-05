local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- Delete without copying
map("n", "x", '"_x', "Delete without copying")

-- Delete, change and paste without touching the yank register
map({ "n", "v" }, "<leader>d", '"_d', "Delete without yanking")
map({ "n", "v" }, "<leader>c", '"_c', "Change without yanking")
map({ "n", "v" }, "<leader>p", '"0p', "Paste the last yank")

-- Delete the word backwards without copying
map("n", "dw", 'vb"_d', "Delete word backwards without copying")

-- Increment and decrement numbers
map("n", "+", "<C-a>", "Increment number")
map("n", "-", "<C-x>", "Decrement number")

-- Select all
map("n", "<C-a>", "gg<S-v>G", "Select all")

-- Tabs
map("n", "te", ":tabedit<Return>", "New tab")
map("n", "<Tab>", ":tabnext<Return>", "Next tab")
map("n", "<S-Tab>", ":tabprev<Return>", "Previous tab")

-- Splits
map("n", "ss", ":split<Return><C-w>w", "Split horizontally")
map("n", "sv", ":vsplit<Return><C-w>w", "Split vertically")

-- Move between windows
map("n", "sh", "<C-w>h", "Go to left window")
map("n", "sj", "<C-w>j", "Go to lower window")
map("n", "sk", "<C-w>k", "Go to upper window")
map("n", "sl", "<C-w>l", "Go to right window")

-- Jump forward in the jump list (<C-i> is Tab in the terminal, which is taken above)
map("n", "<C-m>", "<C-i>", "Jump forward in the jump list")

-- Open a line below or above without continuing a comment
map("n", "<leader>o", "o<Esc>^Da", "Open line below without a comment")
map("n", "<leader>O", "O<Esc>^Da", "Open line above without a comment")

-- Close every hidden buffer, except unsaved ones
map("n", "<leader>bd", function()
	for _, buf in ipairs(vim.fn.getbufinfo({ bufloaded = 1 })) do
		if buf.hidden == 1 and buf.changed == 0 then
			vim.api.nvim_buf_delete(buf.bufnr, {})
		end
	end
end, "Close hidden buffers")

-- Copy the file path with the cursor line, to point an agent at the exact line
map("n", "<leader>yf", function()
	Elveblest.editor.copy_path()
end, "Copy relative file path with line")
map("n", "<leader>yp", function()
	Elveblest.editor.copy_path(true)
end, "Copy absolute file path with line")

-- Copy the selection as a Markdown code block for an agent
map("v", "<leader>cc", function()
	Elveblest.editor.copy_code_block()
end, "Copy selection as a code block")
