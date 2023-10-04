return {
  "folke/zen-mode.nvim",
  opts = {
    plugins = {
      wezterm = { enabled = true, font = "+4"},
    }
  },
  config = function ()
    vim.keymap.set('n', '<leader>z', '<cmd>ZenMode<CR>', { desc = 'Zen Mode' })
  end
}
