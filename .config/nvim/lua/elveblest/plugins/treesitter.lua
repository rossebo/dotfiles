return { -- Highlight, edit, and navigate code

  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    -- nvim-treesitter main branch no longer manages highlighting itself;
    -- that is now a built-in Neovim feature. Enable it for every filetype
    -- that has a parser available, falling back silently when one is missing.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-highlight', { clear = true }),
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
