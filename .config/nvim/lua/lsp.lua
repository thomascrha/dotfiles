-- Main LSP Configuration
return {
  setup = function()
    vim.lsp.enable({
      "denols",
      "bashls",
      "docker_compose_language_service",
      "dockerls",
      "jsonls",
      "terraformls",
      "yamlls",
      "clangd",
      "pyright",
      "lua_ls",
    })
  end,
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
