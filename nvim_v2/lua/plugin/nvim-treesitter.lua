-- Syntax highlighting, indentation, folding, etc..
-- https://github.com/nvim-treesitter/nvim-treesitter
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',

    -- lazy.nvim doesn't want you to write `config`: https://lazy.folke.io/spec#spec-setup
    --
    -- However, nvim-treesitter *demands* that you do call that function (that
    -- is, if you want it to do anything useful), while simultaneously moving
    -- the file you need to `require` around on the `main` branch.
    --
    -- Neatly summarized here:
    -- https://github.com/nvim-treesitter/nvim-treesitter/discussions/7535#discussioncomment-12842161
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,

    -- Does not support lazy-loading
    -- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#installation
    lazy = false,
    opts = {
      auto_install = true,
      ensure_installed = {
        'c',
        'lua',
        'vim',
        'vimdoc'
      },
      highlight = {
        enable = true
      },
      indent = {
        enable = true
      },
    },
  }
}
