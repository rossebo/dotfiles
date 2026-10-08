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
-- vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
--   group = vim.api.nvim_create_augroup('ts_imports', { clear = true }),
--   pattern = { '*.tsx,*.ts' },
--   callback = function()
--     vim.lsp.buf.code_action {
--       apply = true,
--       context = {
--         only = { 'source.organizeImports.ts' },
--         diagnostics = {},
--       },
--     }
--   end,
-- })

-- Workaround for setting virtual buffers to type nofile, so we aren't prompted to save changes to them
-- This is handled by listing and iterating through them one second after startup because the __virtual.cs file is created later as a hidden buffer by the lsp
-- and cannot be captured by 'BufEnter', 'BufHidden', 'BufNewFile', 'BufRead', 'BufReadPost' or 'BufWinEnter' events
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = vim.api.nvim_create_augroup('rzls-virtual-buffers', { clear = true }),
  callback = function(event)
    vim.defer_fn(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if name:match 'razor' then
          local razor = require 'rzls.razor'
          if name:match(razor.virtual_suffixes.csharp .. '$') or name:match(razor.virtual_suffixes.html .. '$') then
            vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
            vim.api.nvim_set_option_value('buflisted', false, { buf = buf })
            vim.api.nvim_set_option_value('swapfile', false, { buf = buf })
            vim.api.nvim_set_option_value('readonly', true, { buf = buf })
          end
        end
      end
    end, 1000)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'cs',
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.expandtab = true
  end,
})

-- Define WoW Class Colors
vim.api.nvim_set_hl(0, 'WoWPaladin', { fg = '#F58CBA', bold = true })
vim.api.nvim_set_hl(0, 'WoWDruid',   { fg = '#FF7D0A', bold = true })
vim.api.nvim_set_hl(0, 'WoWShaman',  { fg = '#0070DE', bold = true })
vim.api.nvim_set_hl(0, 'WoWPriest',  { fg = '#F0F0F0', bold = true })
vim.api.nvim_set_hl(0, 'WoWRogue',   { fg = '#FFF468', bold = true })
vim.api.nvim_set_hl(0, 'WoWWarlock', { fg = '#8788EE', bold = true })
vim.api.nvim_set_hl(0, 'WoWMage',    { fg = '#3FC7EB', bold = true })
vim.api.nvim_set_hl(0, 'WoWHunter',  { fg = '#AAD372', bold = true })
vim.api.nvim_set_hl(0, 'WoWWarrior', { fg = '#C69B6D', bold = true })

-- Automatically highlight class names when opening any Markdown file
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.cmd([[
      syntax match WoWPaladin /\<Paladin\>/
      syntax match WoWDruid /\<Druid\>/
      syntax match WoWShaman /\<Shaman\>/
      syntax match WoWPriest /\<Priest\>/
      syntax match WoWRogue /\<Rogue\>/
      syntax match WoWWarlock /\<Warlock\>/
      syntax match WoWMage /\<Mage\>/
      syntax match WoWHunter /\<Hunter\>/
      syntax match WoWWarrior /\<Warrior\>/
    ]])
  end,
})

