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
    -- Finally, features are disabled by default (!!) and have to be enabled by
    -- autocmds and filetype plugins.
    -- Read on, see `/ftplugin/*`, or run `:h filetype-plugin` for details.
    config = function(_, opts)
      local ts = require('nvim-treesitter')
      ts.setup(opts)
      ts.install({
        'c',
        'lua',
        'vim',
        'vimdoc',
      })

      -- https://aliou.me/posts/upgrading-nvim-treesitter/
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('ui.treesitter', { clear = true }),
        pattern = { '*' },
        callback = function(event)
          -- Install a parser for the language, if not already installed
          local lang = event.match
          local ok, task = pcall(ts.install, { lang }, { summary = true })
          if not ok then return end

          -- Enable syntax highlighting
          ok, _ = pcall(vim.treesitter.start, event.buf, lang)
          if not ok then return end

          -- Global settings for all filetypes.
          -- Enable filetype-specific settings in `/ftplugin/<filetype>_<name>.lua`

          -- folds, provided by Neovim
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo.foldmethod = 'expr'

          -- indentation, provided by nvim-treesitter
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      })
    end,

    -- Does not support lazy-loading
    -- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#installation
    lazy = false,

    -- nvim-treesitter doesn't seem to have many opts that can go its its setup method, since v0.10
    -- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#setup
    opts = { },
  }
}
