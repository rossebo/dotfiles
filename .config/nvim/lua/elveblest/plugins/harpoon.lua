return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  -- REQUIRED
  config = function()
    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():append()
    end, { desc = 'Add file to harpoon buffer' })
    vim.keymap.set('n', '<C-e>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Show harpoon file buffer' })
    --            vim.keymap.set('n', '<C-h>', function()
    --              harpoon:list():select(1)
    --            end, { desc = 'Go to first file in buffer' })
    --            vim.keymap.set('n', '<C-j>', function()
    --              harpoon:list():select(2)
    --            end, { desc = 'Go to second file in buffer' })
    --            vim.keymap.set('n', '<C-k>', function()
    --              harpoon:list():select(3)
    --            end, { desc = 'Go to third file in buffer' })
    --            vim.keymap.set('n', '<C-l>', function()
    --              harpoon:list():select(4)
    --            end, { desc = 'Go to fourth file in buffer' })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<C-S-P>', function()
      harpoon:list():prev()
    end)
    vim.keymap.set('n', '<C-S-N>', function()
      harpoon:list():next()
    end)
  end,
}
