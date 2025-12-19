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
    --
    -- Finally, features are disabled by default (!!) and have to be enabled by filetype plugins.
    -- See `/ftplugin/*` and `:h filetype-plugin` for details.
    -- Also see `:setfiletype <ctrl-d>` for a list of known filetypes
    config = function(_, opts)
      -- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#setup
      local ts = require('nvim-treesitter')
      ts.setup(opts)
      ts.install({
        'c',
        'lua',
        'vim',
        'vimdoc',
      })
    end,

    -- Does not support lazy-loading
    -- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#installation
    lazy = false,

    -- nvim-treesitter doesn't seem to have many opts that can go its its setup method, since v0.10 
    opts = { },
  }
}
