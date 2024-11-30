return {
  {
    'zbirenbaum/copilot.lua',
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      -- Cache frequently used modules
      local copilot = require('copilot')
      local suggestion = require('copilot.suggestion')

      -- Define keymaps in a table for better organization
      vim.keymap.set('i', '<C-u>', function() suggestion.accept() end, {})
      vim.keymap.set('i', '<C-n>', function() suggestion.next() end, {})
      vim.keymap.set('i', '<C-p>', function() suggestion.previous() end, {})
      vim.keymap.set('n', '<leader>ce', '<cmd>Copilot enable<cr><cmd>Copilot status<cr>', { desc = '[C]opilot [e]nable'})
      vim.keymap.set('n', '<leader>cd', '<cmd>Copilot disable<cr><cmd>Copilot status<cr>', { desc = '[C]opilot [d]isable' })
      vim.keymap.set('n', '<leader>cs', '<cmd>Copilot status<cr>', { desc = '[C]opilot [s]tatus' })

      -- Setup configuration
      copilot.setup({
        auto_refresh = true,
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = false, -- Disable default keymaps
            next = false,
            prev = false,
          }
        },
        filetypes = {
          ["*"] = true,
          -- Add specific filetype exclusions if needed
          -- Example:
          -- ["markdown"] = false,
          -- ["text"] = false,
        }
      })
    end
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = function()
      -- Only build tiktoken on Unix systems
      if vim.fn.has('unix') == 1 then
        vim.fn.system('make tiktoken')
      end
    end,
    opts = {
      -- Add some default configuration
      debug = false, -- Enable debugging
      show_help = true, -- Show help message in command line
      prompts = {
        -- Add custom prompts
        Explain = "Explain how this code works:",
        Review = "Review this code and suggest improvements:",
        Tests = "Generate unit tests for this code:",
      },
    },
  },

  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    opts = {
      provider = "copilot",
      copilot = {
        model = "claude-3.5-sonnet", -- Updated model name
        -- max_tokens = 4096,
      },
      -- Add UI configuration
      ui = {
        border = "rounded",
        width = 0.8, -- 80% of screen width
        height = 0.8, -- 80% of screen height
        transparency = 0, -- Fully opaque
      },
      -- Add keymaps configuration
      keymaps = {
        close = "<Esc>",
        submit = "<C-Enter>",
        toggle = "<leader>aa",
      },
    },
    build = vim.fn.has('win32') == 1
      and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = vim.fn.has('win32') == 1,
            -- Add image directory configuration
            image_dir = "assets/images",
            -- Add file naming pattern
            file_name_pattern = "%Y%m%d_%H%M%S",
          },
        },
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
          -- Add highlighters configuration
          highlighters = {
            code_blocks = true,
            headlines = true,
            tables = true,
          },
        },
        ft = { "markdown", "Avante" },
      },
    },
  }
}
