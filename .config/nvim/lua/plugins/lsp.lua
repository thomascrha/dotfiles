-- Main LSP Configuration
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      { "j-hui/fidget.nvim", opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      "saghen/blink.cmp",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has("nvim-0.11") == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
          then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "highlight", buffer = event2.buf })
              end,
            })
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {},
        virtual_text = {
          source = "if_many",
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      local lsps = {
        -- disabled as its broken
        -- azure_pipelines_ls = {
        --   settings = {
        --     cmd = {
        --       "/home/tcrha/Software/azure-pipelines-language-server/language-server/bin/azure-pipelines-language-server",
        --     },
        --     schemas = {
        --       ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = {
        --         "azure-pipelines/**/*.y*l",
        --       },
        --     },
        --   },
        -- },
        denols = {},
        bashls = {},
        docker_compose_language_service = {},
        dockerls = {},
        jsonls = {},
        terraformls = {},
        yamlls = {},
        clangd = {},
        -- gopls = {},
        pyright = {
          settings = {
            python = {
              analysis = {
                extraPaths = {},
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
          on_init = function(client)
            -- Try to find .venv in the project root
            local root_dir = client.config.root_dir
            if root_dir then
              local venv_path = root_dir .. "/.venv"
              local site_packages = ""

              -- Check if .venv directory exists
              local f = io.open(venv_path, "r")
              if f then
                f:close()

                -- Look for site-packages directory in the virtual environment
                local python_version_cmd = "find " .. venv_path .. "/lib -type d -name 'python*' | sort | head -1"
                local handle = io.popen(python_version_cmd)
                if handle then
                  local python_lib_path = handle:read("*a"):gsub("%s+$", "")
                  handle:close()

                  if python_lib_path ~= "" then
                    site_packages = python_lib_path .. "/site-packages"

                    -- Add site-packages to extraPaths
                    client.config.settings.python.analysis.extraPaths = {
                      site_packages,
                    }

                    vim.notify("Python virtual environment found at: " .. venv_path, vim.log.levels.INFO)
                    vim.notify("Added to PYTHONPATH: " .. site_packages, vim.log.levels.INFO)
                  end
                end
              end
            end
            return true
          end,
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      }

      local ensure_installed = {
        -- multis
        'ruff', -- Used to lint Python code and formatting - has lsp but not used
        'denols', -- Deno language server for JavaScript/TypeScript - only used for formatting and linting
        -- linters
        'cpplint', -- Used to lint C++ code
        'luacheck', -- Used to lint Lua code
        -- formatters
        'stylua', -- Used to format Lua code
        'clang-format', -- Used to format C/C++ code
        -- debuggers
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
      }
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- The following loop will configure each server with the capabilities we defined above.
      -- This will ensure that all servers have the same base configuration, but also
      -- allow for server-specific overrides.
      for server_name, server_config in pairs(lsps) do
        server_config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})
        require("lspconfig")[server_name].setup(server_config)
      end
    end,
  },
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
