-- clipboard
vim.opt.clipboard = "unnamedplus"

-- colors
vim.opt.termguicolors = true

-- command preview
vim.opt.inccommand = "split"

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

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set configuration before plugins load (and remember) it
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Load lazy.nvim and any immediately-loaded plugins (like colorschemes)
require("lazy").setup({
  spec = {
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {},
      config = function()
        vim.cmd([[colorscheme tokyonight-moon]])
      end,
    }
  },
  install = { colorscheme = { "folke/tokyonight.nvim" } },
  checker = { enabled = false },
})
