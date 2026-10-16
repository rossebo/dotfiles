-- Neovim ships the tree-sitter client; nvim-treesitter (main branch) is only
-- used to install/update parsers and provide queries. Needs the `tree-sitter`
-- CLI and a C compiler on PATH.
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local ts = require 'nvim-treesitter'
    local parsers = { 'python', 'lua', 'c_sharp', 'bash', 'json', 'yaml', 'toml', 'markdown', 'markdown_inline' }

    -- The tree-sitter CLI comes from Mason (async), so wait for it if missing
    if vim.fn.executable 'tree-sitter' == 1 then
      ts.install(parsers)
    else
      vim.api.nvim_create_autocmd('User', {
        pattern = 'MasonToolsComplete',
        once = true,
        callback = function()
          ts.install(parsers)
        end,
      })
    end

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('elveblest-treesitter', { clear = true }),
      callback = function(args)
        -- Silently skip filetypes without an installed parser
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
