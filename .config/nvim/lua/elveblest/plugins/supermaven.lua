return {
  'supermaven-inc/supermaven-nvim',
  config = function()
    require('supermaven-nvim').setup {
      keymaps = {
        accept_suggestion = '<Tab>',
        clear_suggestion = '<C-]>',
        accept_word = '<C-j>',
      },
      color = {
        suggestion_color = '#f6f6f6',
        cterm = 244,
      },
      log_level = 'info', -- set to "off" to disable logging completely
      ignored_filetypes = { 'gitcommit', 'gitrebase', 'gitconfig', 'gitignore', 'gitmodules', 'markdown', 'text' },
      disable_inline_completion = false, -- disables inline completion for use with cmp
      disable_keymaps = false, -- disables built in keymaps for more manual control
      condition = function()
        return false
      end,
    }
  end,
}
