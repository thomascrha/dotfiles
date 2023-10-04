return {
  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup({
        auto_open = false,
        auto_close = true,
        auto_preview = false,
        auto_fold = false,
        signs = {
          error = " ",
          warning = " ",
          hint = " ",
          information = " ",
          other = "﫠"
        },
        use_diagnostic_signs = true
      })
      -----------------------------------------------------------------------------------
      -- Trouble
      -----------------------------------------------------------------------------------
      vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>",
        { silent = true, noremap = true, desc = 'trouble diagnostics workspace' }
      )

      vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>",
        {silent = true, noremap = true}
      )
      vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>",
        {silent = true, noremap = true}
      )
      vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
        {silent = true, noremap = true}
      )
      vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>",
        {silent = true, noremap = true}
      )

    end
  },

}
