-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Organize imports on save
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = vim.api.nvim_create_augroup('ts_imports', { clear = true }),
  pattern = { '*.tsx,*.ts' },
  callback = function()
    vim.lsp.buf.code_action {
      apply = true,
      context = {
        only = { 'source.organizeImports.ts' },
        diagnostics = {},
      },
    }
  end,
})
