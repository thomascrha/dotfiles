return {
  {
    "stevearc/oil.nvim",
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
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
    end,
  },
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
