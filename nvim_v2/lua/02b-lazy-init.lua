-- Load lazy.nvim and any immediately-loaded plugins (like colorschemes)
-- setup([spec], opts): https://github.com/folke/lazy.nvim/blob/main/lua/lazy/init.lua#L31
-- spec: https://github.com/folke/lazy.nvim/blob/main/lua/lazy/types.lua#L84
-- opts: https://github.com/folke/lazy.nvim/blob/main/lua/lazy/core/config.lua#L7
require('lazy').setup({
  require 'plugin.mini',
  require 'plugin.neo-tree',
  require 'plugin.telescope',
  require 'plugin.tokyonight',
  require 'plugin.which-key',
}, {
  checker = {
    enabled = false
  },
  install = {
    colorscheme = { 'folke/tokyonight.nvim' }
  },
  rocks = {
    enabled = false,
  },
})

-- vim: ts=2 sts=2 sw=2 et
