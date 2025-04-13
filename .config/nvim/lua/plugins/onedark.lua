return {
  {
    "navarasu/onedark.nvim",
    name = "onedark",
    priority = 1000,
    config = function()
      require('onedark').setup({
        toggle_style_key = "<leader>ct"
      })
      vim.cmd('colorscheme onedark')
    end
  },
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
