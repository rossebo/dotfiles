local web = { "biome-check", "oxfmt", "prettierd", "prettier", stop_after_first = true }

require("conform").setup({
	formatters_by_ft = {
		javascript = web,
		typescript = web,
		javascriptreact = web,
		typescriptreact = web,
		json = web,
		css = web,
		scss = web,
		less = web,
		html = web,
		markdown = web,
		mdx = web,
		yaml = web,
		lua = { "stylua" },
		sh = { "shfmt" },
		fish = { "fish_indent" },
	},
	formatters = {
		-- Only runs when the project has biome config (biome.json)
		["biome-check"] = { require_cwd = true },
		-- Only runs when the project has an oxfmt config (.oxfmtrc.json, vite.config.ts, ...)
		oxfmt = { require_cwd = true },
	},
	format_on_save = function(bufnr)
		if vim.b[bufnr].disable_autoformat then
			return
		end
		return { timeout_ms = 1000, lsp_format = "fallback" }
	end,
})
