-- Linting
return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      -- https://github.com/mfussenegger/nvim-lint?tab=readme-ov-file#usage
      -- https://github.com/mfussenegger/nvim-lint?tab=readme-ov-file#available-linters
      -- Note: Linters can be installed with `:Mason`
      -- See available filetypes: https://vi.stackexchange.com/a/5782/19161
      local lint = require 'lint'
      lint.linters_by_ft = {
        make = { 'checkmake' },
        markdown = { 'markdownlint-cli2' },
      }

      -- Add autocommand that does the linting
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Avoid noisy lint errors on buffers you can't modify, like pop-ups
          if vim.opt_local.modifiable:get() then
            lint.try_lint()
          end
        end,
      })

      vim.api.nvim_create_user_command('Lint', function()
        require('lint').try_lint()
      end, {})

      local wk = require 'which-key'
      wk.add {
        { '<leader>l', group = '[L]int' },
      }
      vim.keymap.set('n', '<leader>lb', 'Lint', { desc = '[L]int [B]uffer' })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
