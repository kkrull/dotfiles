-- Syntax highlighting, indentation, folding, etc..
-- https://github.com/nvim-treesitter/nvim-treesitter
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
--  config = function(_plugin, opts)
--    require('nvim-treesitter.configs').setup(opts)
--  end,

  -- Does not support lazy-loading
  -- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#installation
  lazy = false,
  opts = {
    ensure_installed = { 'c', 'lua', 'vim', 'vimdoc' },
    highlight = { enable = true },
    indent = { enable = true },
  },
}
