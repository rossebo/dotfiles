return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map('n', ']h', gs.next_hunk, 'Next hunk')
      map('n', '[h', gs.prev_hunk, 'Prev hunk')

      -- Blame
      map('n', '<leader>hb', function()
        gs.blame_line { full = true }
      end, 'Git [b]lame line')
      map('n', '<leader>hB', gs.toggle_current_line_blame, 'Git toggle inline [B]lame')

      -- Diff
      map('n', '<leader>hd', gs.diffthis, 'Git [d]iff this')
      map('n', '<leader>hD', function()
        gs.diffthis '~'
      end, 'Git [D]iff this ~')

      -- Hunk actions
      map('n', '<leader>hp', gs.preview_hunk, 'Git [p]review hunk')
      map('n', '<leader>hs', gs.stage_hunk, 'Git [s]tage hunk')
      map('v', '<leader>hs', function()
        gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, 'Git [s]tage hunk')
      map('n', '<leader>hr', gs.reset_hunk, 'Git [r]eset hunk')
      map('v', '<leader>hr', function()
        gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, 'Git [r]eset hunk')
      map('n', '<leader>hS', gs.stage_buffer, 'Git [S]tage buffer')
      map('n', '<leader>hR', gs.reset_buffer, 'Git [R]eset buffer')
      map('n', '<leader>hu', gs.undo_stage_hunk, 'Git [u]ndo stage hunk')

      -- Text object
      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Gitsigns select hunk')
    end,
  },
}
