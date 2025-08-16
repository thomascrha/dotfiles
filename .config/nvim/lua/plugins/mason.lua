return {
  {
    'mason-org/mason.nvim',
    dependencies = {
      { 'mason-org/mason-lspconfig.nvim' },
      { 'neovim/nvim-lspconfig' },
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      require("mason").setup()
      local ensure_installed = {
        -- multis
        'ruff', -- Used to lint Python code and formatting - has lsp but not used
        'denols', -- Deno language server for JavaScript/TypeScript - only used for formatting and linting
        -- linters
        'cpplint', -- Used to lint C++ code
        'luacheck', -- Used to lint Lua code
        'jsonlint', -- Used to lint JSON code
        'yamllint', -- Used to lint YAML code
        'hadolint', -- Used to lint Dockerfiles
        'shellcheck', -- Used to lint Bash scripts
        'tflint', -- Used to lint Terraform code
        -- formatters
        'black', -- Used to format Python code
        'isort', -- Used to sort Python imports
        'yamlfmt', -- Used to format YAML code
        'stylua', -- Used to format Lua code
        'clang-format', -- Used to format C/C++ code
        -- debugger
        'codelldb', -- Used for debugging Rust code
        'debugpy', -- Used for debugging Python code
        -- lsps
        'bashls', -- Bash language server
        'docker_compose_language_service', -- Docker Compose language server
        'dockerls', -- Docker language server
        'jsonls', -- JSON language server
        'terraformls', -- Terraform language server
        'yamlls', -- YAML language server
        'clangd', -- C/C++ language server
        'pyright', -- Python language server
        'lua_ls', -- Lua language server
      }
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
    end,
  },
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
