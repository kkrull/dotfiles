-- filetype plugin for lua, which enables nvim-treesitter
-- See `:h filetype-plugin` for details.

-- syntax highlighting, provided by Neovim
vim.treesitter.start()

-- folds, provided by Neovim
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo.foldmethod = 'expr'

-- indentation, provided by nvim-treesitter
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
