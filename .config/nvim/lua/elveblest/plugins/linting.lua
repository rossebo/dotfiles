return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      svelte = { 'eslint_d' },
      python = { 'pylint' },
      go = { 'golangcilint' },
    }

    -- Per-buffer active line range filter. nil = no filter (show all diagnostics).
    local selection_filter = {}
    local is_filtering = false

    local function apply_filter(bufnr)
      local sel = selection_filter[bufnr]
      if not sel then return end
      if is_filtering then return end
      is_filtering = true
      for ns_id in pairs(vim.diagnostic.get_namespaces()) do
        local all = vim.diagnostic.get(bufnr, { namespace = ns_id })
        if #all > 0 then
          local filtered = vim.tbl_filter(function(d)
            return d.lnum >= sel.start_line and d.lnum <= sel.end_line
          end, all)
          vim.diagnostic.set(ns_id, bufnr, filtered)
        end
      end
      is_filtering = false
    end

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    -- Re-apply the selection filter whenever any diagnostic source updates,
    -- so LSP re-sends after formatting don't blow away the filter.
    vim.api.nvim_create_autocmd('DiagnosticChanged', {
      group = lint_augroup,
      callback = function(args)
        if not is_filtering then
          apply_filter(args.buf)
        end
      end,
    })

    -- Normal mode: clear the filter and lint the whole file
    vim.keymap.set('n', '<leader>l', function()
      local bufnr = vim.api.nvim_get_current_buf()
      selection_filter[bufnr] = nil
      lint.try_lint()
    end, { desc = 'Lint current file (show all diagnostics)' })

    -- Visual mode: set a persistent line-range filter, then lint
    vim.keymap.set('v', '<leader>l', function()
      local bufnr = vim.api.nvim_get_current_buf()
      -- Marks '< and '> are written when the visual keymap fires
      local start_line = vim.fn.line "'<" - 1 -- convert to 0-indexed
      local end_line = vim.fn.line "'>" - 1
      selection_filter[bufnr] = { start_line = start_line, end_line = end_line }
      lint.try_lint()
      -- Apply immediately to existing diagnostics (LSP ones already in the buffer)
      vim.schedule(function()
        apply_filter(bufnr)
      end)
    end, { desc = 'Lint selected lines only' })
  end,
}
