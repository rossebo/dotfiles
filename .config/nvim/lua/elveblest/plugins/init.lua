-- Registered before vim.pack.add so it also fires on the first install.
vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("elveblest-pack", { clear = true }),
	desc = "Keep Treesitter parsers in sync with the plugin version",
	callback = function(event)
		local data = event.data
		if data.spec.name == "nvim-treesitter" and (data.kind == "install" or data.kind == "update") then
			if not data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

vim.pack.add({
	"https://github.com/rachartier/tiny-cmdline.nvim",
	"https://github.com/craftzdog/solarized-osaka.nvim",
	"https://github.com/nvim-mini/mini.icons",
	"https://github.com/nvim-mini/mini.pairs",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	{ src = "https://github.com/craftzdog/mini.diff", version = "feat/grouping" },
	"https://github.com/esmuellert/codediff.nvim",
	"https://github.com/linrongbin16/gitlinker.nvim",
	"https://github.com/zbirenbaum/copilot.lua",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/b0o/incline.nvim",
	"https://github.com/folke/snacks.nvim",
	"https://github.com/stevearc/oil.nvim",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/brenoprata10/nvim-highlight-colors",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/seblyng/roslyn.nvim",
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },
})

require("elveblest.plugins.ui")
require("elveblest.plugins.snacks")
require("elveblest.plugins.explorer")
require("elveblest.plugins.treesitter")
require("elveblest.plugins.highlights")
require("elveblest.plugins.completion")
require("elveblest.plugins.editing")
require("elveblest.plugins.lsp")
require("elveblest.plugins.formatting")
require("elveblest.plugins.git")
require("elveblest.plugins.ai")

require("elveblest.plugins.keymaps")
