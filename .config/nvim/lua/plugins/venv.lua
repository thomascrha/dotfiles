return {

  -- virtualenv support for pyright
  {
    'HallerPatrick/py_lsp.nvim',
    config = function()
      require("py_lsp").setup()
    end,

  },
}
