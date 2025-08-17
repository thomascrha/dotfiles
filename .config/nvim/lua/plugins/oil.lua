return {
  {
    "stevearc/oil.nvim",
    opts = {},
    config = function()
      require("mini.icons").setup()
      require("oil").setup({
        skip_confirm_for_simple_edits = true,
        columns = { "icon" },
        keymaps = {
          ["<C-h>"] = false,
          ["<C-l>"] = false,
          ["<C-k>"] = false,
          ["<C-j>"] = false,
          ["<M-h>"] = "actions.select_split",
        },
        view_options = { show_hidden = true },
      })
      vim.keymap.set("n", "<leader>-", "<cmd>Oil<CR>", { desc = "Toggle Oil" })
      -- Disable line numbers in oil buffers
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("oil_settings", { clear = true }),
        pattern = "oil://*",
        callback = function()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
        end,
        desc = "Disable line numbers in oil file explorer",
      })
    end,
  },
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
