return {
  {
    "ThePrimeagen/refactoring.nvim",
    config = function()
      require("refactoring").setup()
      -----------------------------------------------------------------------------------
      -- refactoring
      -----------------------------------------------------------------------------------
      -- Remaps for the refactoring operations currently offered by the plugin
      vim.keymap.set("v", "<leader>re", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]], { desc = 'Extract Funciton' })
      vim.keymap.set("v", "<leader>rf", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]], { desc = 'Extract Fuction to [f]ile'})
      vim.keymap.set("v", "<leader>rv", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]], { desc = 'Extract [V]ariable' })
      vim.keymap.set("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], { desc = '[I]nline Variable' })

      -- Extract block doesn't need visual mode
      vim.keymap.set("n", "<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]], { desc = 'Extract [B]lock'})
      vim.keymap.set("n", "<leader>rf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]], { desc = 'Extract [b]lock to [f]ile'})

      -- Inline variable can also pick up the identifier currently under the cursor without visual mode
      vim.keymap.set("n", "<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], { desc = '[I]nline Variable'})

      -- load refactoring Telescope extension
      require("telescope").load_extension("refactoring")

      -- remap to open the Telescope refactoring menu in visual mode
      vim.keymap.set(
        "v",
        "<leader>rr",
        "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
        { desc = '[R]efactoring menu' }
      )

    end,
  },
}
