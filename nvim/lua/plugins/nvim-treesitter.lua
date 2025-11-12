-- Highlight, edit, and navigate code
-- `:help nvim-treesitter`
-- - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
-- - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
-- - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      -- Autoinstall languages that are not installed
      auto_install = true,
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      },
      highlight = {
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        additional_vim_regex_highlighting = { 'ruby' },
        enable = true,
      },
      indent = {
        disable = { 'ruby' },
        enable = true,
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
