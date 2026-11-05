local parsers = {
	"astro",
	"bash",
	"c",
	"cmake",
	"cpp",
	"css",
	"diff",
	"fish",
	"gitignore",
	"go",
	"graphql",
	"html",
	"http",
	"java",
	"javascript",
	"jsdoc",
	"json",
	"lua",
	"luadoc",
	"luap",
	"markdown",
	"markdown_inline",
	"php",
	"printf",
	"python",
	"query",
	"regex",
	"rust",
	"scss",
	"sql",
	"svelte",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"xml",
	"yaml",
}

local treesitter = require("nvim-treesitter")
treesitter.setup()

local installed = treesitter.get_installed()
local missing = vim.tbl_filter(function(lang)
	return not vim.list_contains(installed, lang)
end, parsers)
if #missing > 0 then
	treesitter.install(missing)
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("elveblest-treesitter", { clear = true }),
	desc = "Start Treesitter highlighting and indent when a parser exists",
	callback = function(event)
		local lang = vim.treesitter.language.get_lang(event.match)
		if lang and pcall(vim.treesitter.start, event.buf, lang) then
			vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})
