-- Configure and install plugins
-- https://lazy.folke.io/installation
require('lazy').setup({
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.gitsigns',
  -- require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.neo-tree',
  require 'plugins.blink',
  -- require 'plugins.colorscheme.kanagawa',
  require 'plugins.colorscheme.tokyonight',
  require 'plugins.conform',
  -- require 'plugins.gitsigns-basic',
  require 'plugins.lsp',
  require 'plugins.mini',
  require 'plugins.nvim-treesitter',
  require 'plugins.telescope',
  require 'plugins.todo-comments',
  require 'plugins.vim-sleuth',
  require 'plugins.which-key',

  -- { import = 'custom.plugins' },
}, {
  rocks = {
    enabled = false,
  },
  ui = {
    -- Fallback to unicode icons if a Nerd Font is not available
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
