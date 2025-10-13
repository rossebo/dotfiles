return {
  'stevearc/oil.nvim',
  -- Simple configuration, mostly relying on defaults.
  opts = {
    -- Automatically open Oil when editing a directory (like netrw)
    default_file_explorer = true,
    view_options = {
      -- Show hidden files by default.
      show_hidden = true,
    },
    -- Use the default keymaps (g., -, _, etc.)
  },
  dependencies = {
    -- Icon dependency
    { 'nvim-mini/mini.icons', opts = {} },
  },
  -- Recommended setting to prevent load issues
  lazy = false,
}
