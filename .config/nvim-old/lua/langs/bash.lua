return {
  setup = function()
    vim.lsp.config["bashls"] = {
      name = "bash-languge-server",
      cmd = {"bash-language-server", "start"},
      filetypes = {"sh", "bash"},
    }
    vim.lsp.enable("bashls")
    return 'bashls'
  end
}
