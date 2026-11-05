require("mason").setup({
	registries = {
		"github:mason-org/mason-registry",
		-- Provides roslyn for dotnet
		"github:Crashdummyy/mason-registry",
	},
})

require("mason-tool-installer").setup({
	ensure_installed = {
		-- Language servers
		"lua-language-server",
		"vtsls",
		"eslint-lsp",
		"oxlint",
		"tailwindcss-language-server",
		"css-lsp",
		"rust-analyzer",
		"copilot-language-server",
		-- Language servers for Python, dotnet, TypeScript and SQL
		"pyright",
		"ruff",
		"biome",
		"roslyn",
		"sqls",
		-- Formatters
		"prettier",
		"prettierd",
		"oxfmt",
		"stylua",
		"shfmt",
		"csharpier",
		"sqlfluff",
	},
	auto_update = false,
	run_on_start = true,
})

-- Every server gets file-rename support
vim.lsp.config("*", {
	capabilities = {
		workspace = {
			fileOperations = {
				didRename = true,
				willRename = true,
			},
		},
	},
})

vim.lsp.enable({
	"eslint",
	"oxlint",
	"lua_ls",
	"cssls",
	"vtsls",
	"tailwindcss",
	"rust_analyzer",
	"pyright",
	"ruff",
	"biome",
	"sqls",
})

-- roslyn.nvim enables the roslyn server for C# itself
require("roslyn").setup()

local severity = vim.diagnostic.severity
local icons = Elveblest.icons.diagnostics
vim.diagnostic.config({
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	virtual_text = { prefix = "●", source = "if_many" },
	signs = {
		text = {
			[severity.ERROR] = icons.error,
			[severity.WARN] = icons.warn,
			[severity.INFO] = icons.info,
			[severity.HINT] = icons.hint,
		},
	},
})
