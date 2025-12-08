-- Load lazy.nvim and any immediately-loaded plugins (like colorschemes)
-- setup([spec], opts): https://github.com/folke/lazy.nvim/blob/main/lua/lazy/init.lua#L31
-- spec: https://github.com/folke/lazy.nvim/blob/main/lua/lazy/types.lua#L84
-- opts: https://github.com/folke/lazy.nvim/blob/main/lua/lazy/core/config.lua#L7
require("lazy").setup({
  checker = {
    enabled = false
  },
  install = {
    colorscheme = { "folke/tokyonight.nvim" }
  },
  rocks = {
    enabled = false,
  },
  spec = {
    { import = "plugin" },
  },
})

-- vim: ts=2 sts=2 sw=2 et
