return {
  {
    "mfussenegger/nvim-dap",
    config = function()

      vim.keymap.set('n', '<F10>', '<cmd>lua require"dap".step_over()<CR>', { desc = 'Step Over' })
      vim.keymap.set('n', '<F11>', '<cmd>lua require"dap".step_into()<CR>', { desc = 'Step Into' })
      vim.keymap.set('n', '<S-F11>', '<cmd>lua require"dap".step_out()<CR>', { desc = 'Step Out' })
      vim.keymap.set('n', '<F5>', '<cmd>lua require"dap".continue()<CR>', { desc = 'Continue' })
      vim.keymap.set('n', '<S-F5>', '<cmd>lua require"dap".close()<CR>', { desc = 'Stop' })
      vim.keymap.set('n', '<C-S-F5>', '<cmd>lua require"dap".restart()<CR>', { desc = 'Restart' })
      -- breakpoints
      vim.keymap.set('n', '<F9>', "<cmd>lua require('persistent-breakpoints.api').toggle_breakpoint()<cr>", { desc = 'Toggle Breakpoint' })
      vim.keymap.set('n', '<S-F9>',
        "<cmd>lua require('persistent-breakpoints.api').set_conditional_breakpoint()<cr>", { desc = 'Toggle Conditional Breakpoint' }
      )
      vim.keymap.set('n', '<C-S-F9>',
        "<cmd>lua require('persistent-breakpoints.api').clear_all_breakpoints()<cr>", { desc = 'Clear All Breakpoints' }
      )

      vim.keymap.set('n', '<F7>', '<cmd>lua require"dapui".toggle()<CR>', { desc = '[D]ebug [U]I' })
      vim.keymap.set('n', '<F6>', '<cmd>lua require("neotest").run.run({strategy = "dap"})<CR>', { desc = '[D]ebug [T]est' })
    end
  },
  {
    'Weissle/persistent-breakpoints.nvim',
    config = function ()
      require('persistent-breakpoints').setup{
	    load_breakpoints_event = { "BufReadPost" },
      }
    end
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      dapui.setup()

      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end

      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end
  },

  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'mfussenegger/nvim-dap',
    },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "python", "rust" },
      })
    end
  },

  {
    'mfussenegger/nvim-dap-python',
    config = function()
      local path = vim.fn.getcwd() .. '/.venv/bin/python'
      require('dap-python').setup(path)
      require('dap.ext.vscode').load_launchjs(nil, {python = {'py'} })
    end
  }

}