return {
  'pwntester/octo.nvim',
  cmd = 'Octo',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-mini/mini.icons',
  },
  config = function()
    require('octo').setup {
      picker = 'telescope',
    }
  end,
  keys = {
    -- PR
    { '<leader>opl', '<cmd>Octo pr list<cr>', desc = '[O]cto [P]R [L]ist' },
    { '<leader>opc', '<cmd>Octo pr create<cr>', desc = '[O]cto [P]R [C]reate' },
    {
      '<leader>opo',
      function()
        vim.ui.input({ prompt = 'PR number to checkout: ' }, function(input)
          if input and input ~= '' then
            vim.cmd('Octo pr checkout ' .. input)
          end
        end)
      end,
      desc = '[O]cto [P]R Check[o]ut',
    },
    { '<leader>ops', '<cmd>Octo pr search is:open review-requested:@me<cr>', desc = '[O]cto [P]R [S]earch (review requested)' },

    -- Review
    { '<leader>orb', '<cmd>Octo review start<cr>', desc = '[O]cto [R]eview start ([B]ranch)' },
    { '<leader>orr', '<cmd>Octo review resume<cr>', desc = '[O]cto [R]eview [R]esume' },
    { '<leader>orc', '<cmd>Octo review commits<cr>', desc = '[O]cto [R]eview [C]ommits' },
    { '<leader>ord', '<cmd>Octo review discard<cr>', desc = '[O]cto [R]eview [D]iscard' },
  },
}
