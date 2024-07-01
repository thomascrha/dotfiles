return {
  'stevearc/oil.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require('oil').setup({
      skip_confirm_for_simple_edits = true,
      experimental_watch_for_changes = true,
      view_options = {
	show_hidden = true
      }
    })
    vim.keymap.set("n", "<leader>-", "<cmd>Oil<CR>", { desc = "Toggle Oil" })
  end
}
