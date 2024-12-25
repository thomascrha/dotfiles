return {
  setup = function()
    local root_patterns = {
      'pyproject.toml',
      '.git',
      '.venv',
      'setup.py',
      'requirements.txt',
    }

    local utils = require('..utils')
    vim.lsp.config['basedpyright'] = {
      cmd = { 'basedpyright-langserver', '--stdio' },
      filetypes = { 'python' },
      root_dir = function(fname)
        utils.root_pattern(unpack(root_patterns))(fname)
        -- require('lua.utils').root_pattern(unpack(root_patterns))(fname)
      end,
      single_file_support = true,
      settings = {
        basedpyright = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = 'openFilesOnly',
          },
        },
      },

    }
    vim.lsp.enable('basedpyright')

    -- Create autocommand group for Python-specific settings
    vim.api.nvim_create_augroup('PythonSettings', { clear = true })

    -- Add autocommand that only triggers for Python files
    vim.api.nvim_create_autocmd('FileType', {
      group = 'PythonSettings',
      pattern = 'python',
      callback = function()
        local venv = vim.fn.findfile('pyproject.toml', vim.fn.getcwd() .. ';')
        local venvFolder = vim.fn.finddir('.venv', vim.fn.getcwd() .. ';')
        if venv ~= '' or venvFolder ~= '' then
          require('venv-selector').venv()
        end
      end,
      once = true,
    })
    return 'basedpyright'
  end
}
