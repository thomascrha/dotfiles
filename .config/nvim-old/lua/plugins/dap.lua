return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "nvim-neotest/nvim-nio",
    },
  },
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'mfussenegger/nvim-dap-python',
      'theHamsta/nvim-dap-virtual-text', -- Added virtual text support
      'nvim-telescope/telescope-dap.nvim', -- Added Telescope integration
    },
    keys = function()
      local dap, dapui = require('dap'), require('dapui')

      -- Define debug commands in a table for better organization
      local debug_commands = {
        start_or_continue = { dap.continue, 'Debug: Start/Continue' },
        step_into = { dap.step_into, 'Debug: Step Into' },
        step_over = { dap.step_over, 'Debug: Step Over' },
        step_out = { dap.step_out, 'Debug: Step Out' },
        toggle_breakpoint = { dap.toggle_breakpoint, 'Debug: Toggle Breakpoint' },
        conditional_breakpoint = {
          function()
            dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
          end,
          'Debug: Set Conditional Breakpoint'
        },
        toggle_ui = { dapui.toggle, 'Debug: Toggle UI' },
        terminate = { dap.terminate, 'Debug: Terminate Session' },
        clear_breakpoints = {
          function()
            dap.clear_breakpoints()
            vim.notify('Breakpoints cleared', vim.log.levels.INFO)
          end,
          'Debug: Clear all breakpoints'
        },
      }

      -- Convert commands to keymaps
      local keymaps = {
        { '<F5>', debug_commands.start_or_continue[1], desc = debug_commands.start_or_continue[2] },
        { '<F1>', debug_commands.step_into[1], desc = debug_commands.step_into[2] },
        { '<F2>', debug_commands.step_over[1], desc = debug_commands.step_over[2] },
        { '<F3>', debug_commands.step_out[1], desc = debug_commands.step_out[2] },
        { '<leader>b', debug_commands.toggle_breakpoint[1], desc = debug_commands.toggle_breakpoint[2] },
        { '<leader>B', debug_commands.conditional_breakpoint[1], desc = debug_commands.conditional_breakpoint[2] },
        { '<F7>', debug_commands.toggle_ui[1], desc = debug_commands.toggle_ui[2] },
        { '<F8>', debug_commands.terminate[1], desc = debug_commands.terminate[2] },
        { '<leader>dc', debug_commands.clear_breakpoints[1], desc = debug_commands.clear_breakpoints[2] },
      }

      return keymaps
    end,
    config = function()
      local dap, dapui = require('dap'), require('dapui')

      -- Configure Mason-DAP
      require('mason-nvim-dap').setup({
        automatic_installation = true,
        ensure_installed = {
          'debugpy',            -- Python
          'codelldb',          -- Rust, C++
          'js-debug-adapter',  -- JavaScript, TypeScript
          'node-debug2',       -- Node.js
        },
        handlers = {
          function(config)
            require('mason-nvim-dap').default_setup(config)
          end,
        },
      })

      -- Configure virtual text
      require('nvim-dap-virtual-text').setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        commented = false,
      })

      -- Configure DAP UI
      dapui.setup({
        icons = {
          expanded = '',
          collapsed = '',
          current_frame = '▸',
        },
        mappings = {
          expand = { '<CR>', '<2-LeftMouse>' },
          open = 'o',
          remove = 'd',
          edit = 'e',
          repl = 'r',
          toggle = 't',
        },
        layouts = {
          {
            elements = {
              { id = 'scopes', size = 0.4 },
              { id = 'stacks', size = 0.3 },
              { id = 'watches', size = 0.3 },
            },
            size = 0.3,
            position = 'right',
          },
          {
            elements = {
              { id = 'repl', size = 0.5 },
              { id = 'console', size = 0.5 },
            },
            size = 0.25,
            position = 'bottom',
          },
        },
        controls = {
          enabled = true,
          element = 'repl',
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = '',
            run_last = '↺',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      })

      -- Set up autocommands for DAP events
      local dap_group = vim.api.nvim_create_augroup('dap_group', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'dap-*',
        callback = function()
          vim.opt_local.number = true
          vim.opt_local.relativenumber = true
        end,
        group = dap_group,
      })

      -- Configure DAP signs
      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
      vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '→', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })

      -- Set up DAP event listeners
      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Configure Python debugging
      local function get_python_path()
        local venv_path = vim.fn.getcwd() .. '/.venv/bin/python'
        if vim.fn.filereadable(venv_path) == 1 then
          return venv_path
        end
        return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
      end

      require('dap-python').setup(get_python_path())

      -- Load launch.json if it exists
      require('dap.ext.vscode').load_launchjs(nil, {
        python = {'py'},
        node = {'js', 'ts'},
        rust = {'rs'},
        cpp = {'cpp', 'c'},
      })
    end,
  }
}
