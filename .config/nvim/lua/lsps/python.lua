return {
  setup = function()
    vim.lsp.config['basedpyright'] = {
      cmd = { 'basedpyright-langserver', '--stdio' },
      filetypes = { 'python' },
      root_dir = function(fname)
        return vim.fn.getcwd()
      end,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = 'workspace',
            typeCheckingMode = 'basic',
            stubPath = vim.fn.stdpath('data') .. '/site-packages',
          },
        },
      },
    }
  return 'basedpyright'
  end
}
