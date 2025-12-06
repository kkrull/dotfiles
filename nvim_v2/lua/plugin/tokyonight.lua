-- https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#-installation
return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd([[colorscheme tokyonight-moon]])
    end,
  }
}
