return {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
			},
			hint = { enable = true, paramType = true },
			diagnostics = {
				disable = { "missing-fields", "incomplete-signature-doc", "duplicate-set-field" },
			},
		},
	},
}
