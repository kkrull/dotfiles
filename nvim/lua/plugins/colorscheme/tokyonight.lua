return {
  {
    'folke/tokyonight.nvim',
    lazy = false, -- Load this plugin immediately
    priority = 1000, -- Ensure it loads before other plugins that might depend on colorscheme
    config = function()
      vim.cmd 'colorscheme tokyonight-moon'
    end,
  },
}
