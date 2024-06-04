return {
  'stevearc/oil.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require('oil').setup({
      auto_open = false,
      auto_close = true,
      auto_preview = false,
      auto_fold = false,
      signs = {
	error = " ",
	warning = " ",
	hint = " ",
	information = " ",
	other = "nvim"
      },
      use_diagnostic_signs = true
    })
    vim.keymap.set("n", "<leader>-", "<cmd>Oil<CR>", { desc = "Toggle Oil" })
  end
}
