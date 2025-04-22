return {
  {
    "psliwka/vim-dirtytalk",
    build = ":DirtytalkUpdate",
    config = function()
      vim.o.spelllang = "en_au,programming"
    end,
  },
}
