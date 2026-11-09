local map = vim.keymap.set

-- Snacks: jump between occurrences of the word under the cursor
map("n", "]]", function()
	Snacks.words.jump(vim.v.count1)
end, { desc = "Next reference" })
map("n", "[[", function()
	Snacks.words.jump(-vim.v.count1)
end, { desc = "Previous reference" })

-- Snacks: picker
map("n", "<leader>sf", function()
	Snacks.picker.files({ hidden = true })
end, { desc = "Find files" })
map("n", "<leader>sg", function()
	Snacks.picker.grep({ hidden = true })
end, { desc = "Live grep" })
map("n", ";;", function()
	Snacks.picker.resume()
end, { desc = "Resume last picker" })
map("n", "<leader><leader>", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
map("n", ";e", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
map("n", ";n", function()
	Snacks.picker.notifications()
end, { desc = "Notification history" })
map("n", ";h", function()
	Snacks.picker.git_diff()
end, { desc = "Git hunks" })

-- Oil: file explorer
map("n", "<leader>pv", function()
	require("oil").open_float(nil, { preview = {} })
end, { desc = "Open file explorer" })

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("elveblest-oil-keymaps", { clear = true }),
	pattern = "oil",
	callback = function(event)
		map("n", "q", function()
			require("oil").close()
		end, { buffer = event.buf, desc = "Close oil" })
	end,
})

-- LSP
map("n", "gd", function()
	Snacks.picker.lsp_definitions()
end, { desc = "Go to definition" })
map("n", "gD", function()
	Snacks.picker.lsp_declarations()
end, { desc = "Go to declaration" })
map("n", "gy", function()
	Snacks.picker.lsp_type_definitions()
end, { desc = "Go to type definition" })
map("n", "gr", function()
	Snacks.picker.lsp_references()
end, { nowait = true, desc = "References" })

-- Source definition in TypeScript (skips the .d.ts), implementation elsewhere
map("n", "gI", function()
	local client = vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })[1]
	if not client then
		return Snacks.picker.lsp_implementations()
	end

	local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
	client:exec_cmd({
		command = "typescript.goToSourceDefinition",
		arguments = { params.textDocument.uri, params.position },
		title = "Go to source definition",
	}, { bufnr = 0 }, function(err, result)
		if err or not result or #result == 0 then
			return vim.notify("No source definition found", vim.log.levels.INFO)
		end
		if #result == 1 then
			return vim.lsp.util.show_document(result[1], client.offset_encoding, { focus = true })
		end
		vim.fn.setqflist({}, " ", {
			title = "Source definitions",
			items = vim.lsp.util.locations_to_items(result, client.offset_encoding),
		})
		vim.cmd("copen")
	end)
end, { desc = "Go to source definition / implementation" })

map("n", ";c", function()
	Snacks.picker.lsp_incoming_calls()
end, { desc = "Incoming calls" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover docs" })
map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("n", "<C-j>", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>cR", function()
	Snacks.rename.rename_file()
end, { desc = "Rename file" })
map({ "n", "v" }, "<leader>f", function()
	require("conform").format({ timeout_ms = 1000, lsp_format = "fallback" })
end, { desc = "Format" })
map("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", { desc = "LSP info" })

-- Gitsigns
map("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Blame line" })
map("n", "<leader>hB", function()
	require("gitsigns").blame()
end, { desc = "Blame buffer" })
map("n", "<leader>ho", function()
	Elveblest.git.open_blame_commit()
end, { desc = "Open file at the commit that last touched the line" })
map("n", "<leader>hs", function()
	local gitsigns = require("gitsigns")
	if #gitsigns.get_hunks() > 0 then
		gitsigns.stage_buffer()
	else
		gitsigns.reset_buffer_index()
	end
end, { desc = "Stage buffer, or unstage it if nothing is left to stage" })
map("n", "<leader>hh", function()
	require("gitsigns").stage_hunk()
end, { desc = "Stage or unstage hunk" })
map("v", "<leader>hh", function()
	require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Stage or unstage selected lines" })

-- mini.diff
map("n", "<leader>hd", function()
	require("mini.diff").toggle_overlay()
end, { desc = "Toggle diff overlay" })
map({ "n", "x", "o" }, "]c", function()
	require("mini.diff").goto_hunk("next")
end, { desc = "Next hunk" })
map({ "n", "x", "o" }, "[c", function()
	require("mini.diff").goto_hunk("prev")
end, { desc = "Previous hunk" })

-- codediff
local diff_tab
vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("elveblest-codediff", { clear = true }),
	pattern = { "CodeDiffOpen", "CodeDiffClose" },
	callback = function(event)
		if event.match == "CodeDiffOpen" then
			diff_tab = event.data.tabpage
		elseif diff_tab == event.data.tabpage then
			diff_tab = nil
		end
	end,
})

map("n", "<leader>dv", function()
	if diff_tab and vim.api.nvim_tabpage_is_valid(diff_tab) then
		vim.cmd("tabclose " .. vim.api.nvim_tabpage_get_number(diff_tab))
	else
		vim.cmd("CodeDiff")
	end
end, { desc = "Toggle diff view" })
map("n", "<leader>dh", "<cmd>CodeDiff history %<cr>", { desc = "File history" })
map("n", "<leader>dH", "<cmd>CodeDiff history<cr>", { desc = "Repo history" })

-- Lazygit
map("n", ";g", function()
	-- Remembered so that pressing e in lazygit opens the file in this window
	vim.g.lazygit_win = vim.api.nvim_get_current_win()
	Snacks.lazygit()
end, { desc = "Lazygit" })

-- Copilot (insert mode). Without a visible suggestion the key behaves as usual.
local function copilot(action, key)
	return function()
		local suggestion = require("copilot.suggestion")
		if suggestion.is_visible() then
			suggestion[action]()
		else
			vim.api.nvim_feedkeys(vim.keycode(key), "n", false)
		end
	end
end
map("i", "<C-l>", copilot("accept", "<C-l>"), { desc = "Copilot: accept suggestion" })
map("i", "<M-l>", copilot("accept_word", "<M-l>"), { desc = "Copilot: accept word" })
map("i", "<M-L>", copilot("accept_line", "<M-L>"), { desc = "Copilot: accept line" })
map("i", "<M-]>", function()
	require("copilot.suggestion").next()
end, { desc = "Copilot: next suggestion" })
map("i", "<M-[>", function()
	require("copilot.suggestion").prev()
end, { desc = "Copilot: previous suggestion" })
map("i", "<C-]>", copilot("dismiss", "<C-]>"), { desc = "Copilot: dismiss suggestion" })

-- Open the project's package.json, appsettings.json or requirements.txt in a float
map("n", "<leader>j", function()
	Elveblest.editor.open_project_file()
end, { desc = "Open project file" })
