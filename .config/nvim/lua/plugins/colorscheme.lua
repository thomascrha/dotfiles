return {
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   opts = {},
  --   config = function()
  --     vim.cmd('colorscheme tokyonight-moon')
  --   end
  -- }
  {
    "navarasu/onedark.nvim",
    name = "onedark",
    priority = 1000,
    config = function()
      require('onedark').setup({
        toggle_style_key = "<leader>C"
      })
      vim.cmd('colorscheme onedark')
    end
  }
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
