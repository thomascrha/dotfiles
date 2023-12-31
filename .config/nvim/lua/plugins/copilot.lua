return {
  {
    'zbirenbaum/copilot.lua',
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      local copilot = require('copilot')
      local suggestion = require('copilot.suggestion')

      copilot.setup({
        auto_refresh = true,
        suggestion = {
          auto_trigger = true
        },
        filetypes = {
          ["*"] = true
        }
      })

      vim.keymap.set('i', '<C-u>', function() suggestion.accept() end, {})
      -----------------------------------------------------------------------------------
      -- " Copilot
      -----------------------------------------------------------------------------------
      vim.keymap.set('n', '<leader>ce', '<cmd>Copilot enable<cr>', { desc = '[C]opilot [e]nable'})
      vim.keymap.set('n', '<leader>cd', '<cmd>Copilot disable<cr>', { desc = '[C]opilot [d]isable' })
      vim.keymap.set('n', '<leader>cs', '<cmd>Copilot status<cr>', { desc = '[C]opilot [s]tatus' })
    end
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function ()
      require("copilot_cmp").setup()
    end
  }
}
