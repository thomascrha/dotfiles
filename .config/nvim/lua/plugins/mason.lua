return {
  "williamboman/mason.nvim",
  dependencies = {
      "j-hui/fidget.nvim",
      "williamboman/mason-lspconfig.nvim",
  },
  config = function ()
    require('mason').setup()
    require('fidget').setup()
  end
}
