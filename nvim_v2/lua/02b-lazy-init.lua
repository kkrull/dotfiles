-- Load lazy.nvim and any immediately-loaded plugins (like colorschemes)
-- https://lazy.folke.io/spec#spec-setup
-- setup([spec], opts): https://github.com/folke/lazy.nvim/blob/main/lua/lazy/init.lua#L31
-- spec: https://github.com/folke/lazy.nvim/blob/main/lua/lazy/types.lua#L84
-- opts: https://github.com/folke/lazy.nvim/blob/main/lua/lazy/core/config.lua#L7
require('lazy').setup({
  checker = {
    enabled = false
  },
  defaults = {
    -- Set to `false` to use the latest; some plugins do not keep stable up-to-date
    version = '*'
  },
  install = {
    colorscheme = { 'folke/tokyonight.nvim' }
  },
  rocks = {
    enabled = false,
  },
  spec = {
    { import = 'plugin.mini' },
    { import = 'plugin.neo-tree' },
    { import = 'plugin.nvim-treesitter' },
    { import = 'plugin.telescope' },
    { import = 'plugin.tokyonight' },
    { import = 'plugin.which-key' },
  },
})

-- vim: ts=2 sts=2 sw=2 et
