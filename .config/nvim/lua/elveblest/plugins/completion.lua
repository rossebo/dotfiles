require("blink.cmp").setup({
	keymap = { preset = "enter" },
	completion = {
		accept = { auto_brackets = { enabled = true } },
		documentation = { auto_show = true, auto_show_delay_ms = 200 },
		ghost_text = { enabled = false },
		menu = {
			draw = {
				treesitter = { "lsp" },
				components = {
					kind_icon = {
						text = function(ctx)
							return (MiniIcons.get("lsp", ctx.kind)) .. ctx.icon_gap
						end,
						highlight = function(ctx)
							local _, hl = MiniIcons.get("lsp", ctx.kind)
							return hl
						end,
					},
				},
			},
		},
	},
	cmdline = {
		completion = {
			menu = {
				auto_show = function()
					return vim.fn.getcmdtype() == ":"
				end,
			},
			list = { selection = { preselect = false } },
		},
	},
})

-- Every language server gets blink.cmp's completion capabilities
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})
