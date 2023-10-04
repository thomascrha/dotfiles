return {
  {
    "windwp/nvim-spectre",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -----------------------------------------------------------------------------------
      -- " run command :Spectre
      -----------------------------------------------------------------------------------
      vim.keymap.set('n', '<leader>S', "<cmd>lua require('spectre').open()<cr>", { desc = '[S]ectre search' })
      -- "search current word
      vim.keymap.set({ 'n', 'v' }, '<leader>sw', "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", { desc = '[s]pectre current [w]ord' })
      -- "  search in current file
      vim.keymap.set('n', "<leader>sf", "<cmd>lua require('spectre').open_file_search()<cr>", { desc = '[s]pectre current [f]ile' })
    end,
  },

}
