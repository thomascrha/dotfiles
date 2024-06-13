return {
  setup = function ()
    local util = require("lspconfig.util")
    local lspconfig = require("lspconfig")
    local configs = require("lspconfig.configs")

    local root_files = {
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
    }

    local function exepath(expr)
      local ep = vim.fn.exepath(expr)
      return ep ~= "" and ep or nil
    end

    local custom_attach = function(client) print("Pylance LSP started."); end

    -- Syntax highlight for Deluge files
    vim.cmd [[ autocmd BufNewFile,BufRead /*.py setf pylance ]]

    -- Check if it's already defined for when reloading this file.
    if not lspconfig.pylance then
      print("Setting up pylance")
      configs.pylance = {
        default_config = {
          before_init = function(_, config)
            if not config.settings.python then
              config.settings.python = {}
            end
            if not config.settings.python.pythonPath then
              config.settings.python.pythonPath = exepath("python3") or exepath("python") or "python"
            end
          end,
          cmd = {
            "node",
            vim.fn.expand(
              "~/.vscode-insiders/extensions/ms-python.vscode-pylance-2024.5.1/dist/server_nvim.js",
              false,
              true
            )[1],
            "--stdio",
          },
          filetypes = { "python" },
          single_file_support = true,
          root_dir = util.root_pattern(unpack(root_files)),
          settings = {
            python = {
              analysis = {
                inlayHints = {
                  variableTypes = true,
                  functionReturnTypes = false,
                  callArgumentNames = true,
                  pytestParameters = true,
                },
              },
            },
          },
        }
      };
    end

    lspconfig.pylance.setup {
      on_attach = custom_attach
    }

  end
}
