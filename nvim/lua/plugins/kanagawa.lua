return {
  {
    --https://lazy.folke.io/spec/examples
    --https://github.com/rebelot/kanagawa.nvim
    "rebelot/kanagawa.nvim",
    lazy = false,
    config = function()
      vim.cmd([[colorscheme kanagawa]])
    end,
  }
}
