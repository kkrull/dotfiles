-- Syntax highlighting, indentation, folding, etc..
-- https://github.com/nvim-treesitter/nvim-treesitter
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.config').setup({
      ensure_installed = { 'c', 'lua', 'vim', 'vimdoc' },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,

  -- Does not support lazy-loading
  -- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#installation
  lazy = false,
}
