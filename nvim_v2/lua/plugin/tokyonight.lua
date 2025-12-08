-- https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#-installation
return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd([[colorscheme tokyonight-moon]])
    end,
  }
}

-- vim: ts=2 sts=2 sw=2 et
