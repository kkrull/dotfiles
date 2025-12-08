-- Vim options, some (like mapleader) of which need to be set before plugins
-- are loaded (memoizing whatever their present value is).

-- clipboard
vim.opt.clipboard = "unnamedplus"

-- colors
vim.opt.termguicolors = true

-- command preview
vim.opt.inccommand = "split"

-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- search
vim.opt.ignorecase = true

-- splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- tabs
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- visual mode
vim.opt.virtualedit = "block"

-- wrapping
vim.opt.wrap = true

-- vim: ts=2 sts=2 sw=2 et
