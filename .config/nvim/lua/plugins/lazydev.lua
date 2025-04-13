-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  }
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
