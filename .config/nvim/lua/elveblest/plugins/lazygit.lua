return {
  'kdheepak/lazygit.nvim',
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    { '<leader>hg', '<cmd>LazyGit<cr>', desc = '[H]unk/[G]it open lazygit' },
    { '<leader>hf', '<cmd>LazyGitCurrentFile<cr>', desc = 'Git current [f]ile' },
    { '<leader>hl', '<cmd>LazyGitFilter<cr>', desc = 'Git [l]og' },
  },
}
