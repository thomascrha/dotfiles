return {
  {
    'mason-org/mason.nvim',
    dependencies = {
      { 'mason-org/mason-lspconfig.nvim' },
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      { "j-hui/fidget.nvim", opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      "saghen/blink.cmp",
    },
    config = function()
      require("mason").setup()
      local servers_to_install = {
        -- "denols",
        ruff,
        -- debuggers
        codelldb,
        debugpy,
        -- formatters
        -- "clang_format",
        stylua,
        -- linters
        cpplint,
        luacheck,
        -- lsps
        -- disabled as its broken
        -- "azure_pipelines_ls"
        bashls,
        docker_compose_language_service,
        dockerls,
        jsonls,
        terraformls,
        yamlls,
        clangd,
        -- "gopls",
        pyright
      }
      require("mason-tool-installer").setup({ ensure_installed = servers_to_install })
    end,
  },
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
