-- Syntax highlighting, indentation, folding, etc..
-- https://github.com/nvim-treesitter/nvim-treesitter
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    branch = 'main',

    -- lazy.nvim doesn't want you to write `config`: https://lazy.folke.io/spec#spec-setup
    --
    -- However, nvim-treesitter *demands* that you do call that function (that
    -- is, if you want it to do anything useful), while simultaneously moving
    -- the file you need to `require` around on the `main` branch.
    --
    -- Neatly summarized here:
    -- https://github.com/nvim-treesitter/nvim-treesitter/discussions/7535#discussioncomment-12842161
    config = function(_, opts)
      require('nvim-treesitter').install({
        'c',
        'lua',
        'vim',
        'vimdoc',
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'lua' },
        callback = function()
          -- syntax highlighting, provided by Neovim
          vim.treesitter.start()
          -- folds, provided by Neovim
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo.foldmethod = 'expr'
          -- indentation, provided by nvim-treesitter
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
  })

    end,

    -- Does not support lazy-loading
    -- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#installation
    lazy = false,

    -- nvim-treesitter doesn't seem to have many opts that can go its its setup method, since v0.10 
    opts = { },
  }
}
